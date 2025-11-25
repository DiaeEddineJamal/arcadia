import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'sound_mix.g.dart';

@HiveType(typeId: 1)
class SoundTrack extends Equatable {
  @HiveField(0)
  final String soundId;
  
  @HiveField(1)
  final double volume;
  
  @HiveField(2)
  final bool isEnabled;

  const SoundTrack({
    required this.soundId,
    required this.volume,
    this.isEnabled = true,
  });

  SoundTrack copyWith({
    String? soundId,
    double? volume,
    bool? isEnabled,
  }) {
    return SoundTrack(
      soundId: soundId ?? this.soundId,
      volume: volume ?? this.volume,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [soundId, volume, isEnabled];
}

@HiveType(typeId: 2)
class SoundMix extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final List<SoundTrack> tracks;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime updatedAt;
  
  @HiveField(5)
  final bool isFavorite;
  
  @HiveField(6)
  final String? description;

  const SoundMix({
    required this.id,
    required this.name,
    required this.tracks,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.description,
  });

  SoundMix copyWith({
    String? id,
    String? name,
    List<SoundTrack>? tracks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? description,
  }) {
    return SoundMix(
      id: id ?? this.id,
      name: name ?? this.name,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        tracks,
        createdAt,
        updatedAt,
        isFavorite,
        description,
      ];
}