package com.Luziv.arcadia.mixer

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import java.util.concurrent.CopyOnWriteArraySet

/**
 * Multi-track ambient mixer. Port of the Flutter `AudioPlayerService`
 * (lib/services/audio_service.dart): one looping player per sound, per-sound volume multiplied
 * by a master volume, optional fade in/out, pause/resume-all and a sleep timer.
 *
 * Everything here runs on the main looper. Callers from other threads must post to it.
 */
object MixerEngine {
  private const val FADE_STEP_MS = 50L

  class Track(val id: String, val title: String, val player: ExoPlayer) {
    var volume = 0.7f
    var playing = false
    var fade = 1f
    var fadeRunnable: Runnable? = null
  }

  private val handler = Handler(Looper.getMainLooper())
  private val tracks = LinkedHashMap<String, Track>()
  private val pausedByMaster = LinkedHashSet<String>()
  private var appContext: Context? = null

  var masterVolume = 0.8f
    private set
  private var fadeEnabled = false
  private var fadeInSeconds = 3
  private var fadeOutSeconds = 5

  /** Wall-clock time (ms) when the sleep timer fires, 0 when no timer is set. */
  var sleepTimerEndsAt = 0L
    private set
  var sleepTimerMinutes = 0
    private set
  private var sleepRunnable: Runnable? = null
  private var stoppingWithFade = false

  val listeners = CopyOnWriteArraySet<() -> Unit>()

  fun init(context: Context) {
    if (appContext == null) appContext = context.applicationContext
  }

  val isMasterPlaying: Boolean
    get() = tracks.values.any { it.playing }

  /** True while there is something the media notification can control. */
  val hasSessionContent: Boolean
    get() = isMasterPlaying || pausedByMaster.isNotEmpty()

  val sessionTitle: String
    get() {
      val ids = if (isMasterPlaying) tracks.values.filter { it.playing } else pausedByMaster.mapNotNull { tracks[it] }
      return ids.joinToString(" • ") { it.title }.ifEmpty { "Arcadia" }
    }

  fun tracksSnapshot(): List<Track> = tracks.values.toList()

  fun load(id: String, fileName: String, title: String, volume: Float) {
    if (tracks.containsKey(id)) return
    val context = appContext ?: return
    val player =
        ExoPlayer.Builder(context).build().apply {
          // Same as the Flutter app: no audio focus so the mix plays alongside other audio.
          setAudioAttributes(
              AudioAttributes.Builder()
                  .setUsage(C.USAGE_MEDIA)
                  .setContentType(C.AUDIO_CONTENT_TYPE_MUSIC)
                  .build(),
              false)
          setWakeMode(C.WAKE_MODE_LOCAL)
          repeatMode = Player.REPEAT_MODE_ONE
          setMediaItem(MediaItem.fromUri("asset:///sounds/$fileName"))
          prepare()
        }
    val track = Track(id, title, player)
    track.volume = volume.coerceIn(0f, 1f)
    tracks[id] = track
    applyVolume(track)
    notifyChanged()
  }

  fun play(id: String) {
    val track = tracks[id] ?: return
    pausedByMaster.remove(id)
    if (track.playing) return
    track.playing = true
    if (fadeEnabled && fadeInSeconds > 0) {
      cancelFade(track)
      track.fade = 0f
      applyVolume(track)
      track.player.play()
      fadeTrack(track, 1f, fadeInSeconds * 1000L, null)
    } else {
      cancelFade(track)
      track.fade = 1f
      applyVolume(track)
      track.player.play()
    }
    notifyChanged()
  }

  fun pause(id: String) {
    val track = tracks[id] ?: return
    pausedByMaster.remove(id)
    if (!track.playing) return
    track.playing = false
    if (fadeEnabled && fadeOutSeconds > 0) {
      fadeTrack(track, 0f, fadeOutSeconds * 1000L) {
        track.player.pause()
        track.fade = 1f
        applyVolume(track)
      }
    } else {
      cancelFade(track)
      track.player.pause()
      track.fade = 1f
      applyVolume(track)
    }
    notifyChanged()
  }

  fun remove(id: String) {
    val track = tracks.remove(id) ?: return
    pausedByMaster.remove(id)
    cancelFade(track)
    track.player.release()
    notifyChanged()
  }

  /** [notify] false while a slider is being dragged: audio follows, JS is told on release. */
  fun setVolume(id: String, volume: Float, notify: Boolean = true) {
    val track = tracks[id] ?: return
    track.volume = volume.coerceIn(0f, 1f)
    applyVolume(track)
    if (notify) notifyChanged()
  }

  fun setMasterVolume(volume: Float, notify: Boolean = true) {
    masterVolume = volume.coerceIn(0f, 1f)
    tracks.values.forEach { applyVolume(it) }
    if (notify) notifyChanged()
  }

  fun setFadeConfig(enabled: Boolean, fadeIn: Int, fadeOut: Int) {
    fadeEnabled = enabled
    fadeInSeconds = fadeIn.coerceIn(0, 30)
    fadeOutSeconds = fadeOut.coerceIn(0, 60)
  }

  fun pauseAll() {
    val paused = LinkedHashSet<String>()
    for (track in tracks.values) {
      if (track.playing) {
        cancelFade(track)
        track.player.pause()
        track.playing = false
        track.fade = 1f
        applyVolume(track)
        paused.add(track.id)
      }
    }
    pausedByMaster.clear()
    pausedByMaster.addAll(paused)
    notifyChanged()
  }

  fun resumeAll() {
    if (pausedByMaster.isNotEmpty()) {
      for (id in pausedByMaster.toList()) {
        val track = tracks[id] ?: continue
        cancelFade(track)
        track.fade = 1f
        applyVolume(track)
        track.playing = true
        track.player.play()
      }
      pausedByMaster.clear()
    }
    notifyChanged()
  }

  fun stopAll() {
    for (track in tracks.values) {
      cancelFade(track)
      track.player.release()
    }
    tracks.clear()
    pausedByMaster.clear()
    stoppingWithFade = false
    cancelSleepTimer()
    notifyChanged()
  }

  fun setSleepTimer(minutes: Int) {
    cancelSleepTimer()
    if (minutes > 0) {
      sleepTimerMinutes = minutes
      sleepTimerEndsAt = System.currentTimeMillis() + minutes * 60_000L
      val runnable = Runnable {
        sleepRunnable = null
        fadeOutAndStop()
      }
      sleepRunnable = runnable
      handler.postAtTime(runnable, SystemClock.uptimeMillis() + minutes * 60_000L)
    }
    notifyChanged()
  }

  /** Sleep timer end: fade every playing sound out (when fades are enabled), then stop all. */
  fun fadeOutAndStop() {
    if (stoppingWithFade) return
    sleepTimerEndsAt = 0L
    sleepTimerMinutes = 0
    val playing = tracks.values.filter { it.playing }
    if (!fadeEnabled || fadeOutSeconds <= 0 || playing.isEmpty()) {
      stopAll()
      return
    }
    stoppingWithFade = true
    var remaining = playing.size
    for (track in playing) {
      fadeTrack(track, 0f, fadeOutSeconds * 1000L) {
        remaining -= 1
        if (remaining == 0 && stoppingWithFade) stopAll()
      }
    }
    notifyChanged()
  }

  private fun cancelSleepTimer() {
    sleepRunnable?.let { handler.removeCallbacks(it) }
    sleepRunnable = null
    sleepTimerEndsAt = 0L
    sleepTimerMinutes = 0
  }

  private fun applyVolume(track: Track) {
    track.player.volume = (track.volume * masterVolume * track.fade).coerceIn(0f, 1f)
  }

  private fun cancelFade(track: Track) {
    track.fadeRunnable?.let { handler.removeCallbacks(it) }
    track.fadeRunnable = null
  }

  private fun fadeTrack(track: Track, target: Float, durationMs: Long, onEnd: (() -> Unit)?) {
    cancelFade(track)
    val start = track.fade
    val steps = (durationMs / FADE_STEP_MS).coerceAtLeast(1)
    var step = 0L
    val runnable =
        object : Runnable {
          override fun run() {
            if (!tracks.containsKey(track.id)) return
            step += 1
            track.fade = start + (target - start) * (step.toFloat() / steps)
            applyVolume(track)
            if (step >= steps) {
              track.fadeRunnable = null
              track.fade = target
              applyVolume(track)
              onEnd?.invoke()
            } else {
              handler.postDelayed(this, FADE_STEP_MS)
            }
          }
        }
    track.fadeRunnable = runnable
    handler.postDelayed(runnable, FADE_STEP_MS)
  }

  private fun notifyChanged() {
    listeners.forEach { it.invoke() }
  }
}
