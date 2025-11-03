# Sound Assets Required for Arcadia App

This document lists all the MP3 sound files that need to be provided for the Arcadia ambient sound app. All files should be placed in the `c:\Users\PC\Desktop\arcadia\assets\sounds\` directory.

## File Format Requirements
- **Format**: MP3
- **Quality**: High quality, optimized for looping
- **Licensing**: Royalty-free or properly licensed
- **Loop**: All sounds should be seamless loops without gaps

## Required Sound Files

### Rain Category
| File Name | Display Name | Description | Default Volume |
|-----------|--------------|-------------|----------------|
| `rain_light.mp3` | Light Rain | Gentle, soft rain sounds | 70% |
| `rain_heavy.mp3` | Heavy Rain | Intense rainfall with heavier drops | 60% |
| `thunder.mp3` | Thunder | Distant thunder rumbles | 50% |

### Ocean Category
| File Name | Display Name | Description | Default Volume |
|-----------|--------------|-------------|----------------|
| `ocean_waves.mp3` | Ocean Waves | Rhythmic ocean waves on shore | 80% |

### Nature Category
| File Name | Display Name | Description | Default Volume |
|-----------|--------------|-------------|----------------|
| `forest.mp3` | Forest | Forest ambience with birds and rustling | 70% |

### Wind Category
| File Name | Display Name | Description | Default Volume |
|-----------|--------------|-------------|----------------|
| `wind.mp3` | Wind | Gentle wind through trees | 60% |

### White Noise Category
| File Name | Display Name | Description | Default Volume |
|-----------|--------------|-------------|----------------|
| `white_noise.mp3` | White Noise | Pure white noise for focus | 50% |
| `pink_noise.mp3` | Pink Noise | Balanced pink noise | 50% |
| `brown_noise.mp3` | Brown Noise | Deep brown noise | 50% |

### Fire Category
| File Name | Display Name | Description | Default Volume |
|-----------|--------------|-------------|----------------|
| `fireplace.mp3` | Fireplace | Crackling fireplace sounds | 70% |

### Premium Sounds

#### Cafe Category
| File Name | Display Name | Description | Default Volume | Premium |
|-----------|--------------|-------------|----------------|---------|
| `cafe.mp3` | Café Ambience | Coffee shop atmosphere with chatter | 60% | ✅ |

#### Ambient Category
| File Name | Display Name | Description | Default Volume | Premium |
|-----------|--------------|-------------|----------------|---------|
| `library.mp3` | Library | Quiet library atmosphere | 40% | ✅ |

## Total Files Required: 12

## File Path Structure
```
c:\Users\PC\Desktop\arcadia\assets\sounds\
├── rain_light.mp3
├── rain_heavy.mp3
├── thunder.mp3
├── ocean_waves.mp3
├── forest.mp3
├── wind.mp3
├── white_noise.mp3
├── pink_noise.mp3
├── brown_noise.mp3
├── fireplace.mp3
├── cafe.mp3
└── library.mp3
```

## Featured Sounds in UI
The following sounds are specifically featured on the home screen:
- **Light Rain** (`rain_light.mp3`) - Featured as primary rain sound
- **Ocean Waves** (`ocean_waves.mp3`) - Featured as ocean sound
- **Forest** (`forest.mp3`) - Featured as nature sound

## Technical Notes
- All sounds are loaded using Flutter's `AssetSource('sounds/filename.mp3')`
- Sounds are configured for infinite looping (`ReleaseMode.loop`)
- Each sound has individual volume control that multiplies with master volume
- Premium sounds require app upgrade to access
- Sound files should be optimized for mobile playback and battery efficiency

## Audio Service Integration
The audio service expects these exact file names and will:
1. Initialize each sound as a separate `AudioPlayer` instance
2. Set the file path as `assets/sounds/{fileName}`
3. Configure for looping playback
4. Apply volume controls (individual × master volume)
5. Support simultaneous playback of multiple sounds

## Quality Guidelines
- **Bitrate**: 128-320 kbps recommended
- **Sample Rate**: 44.1 kHz
- **Duration**: 30 seconds to 5 minutes (seamless loop)
- **File Size**: Optimize for mobile (typically 1-10 MB per file)
- **Fade**: Ensure smooth loop transitions without clicks or pops