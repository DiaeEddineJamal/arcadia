import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'sound.g.dart';

@HiveType(typeId: 0)
class Sound extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String fileName;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final String iconPath;
  
  @HiveField(5)
  final bool isPremium;
  
  @HiveField(6)
  final double defaultVolume;

  const Sound({
    required this.id,
    required this.name,
    required this.fileName,
    required this.category,
    required this.iconPath,
    this.isPremium = false,
    this.defaultVolume = 0.7,
  });

  Sound copyWith({
    String? id,
    String? name,
    String? fileName,
    String? category,
    String? iconPath,
    bool? isPremium,
    double? defaultVolume,
  }) {
    return Sound(
      id: id ?? this.id,
      name: name ?? this.name,
      fileName: fileName ?? this.fileName,
      category: category ?? this.category,
      iconPath: iconPath ?? this.iconPath,
      isPremium: isPremium ?? this.isPremium,
      defaultVolume: defaultVolume ?? this.defaultVolume,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        fileName,
        category,
        iconPath,
        isPremium,
        defaultVolume,
      ];
}