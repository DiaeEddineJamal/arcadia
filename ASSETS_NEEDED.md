# Assets needed for the redesign

The redesign is built so that the scene carries the experience. Today it only has one forest clip
(`main_animated.mp4`), its still (`static_main.jpg`) and four abstract onboarding clips. Below is
what would make each part of the app feel like a real place, with prompts you can give ChatGPT.

> A note on authenticity: the design brief prefers real, licensed photography and footage over
> generated imagery. Generated stills are fine to explore the look, but for release, filmed loops
> (your own, or licensed from a stock library with a commercial licence) will read as more
> believable. Wherever a prompt below is used, check the result for the usual tells: impossible
> light, mushy foliage, repeated textures, oversaturated colour.

## 1. App icon — painted on canvas

Deliverables (same artwork, exported at these sizes):

| File | Size | Notes |
| --- | --- | --- |
| `icon-1024.png` | 1024 × 1024 | iOS App Store, **no transparency**, square (iOS rounds it) |
| `play-512.png` | 512 × 512 | Google Play listing |
| `adaptive-foreground.png` | 432 × 432 | Android adaptive icon foreground, transparent background, motif inside the central 264 × 264 safe zone |
| `adaptive-background.png` | 432 × 432 | Android adaptive icon background (the canvas texture/colour only) |
| `notification-icon.png` | 96 × 96 | Single-colour white silhouette on transparent, for the playback notification |

Prompt:

```
An app icon that looks like a small oil painting on stretched linen canvas, seen straight on and
filling a square. The subject is a quiet Arcadian landscape reduced to a few shapes: one solitary
broad tree on a gentle hill at dusk, a pale band of sky, low mist in the valley. Painted with
visible, confident brushstrokes and a slightly dry brush so the canvas weave shows through in the
lighter areas. Muted, natural palette: deep moss and olive greens, warm umber earth, a soft
sand-coloured sky with a hint of ember near the horizon. Gentle, painterly edges, no hard outlines.
No text, no letters, no border, no frame, no drop shadow, no gloss, no 3D effect, no gradients
that look digital. The composition must read clearly at 48 pixels: a strong silhouette of the tree
against the lighter sky, centred, with generous margin around it. Square 1024×1024.
```

Follow-up prompt for the adaptive layers:

```
Using the same painting, give me two separate square 432×432 images: (1) only the tree and hill
on a fully transparent background, kept within the central 264×264 area; (2) only the painted sky
and canvas texture, filling the whole square, with no tree.
```

Follow-up prompt for the notification icon:

```
Make a flat, single-colour white silhouette of just the tree and hill from that painting on a
transparent background, 96×96, no texture, no gradients, readable at 24 pixels.
```

## 2. One still per place (Sounds tab and scene)

Used as the scene when a category's sounds lead the mix, and as the backdrop for that section.
Portrait **1080 × 2340** JPEG, about 300–500 KB each. Keep the lower third calm and darker: that
is where the title and controls sit.

Shared style line to append to every prompt:

```
Photographic, shot on a full-frame camera with a natural lens, real natural light, believable
colour, gentle contrast, no people, no text, no watermark, not oversaturated, not HDR, no lens
flares, no fantasy glow. Vertical 9:19.5 composition with the subject in the upper two thirds and
a calm, darker lower third.
```

| File | Prompt |
| --- | --- |
| `scene-rain.jpg` | Steady rain on a window at blue hour, a blurred forest beyond the glass, water beading and running down. |
| `scene-wind.jpg` | Tall dry grass on a hillside bending in strong wind under a low grey sky, late afternoon. |
| `scene-ocean.jpg` | A quiet grey-blue sea meeting a pebble beach at dawn, small waves, wide horizon, soft overcast light. |
| `scene-forest.jpg` | Inside an old beech forest in early summer, soft light through the canopy, a moss-covered floor. |
| `scene-fire.jpg` | A wood fire burning low in a stone fireplace in a dark room, warm light on the hearth, nothing else lit. |
| `scene-indoors.jpg` | A quiet reading room in a library at dusk, warm lamps, rows of books, empty chairs, slightly out of focus. |
| `scene-noise.jpg` | Thick morning fog over a flat field with a single line of distant trees, almost monochrome. |
| `scene-fantasy.jpg` | The interior of an old timber tavern at night lit only by candles and a hearth, empty tables, worn wood. |

## 3. Optional, for a richer Listen scene

Seamless 10–20 s loops (H.264, 1080 × 1920, about 3–6 MB each) of the same eight places. ChatGPT
cannot make these. Film them or license them, and match each still above. They plug in where
`main_animated.mp4` is used today.

## 4. Content to review (not an asset request)

- **`pirates.mp3`**: the Flutter app listed it as "Pirates of the Caribbean". That is a film
  title, and if the recording is the film's score it cannot ship without a licence. The redesign
  displays it as "Pirate Ship". Please confirm what the recording is and its licence.
- **`tavern.mp3` is 92 MB**, which is most of the app's download size. A 3–5 minute seamless
  loop at 128 kbps (about 3–5 MB) would sound the same in the mixer.
