package com.Luziv.arcadia.glass

import android.content.Context
import android.graphics.Canvas
import android.graphics.RenderNode
import android.os.Build
import android.view.View
import com.facebook.react.views.view.ReactViewGroup
import java.lang.ref.WeakReference

/**
 * The content that Liquid Glass surfaces sample ("the backdrop").
 *
 * Its children (the scene video, imagery and page content behind the floating controls) are
 * recorded once per frame into a single [RenderNode]; every [LiquidGlassView] that names this
 * backdrop redraws that same display list through its own effect chain. Nothing is read back to
 * the CPU and the scene is never re-rendered per glass element — the GPU replays one display list.
 * Video must be a TextureView (not a SurfaceView) for its frames to be part of the display list.
 */
class GlassBackdropView(context: Context) : ReactViewGroup(context), GlassSource {

  internal val node: RenderNode? =
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) RenderNode("ArcadiaGlassBackdrop") else null

  /** True once the node holds a recording that glass surfaces may draw. */
  internal var hasRecording = false
    private set

  override val sourceNode: RenderNode?
    get() = node
  override val sourceReady: Boolean
    get() = hasRecording
  override val sourceView: View
    get() = this
  override val recordsDescendants = true

  var backdropId: String? = null
    set(value) {
      field?.let { GlassRegistry.unregister(it, this) }
      field = value
      if (isAttachedToWindow) value?.let { GlassRegistry.register(it, this) }
    }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    backdropId?.let { GlassRegistry.register(it, this) }
  }

  override fun onDetachedFromWindow() {
    backdropId?.let { GlassRegistry.unregister(it, this) }
    hasRecording = false
    super.onDetachedFromWindow()
  }

  override fun dispatchDraw(canvas: Canvas) {
    val node = node
    if (node == null || !canvas.isHardwareAccelerated || width == 0 || height == 0) {
      hasRecording = false
      super.dispatchDraw(canvas)
      return
    }
    node.setPosition(0, 0, width, height)
    val recording = node.beginRecording(width, height)
    try {
      super.dispatchDraw(recording)
    } finally {
      node.endRecording()
    }
    hasRecording = true
    canvas.drawRenderNode(node)
    // Glass surfaces redraw the node directly, so a new recording reaches them without them
    // re-recording; they only need a nudge the first time a recording becomes available.
    GlassRegistry.onSourceRecorded()
  }
}

/** Anything a glass surface can sample: a backdrop container, or another glass surface's output. */
internal interface GlassSource {
  val sourceNode: RenderNode?
  val sourceReady: Boolean
  val sourceView: View
  /** True when the node contains the source's descendants (a surface inside it must not sample it). */
  val recordsDescendants: Boolean
}

internal object GlassRegistry {
  private val sources = HashMap<String, WeakReference<GlassSource>>()
  private val waiting = HashSet<WeakReference<LiquidGlassView>>()

  fun register(id: String, source: GlassSource) {
    sources[id] = WeakReference(source)
  }

  fun unregister(id: String, source: GlassSource) {
    if (sources[id]?.get() === source) sources.remove(id)
  }

  fun find(id: String?): GlassSource? = id?.let { sources[it]?.get() }

  fun waitFor(view: LiquidGlassView) {
    waiting.add(WeakReference(view))
  }

  fun onSourceRecorded() {
    if (waiting.isEmpty()) return
    val pending = waiting.toList()
    waiting.clear()
    pending.forEach { ref -> ref.get()?.takeIf { it.isAttachedToWindow }?.postInvalidateOnAnimation() }
  }
}
