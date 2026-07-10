import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final int itemCount;

  const ProjectEntity({
    required this.id,
    required this.name,
    this.description = '',
    this.emoji = '📁',
    this.color = '#E3B119',
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.itemCount = 0,
  });

  ProjectEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    int? itemCount,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  List<Object?> get props => [id, name, description, emoji, color, createdAt, updatedAt, isArchived, itemCount];
}
