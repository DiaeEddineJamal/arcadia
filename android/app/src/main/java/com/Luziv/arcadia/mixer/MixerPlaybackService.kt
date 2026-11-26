package com.Luziv.arcadia.mixer

import android.app.PendingIntent
import android.content.Intent
import android.os.Bundle
import android.os.Looper
import androidx.media3.session.CommandButton
import androidx.media3.session.DefaultMediaNotificationProvider
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService
import androidx.media3.session.SessionCommand
import androidx.media3.session.SessionResult
import com.Luziv.arcadia.MainActivity
import com.Luziv.arcadia.R
import com.google.common.collect.ImmutableList
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture

/**
 * Foreground media service: keeps the mix playing in the background and shows the media
 * notification with play/pause and stop controls (notification channel "Arcadia Audio",
 * like the Flutter `audio_service` configuration).
 */
class MixerPlaybackService : MediaSessionService() {

  private var session: MediaSession? = null

  override fun onCreate() {
    super.onCreate()
    MixerEngine.init(this)
    setMediaNotificationProvider(
        DefaultMediaNotificationProvider.Builder(this)
            .setChannelId("arcadia_audio")
            .setChannelName(R.string.notification_channel_name)
            .build()
            .apply { setSmallIcon(R.drawable.ic_stat_arcadia) })

    val openApp =
        PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

    val stopButton =
        CommandButton.Builder(CommandButton.ICON_STOP)
            .setDisplayName("Stop")
            .setSessionCommand(STOP_COMMAND)
            .build()

    session =
        MediaSession.Builder(this, MixerSessionPlayer(Looper.getMainLooper()))
            .setSessionActivity(openApp)
            .setMediaButtonPreferences(ImmutableList.of(stopButton))
            .setCallback(
                object : MediaSession.Callback {
                  override fun onConnect(
                      session: MediaSession,
                      controller: MediaSession.ControllerInfo
                  ): MediaSession.ConnectionResult =
                      MediaSession.ConnectionResult.AcceptedResultBuilder(session)
                          .setAvailableSessionCommands(
                              MediaSession.ConnectionResult.DEFAULT_SESSION_COMMANDS.buildUpon()
                                  .add(STOP_COMMAND)
                                  .build())
                          .build()

                  override fun onCustomCommand(
                      session: MediaSession,
                      controller: MediaSession.ControllerInfo,
                      customCommand: SessionCommand,
                      args: Bundle
                  ): ListenableFuture<SessionResult> {
                    if (customCommand.customAction == STOP_ACTION) {
                      MixerEngine.stopAll()
                    }
                    return Futures.immediateFuture(SessionResult(SessionResult.RESULT_SUCCESS))
                  }
                })
            .build()
  }

  override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaSession? = session

  /** Same as `android:stopWithTask="true"` in the Flutter app: swiping the app away stops audio. */
  override fun onTaskRemoved(rootIntent: Intent?) {
    MixerEngine.stopAll()
    stopSelf()
  }

  override fun onDestroy() {
    session?.run {
      player.release()
      release()
    }
    session = null
    super.onDestroy()
  }

  companion object {
    private const val STOP_ACTION = "arcadia.STOP"
    private val STOP_COMMAND = SessionCommand(STOP_ACTION, Bundle.EMPTY)
  }
}
