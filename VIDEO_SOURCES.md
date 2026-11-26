# Licensed Listen visuals

## In use (2026-11-26)

All from Pexels (free; no credit required). Originals, the licence log with creators and the
licence text as of the download date are in `.stock/` (gitignored). Processed clips are in
`assets/videos/scenes/` (gitignored; the repo is public).

| Place | Clip |
| --- | --- |
| Light Rain | [Candle on a window sill in the rain](https://www.pexels.com/video/a-candle-is-lit-on-a-window-sill-in-the-rain-19095583/) |
| Heavy Rain | [Monsoon rain over misty green hills](https://www.pexels.com/video/lush-monsoon-greenery-in-bangladesh-rain-37302238/) |
| Thunder | [Storm clouds over a city at night](https://www.pexels.com/video/dramatic-night-sky-with-storm-clouds-32410944/) (the first pick was almost black between flashes) |
| Wind | [Tall grass against a golden sunset](https://www.pexels.com/video/serene-nature-scene-with-tall-grass-and-sunset-35022871/) |
| Ocean Waves | [Aerial: waves on a dark beach at night](https://www.pexels.com/video/aerial-view-of-waves-crashing-on-beach-at-night-37757498/) |
| Fireplace | [Wood stove in a dark room](https://www.pexels.com/video/fire-in-fireplace-12917294/) |
| White / Pink / Brown Noise | [Sunrise over a sea of fog](https://www.pexels.com/video/a-sunrise-over-the-ocean-with-fog-18310301/) |
| Café | [Empty classic café](https://www.pexels.com/video/cozy-indoor-cafe-with-classic-ambiance-30574535/) (first 5.5 s only; the later shot shows a shop sign) |
| Library | [Candle among open books](https://www.pexels.com/video/wax-candle-among-books-13096729/) |
| Tavern, Tavern Singing | [Tall candles in the dark](https://www.pexels.com/video/candles-27897502/) |
| Pirate Ship | [Sailboat in a rough sea](https://www.pexels.com/video/sailboat-navigating-rough-sea-waves-39009187/) |
| Forest (and silence) | The app's own `main_animated` footage, unchanged |

To replace one: download it into `.stock/originals/`, run
`python scripts/prepare-scene-clip.py <file> assets/videos/scenes <place> [--start S --duration D]`,
add a row to `.stock/LICENCES.md`.

## How the sources were chosen

Researched 2026-11-26. Licence terms were read on each site that day. This is not legal advice;
the point is to pick sources whose licence covers **video bundled in a mobile app**, and to avoid
the clips that carry extra risk (people, brands, logos, religious or private settings).

## Which sources are safe

| Source | Cost | Apps covered? | Attribution | Main restriction | Indemnity |
| --- | --- | --- | --- | --- | --- |
| **Coverr** (coverr.co) | Free | **Yes, by name**: "Websites, templates, apps, ads and client work are all fine" | Not required | Don't sell, give away or re-upload the raw files | None ("as is") |
| **Pexels** (pexels.com) | Free | Yes: the licence lists use "on your website, blog or app" | Not required | Don't sell or distribute a clip "on a Standalone basis", i.e. substantially unchanged; no trademarks; don't show identifiable people "in a bad light" or imply their endorsement | None; Pexels "do not warrant that any consents or licenses have been obtained" |
| Pixabay (pixabay.com) | Free | Commercial use yes; apps not named | Not required | Same "Standalone" rule as Pexels; no bulk copying | None |
| **Adobe Stock** | Paid (per clip or plan) | Standard licence allows reproduction "in all media, including … software" up to 500,000 copies or views; Enhanced/Extended removes the cap | Not required | Don't distribute "the stand-alone file" | Adobe's terms include an indemnity (amount not checked here; read before buying) |
| Storyblocks | Paid subscription | Not named; covers "multimedia … finished projects" | Not required | No standalone distribution; the Individual licence covers one person only, so a business needs the Business licence | Up to $20,000 on the Individual plan |
| Mixkit, Artlist, Envato Elements | Free / paid | **Not verified**: their licence pages couldn't be read automatically | — | — | — |

### Recommendation

1. **Use Coverr first and Pexels second.** Both are free, need no credit, and cover in-app use.
   Coverr is the safest wording ("apps" by name); Pexels has by far the better selection.
2. **What we do to a clip already takes it out of "standalone" use**: cropped to portrait,
   re-graded, muted, re-encoded with the baked blur, played behind our own UI. Keep it that way:
   never let users save or export a clip, and never ship the raw downloaded file unchanged.
3. **Keep the clips out of the public GitHub repo.** Publishing the downloaded files there is
   "giving away the raw files", which both licences forbid. Keep using the gitignored local folder
   (`assets/videos/scenes/`) and add the clips only to builds.
4. **Avoid clips with people, faces, logos, shop signs or readable brands.** Free sites give no
   model or property releases and no indemnity. Every pick below follows this rule.
5. **Keep proof.** For each clip, save its page URL, the download date and a screenshot of the
   licence page that day (a `licences/` folder outside git is enough). If an uploader turns out not
   to own a clip, that record shows good faith and lets you replace it quickly.
6. **For the tavern and the pirate ship, buy one clip each** (Adobe Stock or Storyblocks
   Business). The free libraries have no real taverns or tall ships, and paid licences come with
   an indemnity.

## Picks for each place

★ = first choice. All Pexels picks are portrait (9:16) unless marked "landscape". Coverr clips
are landscape, so they're centre-cropped to the phone, which suits these subjects.

### Light Rain — rain on a window, cosy
- ★ [Candle on a window sill in the rain (dusk)](https://www.pexels.com/video/a-candle-is-lit-on-a-window-sill-in-the-rain-19095583/) — Pexels
- [Night rain on glass, warm bokeh](https://www.pexels.com/video/yagmur-27637593/) — Pexels
- [City lights through a rainy window at night](https://www.pexels.com/video/nighttime-cityscape-with-rain-on-window-35099181/) — Pexels

### Heavy Rain
- ★ [Monsoon rain over misty green hills](https://www.pexels.com/video/lush-monsoon-greenery-in-bangladesh-rain-37302238/) — Pexels
- [Downpour over a tropical coast](https://www.pexels.com/video/heavy-rain-falling-on-a-tropical-island-beach-12101457/) — Pexels
- [Rain and wind in a forest](https://www.pexels.com/video/rainy-day-in-a-windy-forest-setting-34158589/) — Pexels

### Thunder
- ★ [Thunderstorm clouds lit from inside, purple](https://www.pexels.com/video/dramatic-nighttime-thunderstorm-with-lightning-30296083/) — Pexels
- [Storm clouds over a city at night](https://www.pexels.com/video/dramatic-night-sky-with-storm-clouds-32410944/) — Pexels (small city lights at the bottom)
- [Single lightning bolt in a dark sky](https://www.pexels.com/video/dramatic-lightning-bolt-at-night-39831591/) — Pexels

### Wind
- ★ [Tall grass against a golden sunset](https://www.pexels.com/video/serene-nature-scene-with-tall-grass-and-sunset-35022871/) — Pexels
- [Wheat at golden hour](https://www.pexels.com/video/golden-hour-wheat-field-serenity-35022864/) — Pexels
- [Grass silhouettes at sunset](https://www.pexels.com/video/golden-sunset-over-vibrant-wheat-field-32192845/) — Pexels

### Ocean Waves
- ★ [Aerial: waves breaking on a dark beach at night](https://www.pexels.com/video/aerial-view-of-waves-crashing-on-beach-at-night-37757498/) — Pexels
- ★ [Dark ocean surface rolling](https://coverr.co/videos/ocean-waves-jolwnczjml) — Coverr (landscape)
- [Aerial: dark sea with long foam lines](https://www.pexels.com/video/a-painting-of-a-blue-ocean-with-waves-20752412/) — Pexels (the title is auto-generated; it's real footage)
- [Aerial: a wave folding over dark water](https://coverr.co/videos/ocean-waves-tnhh3rqeox) — Coverr (landscape)

### Forest
- ★ [Misty forest, sun through the trees](https://www.pexels.com/video/misty-forest-with-sunlight-streaming-through-trees-30762712/) — Pexels
- [Misty forest floor, green light](https://www.pexels.com/video/serene-misty-forest-with-lush-greenery-36798463/) — Pexels
- [Foggy pines](https://coverr.co/videos/foggy-forest-06yshrbpk8) — Coverr (landscape)

### Fireplace
- ★ [Wood stove in a dark room, kettle on top](https://www.pexels.com/video/fire-in-fireplace-12917294/) — Pexels
- [Stove glowing in a dark room](https://www.pexels.com/video/cozy-fireplace-with-warm-glowing-flames-32575073/) — Pexels
- [Close-up: logs and flames](https://www.pexels.com/video/cozy-fireplace-with-burning-logs-ambiance-34230599/) — Pexels

### White / Pink / Brown Noise — fog, nothing competing
- ★ [Pink sunrise over a sea of fog](https://www.pexels.com/video/a-sunrise-over-the-ocean-with-fog-18310301/) — Pexels
- [Violet misty sunrise](https://www.pexels.com/video/serene-sunrise-over-misty-landscape-33897599/) — Pexels
- [Lone tree in the mist](https://coverr.co/videos/tree-in-the-mist-jl07anu9ty) — Coverr (landscape)

### Café
- ★ [Empty classic café, warm lamps, evening](https://www.pexels.com/video/cozy-indoor-cafe-with-classic-ambiance-30574535/) — Pexels
- [Coffee and a candle by a rainy window](https://www.pexels.com/video/a-cup-of-coffee-and-a-candle-on-a-window-sill-19315630/) — Pexels
- [Café table by the window on a rainy street](https://www.pexels.com/video/cozy-cafe-during-rainy-day-on-city-street-30627136/) — Pexels (check the magazine cover on the table; crop or skip if a title is readable)

### Library
- ★ [Candle among open old books, dark](https://www.pexels.com/video/wax-candle-among-books-13096729/) — Pexels
- [Candle and magnifying glass on an old book](https://www.pexels.com/video/a-candle-and-a-magnifying-glass-on-top-of-a-book-17542800/) — Pexels
- [Dark bookshelf of classics](https://www.pexels.com/video/cozy-library-bookshelf-with-classic-literature-33997135/) — Pexels

### Tavern, Tavern Singing — no real taverns in the free libraries; warm candlelight instead
- ★ [Tall candles burning in the dark](https://coverr.co/videos/burning-church-candles-v1y9sfoo09) — Coverr (landscape; the church setting isn't visible once cropped)
- [Tall candles flickering in darkness](https://www.pexels.com/video/candles-27897502/) — Pexels
- Better: buy one "medieval tavern interior, fire, candles, no people" clip from Adobe Stock or Storyblocks Business.

### Pirate Ship — no tall ships in the free libraries
- [Sailboat in rough sea](https://www.pexels.com/video/sailboat-navigating-rough-sea-waves-39009187/) — Pexels (small boat, not a galleon)
- [Storm waves](https://www.pexels.com/video/dramatic-ocean-waves-crashing-in-stormy-weather-32719391/) — Pexels
- [Aerial: wreck on a rocky shore](https://www.pexels.com/video/aerial-view-of-shipwreck-on-rocky-shoreline-35681197/) — Pexels (moody, fits "pirates")
- Better: buy one "tall ship / galleon at sea, storm" clip from Adobe Stock or Storyblocks Business.

## Before using a pick

- Watch the whole clip: no people, faces, logos, licence plates, readable signs or brand names
  anywhere in it, including frames that the thumbnail doesn't show.
- Prefer the 1080p or 4K portrait download, and at least 8–10 s so the loop doesn't feel short.
- Run it through `scripts/bake-listen-blur.py` for the blurred cut, and record it in the licence
  log described above.
