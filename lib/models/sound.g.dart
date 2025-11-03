// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoundAdapter extends TypeAdapter<Sound> {
  @override
  final int typeId = 0;

  @override
  Sound read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sound(
      id: fields[0] as String,
      name: fields[1] as String,
      fileName: fields[2] as String,
      category: fields[3] as String,
      iconPath: fields[4] as String,
      isPremium: fields[5] as bool,
      defaultVolume: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Sound obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.iconPath)
      ..writeByte(5)
      ..write(obj.isPremium)
      ..writeByte(6)
      ..write(obj.defaultVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
