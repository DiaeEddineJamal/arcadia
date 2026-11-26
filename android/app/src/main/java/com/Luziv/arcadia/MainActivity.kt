package com.Luziv.arcadia

import android.os.Build
import android.os.Bundle
import android.view.Display
import com.facebook.react.ReactActivity
import com.facebook.react.ReactActivityDelegate
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.fabricEnabled
import com.facebook.react.defaults.DefaultReactActivityDelegate

class MainActivity : ReactActivity() {

  override fun getMainComponentName(): String = "Arcadia"

  override fun createReactActivityDelegate(): ReactActivityDelegate =
      DefaultReactActivityDelegate(this, mainComponentName, fabricEnabled)

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    preferHighestRefreshRate()
  }

  override fun onResume() {
    super.onResume()
    // Some devices reset the display mode when the app goes to the background.
    preferHighestRefreshRate()
  }

  /**
   * Port of the Flutter app's `FlutterDisplayMode.setHighRefreshRate()`: pick the display mode
   * with the highest refresh rate at the current resolution and ask the window to use it.
   */
  private fun preferHighestRefreshRate() {
    try {
      @Suppress("DEPRECATION")
      val display: Display =
          (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display else windowManager.defaultDisplay)
              ?: return
      val current = display.mode
      val best =
          display.supportedModes
              .filter {
                it.physicalWidth == current.physicalWidth &&
                    it.physicalHeight == current.physicalHeight
              }
              .maxByOrNull { it.refreshRate } ?: return
      val params = window.attributes
      if (params.preferredDisplayModeId != best.modeId) {
        params.preferredDisplayModeId = best.modeId
        window.attributes = params
      }
    } catch (_: Exception) {
      // Display mode changes are best effort only.
    }
  }
}
