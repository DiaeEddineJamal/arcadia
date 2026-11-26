# Liquid Glass in Arcadia

Arcadia's floating controls (tab bar and its selection pill, transport, mini player, timer chip,
sheets, dialog, toast) are rendered as an optical material that samples and bends the scene behind
them. This is a native renderer, not a blur view with a border.

## Pipeline (Android)

```
GlassBackdropView                 LiquidGlassView (one per surface)
──────────────────                ──────────────────────────────────────────────────────────
children (scene video on a        1. shadow: blurred rounded rect, drawn outside the shape only
TextureView, still, scrims,       2. effect RenderNode, recorded at 0.33× resolution:
current page) recorded each          drawRenderNode(backdrop) translated to this surface's
frame into ONE RenderNode,           window offset, with padding for the blur
then drawn normally.                 RenderEffect chain: saturation 1.5 → blur 8 dp → AGSL lens
                                  3. surface tint (material colour, ~34–58% opacity)
      │                           4. children (icons, text), clipped to the shape
      └──── shared by every ────▶ 5. rim light: 1 dp stroke, AGSL directional highlight,
            glass surface            additive (PLUS) blend, 0.25 dp blur
```

- **Backdrop capture:** `GlassBackdropView.dispatchDraw` records its children into a single
  `RenderNode` per frame and draws it. Glass surfaces replay that node, so the scene is never
  rendered twice and nothing is read back to the CPU.
- **Video must be a TextureView.** react-native-video 6.19.3 ignores `viewType` on Android
  (`ExoPlayerView.updateSurfaceView` is a TODO) and always uses a SurfaceView, which is
  composited outside the app: glass can't sample it, and opacity, clipping and blur don't apply.
  The app patches the library to inflate its PlayerView with `app:surface_type="texture_view"`
  (see README, "Patched dependency"). With the patch, glass refracts the moving video.
- **Refraction:** the lens is an AGSL `RuntimeShader` run as a `RenderEffect`. Within the "lens
  height" of the edge, it displaces sampling along the rounded-rectangle SDF gradient, following a
  circular profile, with optional depth bias and seven-tap chromatic dispersion. The program comes
  from Kyant0/backdrop (Apache-2.0); see `GlassShaders.kt` and `THIRD_PARTY_NOTICES.md`.
- **Highlight:** an AGSL program weights the rim by how much the edge normal faces a 45° light,
  so the top-left and bottom-right edges catch the light the way the reference does.
- **Motion:** each surface listens for pre-draw and re-records only when its offset relative to
  the backdrop changes (scrolling, the sliding tab pill, sheet animation). Changes inside the
  backdrop reach the glass automatically, because it replays the same node.
- **Clipping:** a surface never samples a backdrop that contains it (that would recurse). Such a
  surface falls back to a solid material.
- **Nested glass (export):** a surface with `exportId` publishes its rendered glass (sampled,
  blurred, tinted backdrop, without rim, shadow or children) as a source. Glass placed on top of
  it, such as the tab pill, the mini player's play button, timer buttons on the sheet or Continue in
  the onboarding dock, refracts that glass rather than the scene. This is BitChord's exported
  backdrop for its selection pill, implemented independently.
- **Inner shadow:** a soft crescent inside the top edge (filled shape minus an offset copy,
  blurred) gives controls thickness, after Kyant0/backdrop's InnerShadow.
- **Sliders:** each level bar draws its track and fill into its own small backdrop, and a clear
  `lens` glass knob rides on the fill's edge. It magnifies and bends the boundary and the text
  under it, and grows while dragging, like iOS 26 sliders.

## Calibration and where glass is used

Glass is deliberately rare. As in BitChord, it is used only for navigation and for controls that
float directly over footage:

- tab bar and its selected-tab pill
- the round sleep-timer and mix controls on the scene, and the timer chip
- onboarding: the control dock and the playback-notification preview

Everything else is a solid surface (`Surface` in `src/glass`): sheets, the dialog, the mini
player, toasts, and the solid paper play button. Values are BitChord's own:

| | Clear (`clear`) | Selected pill (`lift`) | BitChord |
| --- | --- | --- | --- |
| Saturation (vibrancy 1.0) | 1.5 | 1.5 | 1.5 |
| Blur | 8 dp | 4 dp | 8 dp |
| Lens height / amount | 24 / 24 dp | 16 / 20 dp | 24 / 24 dp (0.5 × 48) |
| Tint | #121212 @ 40% | white @ 14% | #121212 @ 40%, indicator white @ 14% |
| Resolution scale | 0.33 | 0.33 | 0.33 |
| Rim | 0.5 dp, white 50% | 0.5 dp, white 50% | 0.5 dp, white 50% |
| Shadow | black 10% | none | black 10% |

The native view also supports a luminance lift and rim width (`brightness`, `rimWidth`). Both are
left at BitChord's neutral values.

## Tiers and fallbacks

| Tier | When | What renders |
| --- | --- | --- |
| Liquid | Android 13+ (API 33), Settings → Glass → Liquid | saturation → blur → lens + dispersion, rim shader |
| Frosted | Android 12 (API 31–32), or Settings → Glass → Frosted | saturation → 16 dp blur at 0.25×, no lens; rim shader on 33+ |
| Solid | Android ≤ 11, Settings → Glass → Solid, no backdrop available yet | opaque material, 0.5 dp hairline at 10% white |
| iOS (all) | native glass not implemented yet | Solid |

Settings → Glass is the user-facing quality and accessibility switch. "Solid" is the
reduced-transparency option. Android has no system reduce-transparency flag, so this is explicit.
Reduce Motion (system animator scale) freezes the scene to its still, removes spring motion and
shortens transitions to fades.

## Cost

- One backdrop recording per frame (a display list, not pixels).
- Each surface processes about 11% of its own pixels (0.33²) through colour, blur and lens, or
  about 6% when frosted. On screen at once: three or four small surfaces.
- AGSL programs compile once per surface instance. Effects are rebuilt only when size or
  parameters change, not per frame.
- Audio runs in its own Media3 service and is unaffected by rendering.

## Using it

```tsx
import { Glass, GlassBackdrop } from './src/glass';

<GlassBackdrop id="scene" style={StyleSheet.absoluteFill}>{/* scene + page */}</GlassBackdrop>
<Glass radius={32} material="clear" style={{ height: 64 }}>{/* controls */}</Glass>
```

`material`: `clear` | `regular` | `lift`. The `lens` prop scales refraction, for example to
strengthen it while pressed. Rendering quality comes from `GlassQualityProvider`, which is wired to
Settings.

## iOS (not done)

iOS 26 ships Liquid Glass natively (`UIGlassEffect` / SwiftUI `.glassEffect()`). The right
implementation is a small native view wrapping `UIVisualEffectView(effect: UIGlassEffect())`
behind the same `<Glass>` API, falling back to `UIBlurEffect(.systemThinMaterialDark)` before iOS
26. It wasn't built because this machine can't compile iOS. Until then iOS uses the Solid tier.
