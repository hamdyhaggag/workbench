import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.type,
    super.status,
    super.isFavorite,
    super.isPinned,
    super.tags,
    required super.createdAt,
    required super.updatedAt,
    super.lastAccessedAt,
    super.content,
    super.promptContent,
    super.url,
    super.linkPreviewTitle,
    super.website,
    super.email,
    super.username,
    super.encryptedPassword,
    super.code,
    super.codeLanguage,
    super.endpoint,
    super.method,
    super.headersJson,
    super.bodyJson,
    super.apiNotes,
  });

  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      title: data['title'] ?? '',
      type: ItemType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ItemType.note,
      ),
      status: ItemStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ItemStatus.active,
      ),
      isFavorite: data['isFavorite'] ?? false,
      isPinned: data['isPinned'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastAccessedAt: (data['lastAccessedAt'] as Timestamp?)?.toDate(),
      content: data['content'],
      promptContent: data['promptContent'],
      url: data['url'],
      linkPreviewTitle: data['linkPreviewTitle'],
      website: data['website'],
      email: data['email'],
      username: data['username'],
      encryptedPassword: data['encryptedPassword'],
      code: data['code'],
      codeLanguage: data['codeLanguage'],
      endpoint: data['endpoint'],
      method: data['method'],
      headersJson: data['headersJson'],
      bodyJson: data['bodyJson'],
      apiNotes: data['apiNotes'],
    );
  }

  factory ItemModel.fromEntity(ItemEntity entity) {
    return ItemModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      type: entity.type,
      status: entity.status,
      isFavorite: entity.isFavorite,
      isPinned: entity.isPinned,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastAccessedAt: entity.lastAccessedAt,
      content: entity.content,
      promptContent: entity.promptContent,
      url: entity.url,
      linkPreviewTitle: entity.linkPreviewTitle,
      website: entity.website,
      email: entity.email,
      username: entity.username,
      encryptedPassword: entity.encryptedPassword,
      code: entity.code,
      codeLanguage: entity.codeLanguage,
      endpoint: entity.endpoint,
      method: entity.method,
      headersJson: entity.headersJson,
      bodyJson: entity.bodyJson,
      apiNotes: entity.apiNotes,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'type': type.name,
      'status': status.name,
      'isFavorite': isFavorite,
      'isPinned': isPinned,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastAccessedAt': lastAccessedAt != null ? Timestamp.fromDate(lastAccessedAt!) : null,
      'content': content,
      'promptContent': promptContent,
      'url': url,
      'linkPreviewTitle': linkPreviewTitle,
      'website': website,
      'email': email,
      'username': username,
      'encryptedPassword': encryptedPassword,
      'code': code,
      'codeLanguage': codeLanguage,
      'endpoint': endpoint,
      'method': method,
      'headersJson': headersJson,
      'bodyJson': bodyJson,
      'apiNotes': apiNotes,
      // Search index fields
      'searchTitle': title.toLowerCase(),
    };
  }
}
