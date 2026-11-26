/**
 * Which place the Listen scene shows for the current mix: "the place you are in, with the
 * weather around it".
 *
 *  1. Each category has a tier: setting (café, library, tavern, pirate ship, fireplace) >
 *     landscape (ocean, forest, wind) > weather (rain, thunder) > texture (the noises).
 *  2. The highest tier present leads. Rain + Café → the café; Rain + Fireplace → the fire.
 *  3. Within a tier the loudest layer leads (its volume, counting only layers that are playing);
 *     ties go to the layer added most recently.
 *  4. Noise leads only when nothing else is in the mix.
 *  5. Hysteresis: a challenger takes over only after leading for ~2 s, so dragging a slider never
 *     flickers the scene. The first sound, or the leader leaving the mix, switches at once.
 */
import { useEffect, useRef, useState } from 'react';
import { Category, getSound } from '../data/sounds';
import type { MixerTrack } from '../services/mixer';

const TIER: Record<Category, number> = {
  Indoors: 3,
  Fantasy: 3,
  Fire: 3,
  Ocean: 2,
  Forest: 2,
  Wind: 2,
  Rain: 1,
  Noise: 0,
};

export const SCENE_HOLD_MS = 2000;

/** The sound id that should lead right now, with no hysteresis. */
export function pickLead(tracks: MixerTrack[]): string | null {
  if (tracks.length === 0) return null;
  const playing = tracks.filter(t => t.playing);
  const pool = playing.length > 0 ? playing : tracks;
  let best: { id: string; tier: number; loud: number; order: number } | null = null;
  pool.forEach(t => {
    const sound = getSound(t.id);
    if (!sound) return;
    const tier = TIER[sound.category];
    const loud = t.playing ? t.volume : 0;
    const order = tracks.indexOf(t); // later = added more recently
    if (
      !best ||
      tier > best.tier ||
      (tier === best.tier && loud > best.loud + 0.001) ||
      (tier === best.tier && Math.abs(loud - best.loud) <= 0.001 && order > best.order)
    ) {
      best = { id: t.id, tier, loud, order };
    }
  });
  return (best as { id: string } | null)?.id ?? null;
}

/** The leading sound id, stabilised over time. */
export function useSceneLead(tracks: MixerTrack[]): string | null {
  const candidate = pickLead(tracks);
  const [lead, setLead] = useState<string | null>(candidate);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const leadInMix = lead !== null && tracks.some(t => t.id === lead);

  useEffect(() => {
    if (timer.current) {
      clearTimeout(timer.current);
      timer.current = null;
    }
    if (candidate === lead) return;
    // Switch at once when there is no current leader to protect.
    if (lead === null || !leadInMix || candidate === null) {
      setLead(candidate);
      return;
    }
    timer.current = setTimeout(() => setLead(candidate), SCENE_HOLD_MS);
    return () => {
      if (timer.current) clearTimeout(timer.current);
    };
  }, [candidate, lead, leadInMix]);

  return lead;
}
