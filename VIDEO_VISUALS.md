# Listen scene visuals

The Listen clips are free stock footage from Pexels; which clip each place uses, where it came
from and how to replace one is in [VIDEO_SOURCES.md](VIDEO_SOURCES.md). (The Pinterest
placeholders used during design were removed on 2026-11-26.)

## Which video plays when several sounds are mixed

Implemented in `src/state/useSceneLead.ts`. The rule: **the place you are in, with the
weather around it.**

1. Each category gets a tier:
   - **Setting:** Café, Library, Tavern, Pirate Ship, Fireplace
   - **Landscape:** Ocean, Forest, Wind
   - **Weather:** Light Rain, Heavy Rain, Thunder
   - **Texture:** White / Pink / Brown Noise
2. The highest tier present leads. Rain + Café → the café. Rain + Fireplace → the fire. Rain + Forest → the forest.
3. Within a tier, the loudest layer leads (volume × playing). Ties go to the most recently added.
4. Hysteresis, so the scene doesn't flicker as you drag sliders: a new leader takes over only when
   it has been ahead for ~2 s, then the videos crossfade over ~1.5 s.
5. Noise leads only when nothing else is playing.

Optional later: a few hand-made combination scenes (Rain + Café → a rainy café window, Rain + Fireplace → a fire with a rainy window) where a real clip exists.

---

## Progressive blur (baked into the clips)

Listen copies BitChord's player: the footage is sharp at the top and softly blurred behind the
title and controls. Each scene clip ships in two cuts, `*-sharp.mp4` (the original) and
`*-blur.mp4` (the same clip re-encoded with the blur in the picture). Both play together; in
immersive mode the blurred cut slides down out of view, leaving the sharp video. The blurred cut:

- 0–40% of the height: untouched.
- 40–56%: blends to a light blur; 54–72%: blends to a heavy blur, which holds to the bottom.
- H.264, CRF 20, no audio, same size and frame rate as the source.

All clips are taller than wide enough that the phone shows their full height (cover-fit crops only
the sides), so the ramp lines up with the screen. Replacement clips go through `scripts/prepare-scene-clip.py`.

## Immersive mode (BitChord)

A tap on the scene (not on a control), or 6 s without a touch while sound plays on Listen,
switches to immersive: in ~0.3 s (ease-out) the blur lifts, the title drops to the foot of the
screen and the controls and tab bar slide down off the screen with it. Another tap, or Back,
reverses it. With Reduce Motion only the fade runs.

## One clock per clip

Copies of a clip (the scene's sharp and blurred cuts, the mini player's thumbnail, the transition's
flying clip) all start at the scene's current frame and correct drift above ~0.1 s, so they hand
over without a jump (BitChord resumes its canvas from the frame on screen the same way). The
mini player shows the live clip; opening it flies that clip to full screen on a critically damped
spring (stiffness 195, as BitChord), then swaps for the scene, which is on the same frame.
