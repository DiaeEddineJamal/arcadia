// The sound catalogue (same recordings and default volumes as the Flutter build).
import type { IconName } from '../design/primitives';

export interface Sound {
  id: string;
  name: string;
  fileName: string;
  category: Category;
  defaultVolume: number;
}

export type Category = 'Rain' | 'Wind' | 'Ocean' | 'Forest' | 'Fire' | 'Indoors' | 'Noise' | 'Fantasy';

export const SOUNDS: Sound[] = [
  { id: 'rain_light', name: 'Light Rain', fileName: 'rain_light.mp3', category: 'Rain', defaultVolume: 0.7 },
  { id: 'rain_heavy', name: 'Heavy Rain', fileName: 'rain_heavy.mp3', category: 'Rain', defaultVolume: 0.6 },
  { id: 'thunder', name: 'Thunder', fileName: 'thunder.mp3', category: 'Rain', defaultVolume: 0.5 },
  { id: 'wind', name: 'Wind', fileName: 'wind.mp3', category: 'Wind', defaultVolume: 0.6 },
  { id: 'ocean_waves', name: 'Ocean Waves', fileName: 'ocean_waves.mp3', category: 'Ocean', defaultVolume: 0.8 },
  { id: 'forest', name: 'Forest', fileName: 'forest.mp3', category: 'Forest', defaultVolume: 0.7 },
  { id: 'fireplace', name: 'Fireplace', fileName: 'fireplace.mp3', category: 'Fire', defaultVolume: 0.7 },
  { id: 'cafe', name: 'Café', fileName: 'cafe.mp3', category: 'Indoors', defaultVolume: 0.6 },
  { id: 'library', name: 'Library', fileName: 'library.mp3', category: 'Indoors', defaultVolume: 0.4 },
  { id: 'white_noise', name: 'White Noise', fileName: 'white_noise.mp3', category: 'Noise', defaultVolume: 0.5 },
  { id: 'pink_noise', name: 'Pink Noise', fileName: 'pink_noise.mp3', category: 'Noise', defaultVolume: 0.5 },
  { id: 'brown_noise', name: 'Brown Noise', fileName: 'brown_noise.mp3', category: 'Noise', defaultVolume: 0.5 },
  { id: 'tavern', name: 'Tavern', fileName: 'tavern.mp3', category: 'Fantasy', defaultVolume: 0.6 },
  { id: 'tavern_singing', name: 'Tavern Singing', fileName: 'tavern_singing.mp3', category: 'Fantasy', defaultVolume: 0.55 },
  { id: 'pirates', name: 'Pirate Ship', fileName: 'pirates.mp3', category: 'Fantasy', defaultVolume: 0.65 },
];

export const CATEGORY_ORDER: Category[] = ['Rain', 'Wind', 'Ocean', 'Forest', 'Fire', 'Indoors', 'Noise', 'Fantasy'];

export const CATEGORY_ICON: Record<Category, IconName> = {
  Rain: 'cloud-rain',
  Wind: 'wind',
  Ocean: 'waves',
  Forest: 'trees',
  Fire: 'flame',
  Indoors: 'coffee',
  Noise: 'audio-lines',
  Fantasy: 'castle',
};

export function getSound(id: string): Sound | undefined {
  return SOUNDS.find(s => s.id === id);
}

export function soundsIn(category: Category): Sound[] {
  return SOUNDS.filter(s => s.category === category);
}

/** "Light Rain", "Light Rain & Forest", "Light Rain, Forest & Fireplace", "Light Rain, Forest & 2 more". */
export function mixTitle(names: string[]): string {
  if (names.length === 0) return '';
  if (names.length === 1) return names[0];
  if (names.length === 2) return `${names[0]} & ${names[1]}`;
  if (names.length === 3) return `${names[0]}, ${names[1]} & ${names[2]}`;
  return `${names[0]}, ${names[1]} & ${names.length - 2} more`;
}
