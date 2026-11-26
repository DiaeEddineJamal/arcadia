// One photograph per place. Used as the Listen scene for a mix led by that place, and to open
// each section in Sounds.
import type { Category } from './sounds';

export const SCENE_IMAGE: Record<Category, number> = {
  Rain: require('../../assets/images/scene-rain.jpg'),
  Wind: require('../../assets/images/scene-wind.jpg'),
  Ocean: require('../../assets/images/scene-ocean.jpg'),
  Forest: require('../../assets/images/scene-forest.jpg'),
  Fire: require('../../assets/images/scene-fire.jpg'),
  Indoors: require('../../assets/images/scene-indoors.jpg'),
  Noise: require('../../assets/images/scene-noise.jpg'),
  Fantasy: require('../../assets/images/scene-fantasy.jpg'),
};

/** Vertical focal point (0 = top, 1 = bottom) for showing each photograph in a short band. */
export const SCENE_FOCUS: Record<Category, number> = {
  Rain: 0.4,
  Wind: 0.62,
  Ocean: 0.6,
  Forest: 0.5,
  Fire: 0.45,
  Indoors: 0.42,
  Noise: 0.42,
  Fantasy: 0.4,
};

/**
 * A Listen clip in two cuts: the original, and the same clip with BitChord's progressive blur
 * baked in (sharp top, blurred behind the title and controls; scripts/bake-listen-blur.py).
 * Both play together; the blurred cut fades out in immersive mode.
 */
export interface SceneClip {
  sharp: number;
  blur: number;
}

/**
 * The Listen clips for each sound: free stock footage (VIDEO_SOURCES.md), kept out of the public
 * repo in sceneVideos.local.ts (gitignored, with assets/videos/scenes/). Without that file
 * every place shows its photograph. Loaded as an optional dependency (metro.config.js).
 */
function loadLocalClips(): Partial<Record<string, SceneClip>> {
  try {
    return require('./sceneVideos.local').SCENE_VIDEO;
  } catch {
    return {};
  }
}

export const SCENE_VIDEO: Partial<Record<string, SceneClip>> = loadLocalClips();
