// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_mix.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoundTrackAdapter extends TypeAdapter<SoundTrack> {
  @override
  final int typeId = 1;

  @override
  SoundTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SoundTrack(
      soundId: fields[0] as String,
      volume: fields[1] as double,
      isEnabled: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SoundTrack obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.soundId)
      ..writeByte(1)
      ..write(obj.volume)
      ..writeByte(2)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SoundMixAdapter extends TypeAdapter<SoundMix> {
  @override
  final int typeId = 2;

  @override
  SoundMix read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SoundMix(
      id: fields[0] as String,
      name: fields[1] as String,
      tracks: (fields[2] as List).cast<SoundTrack>(),
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      isFavorite: fields[5] as bool,
      description: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SoundMix obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.tracks)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundMixAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
