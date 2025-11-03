# Arcadia - Soundscape Mixing App

A beautiful Flutter app for creating relaxing soundscapes by mixing multiple ambient sounds.

## Features

🔊 **Core Features**
- Multiple simultaneous sound playback
- Individual volume controls for each sound
- Custom sound mix creation and saving
- Offline mode support
- Glassmorphism UI with acrylic panels

🛠️ **Advanced Features**
- Sleep timer with fade out
- Background playback
- Dark/Light theme support
- Customizable accent colors
- Grain overlay effects for mica texture

## Sound Categories

- **Nature**: Rain, Thunder, Ocean Waves, Forest, Wind
- **White Noise**: White, Pink, Brown noise
- **Ambient**: Fireplace, Café, Library (Premium)

## Getting Started

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Dart SDK
- Android Studio / VS Code

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd arcadia
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter packages pub run build_runner build
```

4. Add sound files:
   - Place your sound files (.mp3 format) in `assets/sounds/`
   - Update the sound definitions in `StorageService._initializeDefaultSounds()`

5. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── sound.dart
│   ├── sound_mix.dart
│   └── app_settings.dart
├── services/                 # Business logic
│   ├── audio_service.dart
│   └── storage_service.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── sound_library_screen.dart
│   ├── mix_builder_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable widgets
│   └── glassmorphism_widgets.dart
└── theme/                    # App theming
    └── app_theme.dart
```

## UI/UX Design

The app features a modern glassmorphism design with:
- Semi-transparent acrylic panels
- Soft rounded shapes and organic layouts
- Pastel color palette with customizable accents
- Subtle grain overlays for texture
- Smooth animations and micro-interactions

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **Hive**: Local database
- **AudioPlayers**: Audio playback
- **Glassmorphism**: UI effects

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Acknowledgments

- Sound files should be royalty-free or properly licensed
- UI inspiration from modern design systems
- Flutter community for excellent packages
