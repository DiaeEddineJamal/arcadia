package com.Luziv.arcadia.mixer

import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.common.SimpleBasePlayer
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture

/**
 * A facade [Player] that exposes the whole mix as a single "track" to the media session, so the
 * system notification / lock screen can play, pause and stop every sound at once. This is the
 * equivalent of the Flutter `AppAudioHandler` (lib/services/app_audio_handler.dart).
 */
class MixerSessionPlayer(looper: Looper) : SimpleBasePlayer(looper) {

  private val engineListener: () -> Unit = { invalidateState() }

  init {
    MixerEngine.listeners.add(engineListener)
  }

  override fun getState(): State {
    val commands =
        Player.Commands.Builder()
            .addAll(
                Player.COMMAND_PLAY_PAUSE,
                Player.COMMAND_STOP,
                Player.COMMAND_GET_CURRENT_MEDIA_ITEM,
                Player.COMMAND_GET_METADATA,
                Player.COMMAND_GET_TIMELINE,
                Player.COMMAND_RELEASE,
            )
            .build()
    val builder =
        State.Builder()
            .setAvailableCommands(commands)
            .setPlayWhenReady(
                MixerEngine.isMasterPlaying, Player.PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST)

    if (MixerEngine.hasSessionContent) {
      val metadata =
          MediaMetadata.Builder()
              .setTitle(MixerEngine.sessionTitle)
              .setArtist("Arcadia Ambient Mix")
              .setAlbumTitle("Arcadia")
              .build()
      val item =
          MediaItemData.Builder(MIX_ID)
              .setMediaItem(
                  MediaItem.Builder().setMediaId(MIX_ID).setMediaMetadata(metadata).build())
              .setMediaMetadata(metadata)
              .setIsSeekable(false)
              .setIsDynamic(false)
              .build()
      builder.setPlaylist(listOf(item)).setPlaybackState(Player.STATE_READY)
    } else {
      builder.setPlaylist(emptyList()).setPlaybackState(Player.STATE_IDLE)
    }
    return builder.build()
  }

  override fun handleSetPlayWhenReady(playWhenReady: Boolean): ListenableFuture<*> {
    if (playWhenReady) MixerEngine.resumeAll() else MixerEngine.pauseAll()
    return Futures.immediateVoidFuture()
  }

  override fun handleStop(): ListenableFuture<*> {
    MixerEngine.stopAll()
    return Futures.immediateVoidFuture()
  }

  override fun handleRelease(): ListenableFuture<*> {
    MixerEngine.listeners.remove(engineListener)
    return Futures.immediateVoidFuture()
  }

  companion object {
    private const val MIX_ID = "arcadia_mix"
  }
}
