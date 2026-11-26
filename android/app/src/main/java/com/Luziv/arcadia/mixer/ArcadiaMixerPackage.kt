package com.Luziv.arcadia.mixer

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

class ArcadiaMixerPackage : ReactPackage {
  override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> =
      listOf(ArcadiaMixerModule(reactContext))

  override fun createViewManagers(
      reactContext: ReactApplicationContext
  ): List<ViewManager<*, *>> = emptyList()
}
