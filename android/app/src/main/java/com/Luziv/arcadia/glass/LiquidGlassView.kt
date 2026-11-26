package com.Luziv.arcadia.glass

import android.content.Context
import android.graphics.BlendMode
import android.graphics.BlurMaskFilter
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.RenderEffect
import android.graphics.RenderNode
import android.graphics.RuntimeShader
import android.graphics.Shader
import android.os.Build
import android.view.View
import android.view.ViewTreeObserver
import com.facebook.react.views.view.ReactViewGroup
import kotlin.math.ceil
import kotlin.math.min

/**
 * A Liquid Glass surface: samples the named [GlassBackdropView] behind it and renders it through
 * vibrancy (saturation), blur and a lens refraction shader with chromatic dispersion, then the
 * surface tint, the children, and a directional rim highlight. A soft drop shadow is drawn
 * outside the shape only.
 *
 * Rendering tiers (resolved every frame, so a setting change takes effect immediately):
 *  - LIQUID   (API 33+): saturation → blur → lens (RuntimeShader/AGSL), backdrop at [resolutionScale].
 *  - FROSTED  (API 31+, or LIQUID requested below API 33, or "performance" mode): saturation → wider
 *             blur at quarter resolution, no lens.
 *  - SOLID    (API < 31, reduced transparency, or no backdrop available): opaque material + hairline.
 *
 * Calibration follows the BitChord/Kyant0 baseline: vibrancy 1.0 (saturation 1.5), blur 8 dp,
 * lens height = lens amount = 0.5 × 48 dp, surface opacity 0.4, resolution 0.33, rim 0.5 dp.
 */
class LiquidGlassView(context: Context) : ReactViewGroup(context), GlassSource {

  enum class Mode { LIQUID, FROSTED, SOLID }

  private val density = resources.displayMetrics.density
  private fun dp(v: Float) = v * density

  // ---- props (dp where relevant) ----
  var backdropId: String? = null
    set(v) { field = v; markDirty() }
  var mode = Mode.LIQUID
    set(v) { field = v; markDirty() }
  var cornerRadiusDp = 24f
    set(v) { field = v; markDirty() }
  var tintColor = Color.argb(0.4f, 0.07f, 0.07f, 0.07f)
    set(v) { field = v; invalidate() }
  var materialColor = Color.argb(0.96f, 0.09f, 0.10f, 0.09f)
    set(v) { field = v; invalidate() }
  var saturation = 1.5f
    set(v) { field = v; markDirty() }
  /** Luminance lift applied to the sampled backdrop (0 = none), as glass gathers light. */
  var brightness = 0f
    set(v) { field = v; markDirty() }
  var rimWidthDp = 0.5f
    set(v) { field = v; invalidate() }
  var blurRadiusDp = 8f
    set(v) { field = v; markDirty() }
  var lensHeightDp = 24f
    set(v) { field = v; markDirty() }
  var lensAmountDp = 24f
    set(v) { field = v; markDirty() }
  var chromaticAberration = true
    set(v) { field = v; markDirty() }
  var depthEffect = true
    set(v) { field = v; markDirty() }
  var resolutionScale = 0.33f
    set(v) { field = v.coerceIn(0.1f, 1f); markDirty() }
  var highlightOpacity = 0.5f
    set(v) { field = v; invalidate() }
  var highlightAngleDeg = 45f
    set(v) { field = v; invalidate() }
  var shadowOpacity = 0.1f
    set(v) { field = v; shadowDirty = true; invalidate() }
  var edgeOpacity = 0.10f
    set(v) { field = v; invalidate() }
  /** Kyant-style inner shadow: a soft crescent inside the top edge that gives the glass thickness. */
  var innerShadowOpacity = 0f
    set(v) { field = v; innerDirty = true; invalidate() }
  /**
   * When set, this surface publishes its rendered glass (sampled, blurred, tinted backdrop,
   * without rim, shadow or children) under this id, so glass placed on top of it refracts the
   * glass itself, like the exported backdrop BitChord uses for its tab pill.
   */
  var exportId: String? = null
    set(v) {
      field?.let { GlassRegistry.unregister(it, this) }
      field = v
      if (isAttachedToWindow) v?.let { GlassRegistry.register(it, this) }
    }

  // ---- rendering state ----
  private val supportsNodes = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
  private val effectNode: RenderNode? = if (supportsNodes) RenderNode("ArcadiaGlass") else null
  private val shadowNode: RenderNode? = if (supportsNodes) RenderNode("ArcadiaGlassShadow") else null
  private var refractionShader: Any? = null // RuntimeShader on API 33+
  private var highlightShader: Any? = null // RuntimeShader on API 33+
  private var effectKey: String? = null
  private var shadowDirty = true
  private var innerDirty = true
  private var innerSize = 0L
  private val innerNode: RenderNode? = if (supportsNodes) RenderNode("ArcadiaGlassInner") else null
  private val exportNode: RenderNode? = if (supportsNodes) RenderNode("ArcadiaGlassExport") else null
  private var exportReady = false

  override val sourceNode: RenderNode?
    get() = exportNode
  override val sourceReady: Boolean
    get() = exportReady
  override val sourceView: View
    get() = this
  override val recordsDescendants = false
  private var shadowSize = 0L

  private val path = Path()
  private val rect = RectF()
  private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG)
  private val edgePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE }
  private val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG)
  private val innerPaint = Paint(Paint.ANTI_ALIAS_FLAG)
  private var lastPad = 0
  private var lastScale = 1f

  private val selfLoc = IntArray(2)
  private val backdropLoc = IntArray(2)
  private var lastOffsetX = Int.MIN_VALUE
  private var lastOffsetY = Int.MIN_VALUE

  /** Re-record when this surface moves relative to its backdrop (scrolls, native-driven motion). */
  private val preDraw =
      ViewTreeObserver.OnPreDrawListener {
        val backdrop = GlassRegistry.find(backdropId)
        if (backdrop != null && currentMode() != Mode.SOLID) {
          getLocationInWindow(selfLoc)
          backdrop.sourceView.getLocationInWindow(backdropLoc)
          val x = selfLoc[0] - backdropLoc[0]
          val y = selfLoc[1] - backdropLoc[1]
          if (x != lastOffsetX || y != lastOffsetY) invalidate()
        }
        true
      }

  init {
    setWillNotDraw(false)
  }

  private fun markDirty() {
    effectKey = null
    invalidate()
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    viewTreeObserver.addOnPreDrawListener(preDraw)
    exportId?.let { GlassRegistry.register(it, this) }
  }

  override fun onDetachedFromWindow() {
    viewTreeObserver.removeOnPreDrawListener(preDraw)
    exportId?.let { GlassRegistry.unregister(it, this) }
    exportReady = false
    super.onDetachedFromWindow()
  }

  override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
    super.onSizeChanged(w, h, oldw, oldh)
    effectKey = null
    shadowDirty = true
    innerDirty = true
  }

  private fun cornerRadiusPx(): Float = min(dp(cornerRadiusDp), min(width, height) / 2f)

  private fun currentMode(): Mode =
      when {
        mode == Mode.SOLID || !supportsNodes -> Mode.SOLID
        mode == Mode.LIQUID && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU -> Mode.FROSTED
        else -> mode
      }

  /** Resolve the tier actually drawable right now. */
  private fun resolveMode(canvas: Canvas, backdrop: GlassSource?): Mode {
    val wanted = currentMode()
    if (wanted == Mode.SOLID) return Mode.SOLID
    if (!canvas.isHardwareAccelerated || backdrop?.sourceNode == null || backdrop === this) return Mode.SOLID
    if (backdrop.recordsDescendants && isInside(backdrop.sourceView)) return Mode.SOLID // would sample itself
    if (!backdrop.sourceReady) {
      GlassRegistry.waitFor(this)
      return Mode.SOLID
    }
    return wanted
  }

  private fun isInside(ancestor: View): Boolean {
    var p = parent
    while (p != null) {
      if (p === ancestor) return true
      p = p.parent
    }
    return false
  }

  override fun dispatchDraw(canvas: Canvas) {
    val w = width
    val h = height
    if (w == 0 || h == 0) return super.dispatchDraw(canvas)

    val radius = cornerRadiusPx()
    rect.set(0f, 0f, w.toFloat(), h.toFloat())
    path.reset()
    path.addRoundRect(rect, radius, radius, Path.Direction.CW)

    val backdrop = GlassRegistry.find(backdropId)
    val tier = resolveMode(canvas, backdrop)

    if (tier == Mode.SOLID) {
      fillPaint.color = materialColor
      fillPaint.shader = null
      canvas.drawRoundRect(rect, radius, radius, fillPaint)
    } else {
      drawShadow(canvas, radius)
      drawBackdrop(canvas, backdrop!!, tier, radius)
      fillPaint.color = tintColor
      fillPaint.shader = null
      canvas.drawRoundRect(rect, radius, radius, fillPaint)
      recordExport(radius)
    }
    drawInnerShadow(canvas, radius)

    canvas.save()
    canvas.clipPath(path)
    super.dispatchDraw(canvas)
    canvas.restore()

    drawRim(canvas, tier, radius)
  }

  private fun drawBackdrop(canvas: Canvas, backdrop: GlassSource, tier: Mode, radius: Float) {
    val node = effectNode ?: return
    val source = backdrop.sourceNode ?: return
    val frosted = tier == Mode.FROSTED
    val scale = if (frosted) 0.25f else resolutionScale
    val blurPx = dp(if (frosted) maxOf(16f, blurRadiusDp) else blurRadiusDp)
    val pad = ceil(blurPx).toInt()

    getLocationInWindow(selfLoc)
    backdrop.sourceView.getLocationInWindow(backdropLoc)
    val offX = selfLoc[0] - backdropLoc[0]
    val offY = selfLoc[1] - backdropLoc[1]
    lastOffsetX = offX
    lastOffsetY = offY
    lastPad = pad
    lastScale = scale

    val nodeW = ceil((width + pad * 2) * scale).toInt().coerceAtLeast(1)
    val nodeH = ceil((height + pad * 2) * scale).toInt().coerceAtLeast(1)
    node.setPosition(0, 0, nodeW, nodeH)

    val key = "$tier|$nodeW|$nodeH|$scale|$blurPx|$saturation|$brightness|$lensHeightDp|$lensAmountDp|$chromaticAberration|$depthEffect|$radius"
    if (key != effectKey) {
      node.setRenderEffect(buildEffect(tier, scale, blurPx, pad, radius))
      effectKey = key
    }

    val recording = node.beginRecording(nodeW, nodeH)
    try {
      recording.scale(scale, scale)
      recording.translate((pad - offX).toFloat(), (pad - offY).toFloat())
      recording.drawRenderNode(source)
    } finally {
      node.endRecording()
    }

    canvas.save()
    canvas.clipPath(path)
    canvas.translate(-pad.toFloat(), -pad.toFloat())
    canvas.scale(1f / scale, 1f / scale)
    canvas.drawRenderNode(node)
    canvas.restore()
  }

  /** Publishes the glass just drawn (backdrop + tint) for surfaces layered on top of this one. */
  private fun recordExport(radius: Float) {
    val export = exportNode ?: return
    val glass = effectNode ?: return
    if (exportId == null) return
    export.setPosition(0, 0, width, height)
    val rc = export.beginRecording(width, height)
    try {
      rc.save()
      rc.clipPath(path)
      rc.save()
      rc.translate(-lastPad.toFloat(), -lastPad.toFloat())
      rc.scale(1f / lastScale, 1f / lastScale)
      rc.drawRenderNode(glass)
      rc.restore()
      fillPaint.color = tintColor
      rc.drawRoundRect(rect, radius, radius, fillPaint)
      rc.restore()
    } finally {
      export.endRecording()
    }
    if (!exportReady) {
      exportReady = true
      GlassRegistry.onSourceRecorded()
    }
  }

  private fun drawInnerShadow(canvas: Canvas, radius: Float) {
    val node = innerNode ?: return
    if (innerShadowOpacity <= 0f) return
    val blur = min(dp(24f), min(width, height) * 0.4f)
    val size = (width.toLong() shl 32) or height.toLong()
    if (innerDirty || size != innerSize) {
      node.setPosition(0, 0, width, height)
      val rc = node.beginRecording(width, height)
      innerPaint.color = Color.argb(innerShadowOpacity, 0f, 0f, 0f)
      innerPaint.blendMode = BlendMode.SRC_OVER
      rc.drawRoundRect(rect, radius, radius, innerPaint)
      rc.translate(0f, blur)
      innerPaint.blendMode = BlendMode.CLEAR
      rc.drawRoundRect(rect, radius, radius, innerPaint)
      node.endRecording()
      node.setRenderEffect(RenderEffect.createBlurEffect(blur / 2f, blur / 2f, Shader.TileMode.DECAL))
      innerDirty = false
      innerSize = size
    }
    canvas.save()
    canvas.clipPath(path)
    canvas.drawRenderNode(node)
    canvas.restore()
  }

  private fun buildEffect(tier: Mode, scale: Float, blurPx: Float, pad: Int, radius: Float): RenderEffect {
    val sat = ColorMatrix().apply { setSaturation(saturation) }
    if (brightness != 0f) {
      val lift = brightness * 255f
      sat.postConcat(
          ColorMatrix(
              floatArrayOf(
                  1f, 0f, 0f, 0f, lift,
                  0f, 1f, 0f, 0f, lift,
                  0f, 0f, 1f, 0f, lift,
                  0f, 0f, 0f, 1f, 0f)))
    }
    val color = RenderEffect.createColorFilterEffect(ColorMatrixColorFilter(sat))
    val blurScaled = blurPx * scale
    val blurred =
        if (blurScaled > 0.01f) RenderEffect.createBlurEffect(blurScaled, blurScaled, color, Shader.TileMode.CLAMP)
        else color
    if (tier != Mode.LIQUID || Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return blurred
    val maxLens = min(width, height) / 2f
    val lensHeight = min(dp(lensHeightDp), maxLens)
    val lensAmount = dp(lensAmountDp)
    if (lensHeight <= 0f || lensAmount <= 0f) return blurred
    val shader = obtainRefractionShader()
    val r = radius * scale
    shader.setFloatUniform("size", width * scale, height * scale)
    shader.setFloatUniform("offset", -pad * scale, -pad * scale)
    shader.setFloatUniform("cornerRadii", r, r, r, r)
    shader.setFloatUniform("refractionHeight", lensHeight * scale)
    shader.setFloatUniform("refractionAmount", -lensAmount * scale)
    shader.setFloatUniform("depthEffect", if (depthEffect) 1f else 0f)
    shader.setFloatUniform("chromaticAberration", if (chromaticAberration) 1f else 0f)
    val lens = RenderEffect.createRuntimeShaderEffect(shader, "content")
    return RenderEffect.createChainEffect(lens, blurred)
  }

  private fun obtainRefractionShader(): RuntimeShader =
      (refractionShader as? RuntimeShader)
          ?: GlassShaderCache.refraction().also { refractionShader = it }

  private fun drawShadow(canvas: Canvas, radius: Float) {
    val node = shadowNode ?: return
    if (shadowOpacity <= 0f) return
    val blur = dp(24f)
    val pad = ceil(blur * 1.5f).toInt()
    val size = (width.toLong() shl 32) or height.toLong()
    if (shadowDirty || size != shadowSize) {
      val nw = width + pad * 2
      val nh = height + pad * 2
      node.setPosition(0, 0, nw, nh)
      val rc = node.beginRecording(nw, nh)
      shadowPaint.color = Color.argb(shadowOpacity, 0f, 0f, 0f)
      rc.drawRoundRect(
          pad.toFloat(), pad + dp(4f), (pad + width).toFloat(), (pad + height) + dp(4f), radius, radius, shadowPaint)
      node.endRecording()
      node.setRenderEffect(RenderEffect.createBlurEffect(blur / 2f, blur / 2f, Shader.TileMode.DECAL))
      shadowDirty = false
      shadowSize = size
    }
    canvas.save()
    canvas.clipOutPath(path)
    canvas.translate(-pad.toFloat(), -pad.toFloat())
    canvas.drawRenderNode(node)
    canvas.restore()
  }

  private fun drawRim(canvas: Canvas, tier: Mode, radius: Float) {
    val stroke = ceil(dp(rimWidthDp))
    if (stroke <= 0f) return
    canvas.save()
    canvas.clipPath(path)
    if (tier == Mode.SOLID) {
      edgePaint.shader = null
      edgePaint.maskFilter = null
      edgePaint.blendMode = BlendMode.SRC_OVER
      edgePaint.strokeWidth = stroke * 2f
      edgePaint.color = Color.argb(edgeOpacity, 1f, 1f, 1f)
    } else {
      edgePaint.strokeWidth = stroke * 2f
      edgePaint.blendMode = BlendMode.PLUS
      edgePaint.maskFilter = BlurMaskFilter(stroke / 2f, BlurMaskFilter.Blur.NORMAL)
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        val shader = (highlightShader as? RuntimeShader) ?: GlassShaderCache.highlight().also { highlightShader = it }
        shader.setFloatUniform("size", width.toFloat(), height.toFloat())
        shader.setFloatUniform("cornerRadii", radius, radius, radius, radius)
        shader.setColorUniform("color", Color.WHITE)
        shader.setFloatUniform("angle", Math.toRadians(highlightAngleDeg.toDouble()).toFloat())
        shader.setFloatUniform("falloff", 1f)
        edgePaint.shader = shader
        edgePaint.color = Color.argb(highlightOpacity, 1f, 1f, 1f)
      } else {
        edgePaint.shader = null
        edgePaint.color = Color.argb(0.38f, 1f, 1f, 1f)
      }
    }
    canvas.drawRoundRect(rect, radius, radius, edgePaint)
    canvas.restore()
  }
}

/** One compiled AGSL program per kind; each surface gets its own instance for its uniforms. */
internal object GlassShaderCache {
  fun refraction(): RuntimeShader = RuntimeShader(GlassShaders.REFRACTION_WITH_DISPERSION)

  fun highlight(): RuntimeShader = RuntimeShader(GlassShaders.HIGHLIGHT)
}
