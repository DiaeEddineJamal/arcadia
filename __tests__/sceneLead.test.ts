import { pickLead } from '../src/state/useSceneLead';

const t = (id: string, volume = 0.6, playing = true) => ({ id, volume, playing });

describe('pickLead', () => {
  test('nothing in the mix leads nothing', () => {
    expect(pickLead([])).toBeNull();
  });

  test('a setting outranks weather: rain + café shows the café', () => {
    expect(pickLead([t('rain_light', 0.9), t('cafe', 0.2)])).toBe('cafe');
  });

  test('rain + fireplace shows the fire', () => {
    expect(pickLead([t('rain_heavy'), t('fireplace')])).toBe('fireplace');
  });

  test('a landscape outranks weather: rain + forest shows the forest', () => {
    expect(pickLead([t('thunder'), t('forest')])).toBe('forest');
  });

  test('within a tier the louder layer leads', () => {
    expect(pickLead([t('ocean_waves', 0.4), t('wind', 0.8)])).toBe('wind');
  });

  test('equal tier and volume: the most recently added leads', () => {
    expect(pickLead([t('ocean_waves', 0.5), t('wind', 0.5)])).toBe('wind');
  });

  test('noise leads only when it is alone', () => {
    expect(pickLead([t('white_noise', 1), t('rain_light', 0.1)])).toBe('rain_light');
    expect(pickLead([t('brown_noise')])).toBe('brown_noise');
  });

  test('paused layers do not lead while something is playing', () => {
    expect(pickLead([t('cafe', 0.9, false), t('rain_light', 0.3)])).toBe('rain_light');
  });

  test('when everything is paused the highest tier still leads', () => {
    expect(pickLead([t('rain_light', 0.9, false), t('tavern', 0.2, false)])).toBe('tavern');
  });
});
