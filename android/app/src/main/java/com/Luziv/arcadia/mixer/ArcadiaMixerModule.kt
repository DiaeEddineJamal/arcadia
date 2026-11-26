package com.Luziv.arcadia.mixer

import android.content.ComponentName
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.HapticFeedbackConstants
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.google.common.util.concurrent.ListenableFuture
import java.io.File

/** JS bridge for [MixerEngine]. All engine calls are posted to the main looper. */
class ArcadiaMixerModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

  private val main = Handler(Looper.getMainLooper())
  private var controllerFuture: ListenableFuture<MediaController>? = null
  private var emitScheduled = false

  private val engineListener: () -> Unit = {
    // Coalesce bursts of changes (slider drags, fades) into one JS event per frame-ish.
    if (!emitScheduled) {
      emitScheduled = true
      main.postDelayed(
          {
            emitScheduled = false
            emitState()
          },
          16)
    }
  }

  init {
    main.post {
      MixerEngine.init(reactContext)
      MixerEngine.listeners.add(engineListener)
      // Binding a controller creates the MediaSessionService; Media3 promotes it to a
      // foreground service with a media notification whenever the mix is playing.
      controllerFuture =
          MediaController.Builder(
                  reactContext,
                  SessionToken(
                      reactContext, ComponentName(reactContext, MixerPlaybackService::class.java)))
              .buildAsync()
    }
  }

  override fun getName() = NAME

  override fun invalidate() {
    main.post {
      MixerEngine.listeners.remove(engineListener)
      controllerFuture?.let { MediaController.releaseFuture(it) }
      controllerFuture = null
    }
    super.invalidate()
  }

  @ReactMethod
  fun load(id: String, fileName: String, title: String, volume: Double) {
    main.post { MixerEngine.load(id, fileName, title, volume.toFloat()) }
  }

  @ReactMethod fun play(id: String) = post { MixerEngine.play(id) }

  @ReactMethod fun pause(id: String) = post { MixerEngine.pause(id) }

  @ReactMethod fun remove(id: String) = post { MixerEngine.remove(id) }

  @ReactMethod
  fun setVolume(id: String, volume: Double) = post { MixerEngine.setVolume(id, volume.toFloat()) }

  @ReactMethod
  fun setMasterVolume(volume: Double) = post { MixerEngine.setMasterVolume(volume.toFloat()) }

  /** Live slider updates: change the audio without emitting state (no JS re-render per move). */
  @ReactMethod
  fun setVolumeQuiet(id: String, volume: Double) = post { MixerEngine.setVolume(id, volume.toFloat(), false) }

  @ReactMethod
  fun setMasterVolumeQuiet(volume: Double) = post { MixerEngine.setMasterVolume(volume.toFloat(), false) }

  @ReactMethod
  fun setFadeConfig(enabled: Boolean, fadeInSeconds: Double, fadeOutSeconds: Double) = post {
    MixerEngine.setFadeConfig(enabled, fadeInSeconds.toInt(), fadeOutSeconds.toInt())
  }

  @ReactMethod fun pauseAll() = post { MixerEngine.pauseAll() }

  @ReactMethod fun resumeAll() = post { MixerEngine.resumeAll() }

  @ReactMethod fun stopAll() = post { MixerEngine.stopAll() }

  @ReactMethod fun setSleepTimer(minutes: Double) = post { MixerEngine.setSleepTimer(minutes.toInt()) }

  @ReactMethod
  fun getState(promise: Promise) {
    main.post { promise.resolve(buildState()) }
  }

  /** App version + whether data from the previous (Flutter) build of the app is on the device. */
  @ReactMethod
  fun getAppInfo(promise: Promise) {
    try {
      val info = reactContext.packageManager.getPackageInfo(reactContext.packageName, 0)
      val versionCode =
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) info.longVersionCode
          else @Suppress("DEPRECATION") info.versionCode.toLong()
      val flutterDir = File(reactContext.applicationInfo.dataDir, "app_flutter")
      val map = Arguments.createMap()
      map.putString("version", info.versionName ?: "")
      map.putString("buildNumber", versionCode.toString())
      map.putBoolean(
          "hasLegacyFlutterData",
          File(flutterDir, "settings.hive").exists() || File(flutterDir, "sounds.hive").exists())
      promise.resolve(map)
    } catch (e: Exception) {
      promise.reject("app_info", e)
    }
  }

  /** Light system haptics that respect the user's touch-feedback setting. */
  @ReactMethod
  fun haptic(kind: String) = post {
    val view = reactContext.currentActivity?.window?.decorView ?: return@post
    val constant =
        when (kind) {
          "confirm" ->
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) HapticFeedbackConstants.CONFIRM
              else HapticFeedbackConstants.VIRTUAL_KEY
          "tick" -> HapticFeedbackConstants.CLOCK_TICK
          else -> HapticFeedbackConstants.KEYBOARD_TAP
        }
    view.performHapticFeedback(constant)
  }

  // Required by NativeEventEmitter.
  @ReactMethod fun addListener(eventName: String) {}

  @ReactMethod fun removeListeners(count: Double) {}

  private fun post(block: () -> Unit) {
    main.post(block)
  }

  private fun emitState() {
    if (!reactContext.hasActiveReactInstance()) return
    reactContext
        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
        .emit(EVENT, buildState())
  }

  private fun buildState(): WritableMap {
    val map = Arguments.createMap()
    val tracks = Arguments.createArray()
    for (track in MixerEngine.tracksSnapshot()) {
      val t = Arguments.createMap()
      t.putString("id", track.id)
      t.putBoolean("playing", track.playing)
      t.putDouble("volume", track.volume.toDouble())
      tracks.pushMap(t)
    }
    map.putArray("tracks", tracks)
    map.putBoolean("isMasterPlaying", MixerEngine.isMasterPlaying)
    map.putDouble("masterVolume", MixerEngine.masterVolume.toDouble())
    map.putInt("sleepTimerMinutes", MixerEngine.sleepTimerMinutes)
    map.putDouble("sleepTimerEndsAt", MixerEngine.sleepTimerEndsAt.toDouble())
    return map
  }

  companion object {
    const val NAME = "ArcadiaMixer"
    const val EVENT = "ArcadiaMixerState"
  }
}
