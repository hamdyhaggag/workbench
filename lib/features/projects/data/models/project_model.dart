import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    super.description,
    super.emoji,
    super.color,
    required super.createdAt,
    required super.updatedAt,
    super.isArchived,
    super.itemCount,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '📁',
      color: data['color'] ?? '#E3B119',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isArchived: data['isArchived'] ?? false,
      itemCount: data['itemCount'] ?? 0,
    );
  }

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      emoji: entity.emoji,
      color: entity.color,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isArchived: entity.isArchived,
      itemCount: entity.itemCount,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'emoji': emoji,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isArchived': isArchived,
      'itemCount': itemCount,
    };
  }
}
