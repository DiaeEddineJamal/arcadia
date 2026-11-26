# Listen scene video candidates (Pinterest)

Collected 2026-11-25/26. I opened every pin listed here and judged it from its preview frame.
★ = my pick for that sound. Durations are the pin's video length in seconds.

> **Licensing:** Pinterest pins are almost always reposts. Pinterest grants no right to reuse them
> in an app. For each pick, find the original creator or stock source (many are Pexels, Pond5 or
> Storyblocks clips) and license the original, or ask the creator. Don't ship a file downloaded
> from Pinterest. Watermarked pins (TikTok, Picsart) are listed only as references.

## Rain — Light Rain

- ★ [Dark carved window, rain over a tree](https://www.pinterest.com/pin/245375879690927958/) — 7 s, quiet and cinematic
- [Same window, misty rain](https://www.pinterest.com/pin/1548181168129860/) — 7 s, alternate angle of the same scene
- [Bed by a rainy window at night, forest outside](https://www.pinterest.com/pin/17944098510269040/) — 18 s, cosy, deep blue

## Rain — Heavy Rain

- ★ [Misty forest in heavy rain](https://www.pinterest.com/pin/744923594636752438/) — 16 s
- ★ [Cabin in a downpour at night, windows lit](https://www.pinterest.com/pin/729583208429674969/) — 74 s
- [Window onto rainy green hills](https://www.pinterest.com/pin/882001908256108132/) — 7 s (looks partly generated, check)

## Rain — Thunder

- ★ [Lightning over the sea at night](https://www.pinterest.com/pin/579768152070092254/) — 13 s
- [Purple lightning over a city, seen through a window](https://www.pinterest.com/pin/485262928616514861/) — 8 s
- ✗ [Storm, Picsart watermark](https://www.pinterest.com/pin/695313630006987407/) — not usable

## Wind

- ★ [Wheat field at sunset](https://www.pinterest.com/pin/911908624530429974/) — 11 s
- ★ [Grass silhouettes over water at dusk](https://www.pinterest.com/pin/180214422583221076/) — 9 s
- [Ripe wheat swaying against a cloudy sky](https://www.pinterest.com/pin/673077106843097783/) — 14 s (sold as a stock template)
- [Moonlit field under clouds](https://www.pinterest.com/pin/1010354497640590069/) — 8 s

## Ocean — Ocean Waves

- ★ [Aerial dark surf with pines](https://www.pinterest.com/pin/159596380538102131/) — 8 s, the most cinematic
- ★ [Waves at sunset](https://www.pinterest.com/pin/389068855323729464/) — 4 s (short, needs a clean loop)
- [Waves on a grey day](https://www.pinterest.com/pin/340584790597695034/) — 13 s
- [Deep blue open water](https://www.pinterest.com/pin/549368854567152108/) — 48 s

## Forest

- ★ [Light rays through tall trees](https://www.pinterest.com/pin/182325484908052506/) — 15 s
- ★ [Autumn forest, morning rays](https://www.pinterest.com/pin/1112178070477726568/) — 78 s
- [Bright green forest](https://www.pinterest.com/pin/678354762727876000/) — 7 s (looks CG)

## Fire — Fireplace

- ★ [Close-up of a log fire](https://www.pinterest.com/pin/835840012118167710/) — 11 s (also reposted as [699535754656426376](https://www.pinterest.com/pin/699535754656426376/))
- [Fireplace with candles](https://www.pinterest.com/pin/302656037472232173/) — 30 s (looks generated)
- [Snowy cabin with a fireplace](https://www.pinterest.com/pin/19281104650571397/) — 7 s (looks generated)

## Indoors — Café

Weak on Pinterest without signing in: most café results are long YouTube ambience stills.

- ★ [Steam over a coffee cup in the dark](https://www.pinterest.com/pin/722335227775056797/) — 9 s (looks partly generated)
- [Cosy café on a rainy day](https://www.pinterest.com/pin/468515167504411678/) — 5 s (illustration-like)
- Search to browse when signed in: [rainy café window video](https://www.pinterest.com/search/videos/?q=rainy%20cafe%20window)

## Indoors — Library

- ★ [Old leather books stacked before shelves](https://www.pinterest.com/pin/16184879905366663/) — 10 s
- [Library lamp being switched on](https://www.pinterest.com/pin/10485011673947977/) — 13 s (a hand is in frame)
- ✗ [Gothic library](https://www.pinterest.com/pin/5488830785956760/) and [castle window](https://www.pinterest.com/pin/837739968182383873/) — beautiful but TikTok-watermarked, reference only
- Search: [old library video](https://www.pinterest.com/search/videos/?q=old%20library%20aesthetic)

## Noise — White / Pink / Brown

Fog suits the noises: soft, uniform, no subject competing.

- ★ [Misty meadow at dawn](https://www.pinterest.com/pin/485614772332085679/) — 9 s
- [Misty lake with pink flowers](https://www.pinterest.com/pin/481040803971557720/) — 9 s
- [Fog seen from a car window](https://www.pinterest.com/pin/597149231878386180/) — 7 s

## Fantasy — Tavern, Tavern Singing

No short tavern video pins are reachable without signing in (all are long YouTube ambience
stills). Candlelight works as the tavern's moving image:

- ★ [Melting candles in the dark](https://www.pinterest.com/pin/80501912084454356/) — 12 s
- [Three candles with bokeh](https://www.pinterest.com/pin/65372632086711775/) — 60 s
- Search: [medieval tavern video](https://www.pinterest.com/search/videos/?q=medieval%20tavern%20fire)

## Fantasy — Pirate Ship

All candidates look generated or illustrated, so treat them as references:

- [Tall ship in a storm](https://www.pinterest.com/pin/117375134031861844/) — 7 s
- [Ship's cabin with a storm outside](https://www.pinterest.com/pin/3940718419999213/) — 20 s
- [Black-and-white ship in a storm](https://www.pinterest.com/pin/13721973861043806/) — 148 s

---

## Which video plays when several sounds are mixed (proposal)

Today the scene follows the first sound added. Proposed rule: **the place you are in, with the
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
the sides), so the ramp lines up with the screen. When a licensed replacement clip arrives, run it
through the same bake before adding it. The bake script is `scripts/bake-listen-blur.py`.

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
