package com.Luziv.arcadia.glass

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.views.view.ReactViewGroup
import com.facebook.react.views.view.ReactViewManager

/** <ArcadiaGlassBackdrop>: a regular RN View whose children glass surfaces can sample. */
class GlassBackdropManager : ReactViewManager() {
  override fun getName() = "ArcadiaGlassBackdrop"

  override fun createViewInstance(context: ThemedReactContext): ReactViewGroup = GlassBackdropView(context)

  @ReactProp(name = "backdropId")
  fun setBackdropId(view: ReactViewGroup, id: String?) {
    (view as GlassBackdropView).backdropId = id
  }
}

/** <ArcadiaLiquidGlass>: a regular RN View rendered as a Liquid Glass surface. */
class LiquidGlassManager : ReactViewManager() {
  override fun getName() = "ArcadiaLiquidGlass"

  override fun createViewInstance(context: ThemedReactContext): ReactViewGroup = LiquidGlassView(context)

  private fun ReactViewGroup.glass() = this as LiquidGlassView

  @ReactProp(name = "backdropId")
  fun setBackdropId(view: ReactViewGroup, v: String?) { view.glass().backdropId = v }

  @ReactProp(name = "glassMode")
  fun setGlassMode(view: ReactViewGroup, v: String?) {
    view.glass().mode =
        when (v) {
          "frosted" -> LiquidGlassView.Mode.FROSTED
          "solid" -> LiquidGlassView.Mode.SOLID
          else -> LiquidGlassView.Mode.LIQUID
        }
  }

  @ReactProp(name = "cornerRadius", defaultFloat = 24f)
  fun setCornerRadius(view: ReactViewGroup, v: Float) { view.glass().cornerRadiusDp = v }

  @ReactProp(name = "tintColor", customType = "Color")
  fun setTintColor(view: ReactViewGroup, v: Int?) { v?.let { view.glass().tintColor = it } }

  @ReactProp(name = "solidColor", customType = "Color")
  fun setSolidColor(view: ReactViewGroup, v: Int?) { v?.let { view.glass().materialColor = it } }

  @ReactProp(name = "saturation", defaultFloat = 1.5f)
  fun setSaturation(view: ReactViewGroup, v: Float) { view.glass().saturation = v }

  @ReactProp(name = "exportId")
  fun setExportId(view: ReactViewGroup, v: String?) { view.glass().exportId = v }

  @ReactProp(name = "innerShadowOpacity", defaultFloat = 0f)
  fun setInnerShadowOpacity(view: ReactViewGroup, v: Float) { view.glass().innerShadowOpacity = v }

  @ReactProp(name = "brightness", defaultFloat = 0f)
  fun setBrightness(view: ReactViewGroup, v: Float) { view.glass().brightness = v }

  @ReactProp(name = "rimWidth", defaultFloat = 0.5f)
  fun setRimWidth(view: ReactViewGroup, v: Float) { view.glass().rimWidthDp = v }

  @ReactProp(name = "blurRadius", defaultFloat = 8f)
  fun setBlurRadius(view: ReactViewGroup, v: Float) { view.glass().blurRadiusDp = v }

  @ReactProp(name = "lensHeight", defaultFloat = 24f)
  fun setLensHeight(view: ReactViewGroup, v: Float) { view.glass().lensHeightDp = v }

  @ReactProp(name = "lensAmount", defaultFloat = 24f)
  fun setLensAmount(view: ReactViewGroup, v: Float) { view.glass().lensAmountDp = v }

  @ReactProp(name = "chromaticAberration", defaultBoolean = true)
  fun setChromaticAberration(view: ReactViewGroup, v: Boolean) { view.glass().chromaticAberration = v }

  @ReactProp(name = "resolutionScale", defaultFloat = 0.33f)
  fun setResolutionScale(view: ReactViewGroup, v: Float) { view.glass().resolutionScale = v }

  @ReactProp(name = "highlightOpacity", defaultFloat = 0.5f)
  fun setHighlightOpacity(view: ReactViewGroup, v: Float) { view.glass().highlightOpacity = v }

  @ReactProp(name = "shadowOpacity", defaultFloat = 0.1f)
  fun setShadowOpacity(view: ReactViewGroup, v: Float) { view.glass().shadowOpacity = v }
}

class GlassPackage : ReactPackage {
  override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> = emptyList()

  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> =
      listOf(GlassBackdropManager(), LiquidGlassManager())
}
