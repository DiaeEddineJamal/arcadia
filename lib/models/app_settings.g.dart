// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDarkMode: fields[0] as bool,
      masterVolume: fields[1] as double,
      enableBackgroundPlay: fields[2] as bool,
      enableNotifications: fields[3] as bool,
      defaultSleepTimer: fields[4] as int,
      enableFadeInOut: fields[5] as bool,
      fadeInDuration: fields[6] as int,
      fadeOutDuration: fields[7] as int,
      enableGrainOverlay: fields[8] as bool,
      grainIntensity: fields[9] as double,
      accentColor: fields[10] as String,
      isOnboardingCompleted: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.masterVolume)
      ..writeByte(2)
      ..write(obj.enableBackgroundPlay)
      ..writeByte(3)
      ..write(obj.enableNotifications)
      ..writeByte(4)
      ..write(obj.defaultSleepTimer)
      ..writeByte(5)
      ..write(obj.enableFadeInOut)
      ..writeByte(6)
      ..write(obj.fadeInDuration)
      ..writeByte(7)
      ..write(obj.fadeOutDuration)
      ..writeByte(8)
      ..write(obj.enableGrainOverlay)
      ..writeByte(9)
      ..write(obj.grainIntensity)
      ..writeByte(10)
      ..write(obj.accentColor)
      ..writeByte(11)
      ..write(obj.isOnboardingCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
