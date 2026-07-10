import 'package:equatable/equatable.dart';

enum ItemType { note, prompt, link, account, snippet, api }

enum ItemStatus { active, archived, trashed }

class ItemEntity extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final ItemType type;
  final ItemStatus status;
  final bool isFavorite;
  final bool isPinned;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;

  // Type-specific fields
  // Note
  final String? content;

  // Prompt
  final String? promptContent;

  // Link
  final String? url;
  final String? linkPreviewTitle;

  // Account
  final String? website;
  final String? email;
  final String? username;
  final String? encryptedPassword;

  // Snippet
  final String? code;
  final String? codeLanguage;

  // API
  final String? endpoint;
  final String? method;
  final String? headersJson;
  final String? bodyJson;
  final String? apiNotes;

  const ItemEntity({
    required this.id,
    required this.projectId,
    required this.title,
    required this.type,
    this.status = ItemStatus.active,
    this.isFavorite = false,
    this.isPinned = false,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
    this.content,
    this.promptContent,
    this.url,
    this.linkPreviewTitle,
    this.website,
    this.email,
    this.username,
    this.encryptedPassword,
    this.code,
    this.codeLanguage,
    this.endpoint,
    this.method,
    this.headersJson,
    this.bodyJson,
    this.apiNotes,
  });

  ItemEntity copyWith({
    String? id,
    String? projectId,
    String? title,
    ItemType? type,
    ItemStatus? status,
    bool? isFavorite,
    bool? isPinned,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
    String? content,
    String? promptContent,
    String? url,
    String? linkPreviewTitle,
    String? website,
    String? email,
    String? username,
    String? encryptedPassword,
    String? code,
    String? codeLanguage,
    String? endpoint,
    String? method,
    String? headersJson,
    String? bodyJson,
    String? apiNotes,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      content: content ?? this.content,
      promptContent: promptContent ?? this.promptContent,
      url: url ?? this.url,
      linkPreviewTitle: linkPreviewTitle ?? this.linkPreviewTitle,
      website: website ?? this.website,
      email: email ?? this.email,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      code: code ?? this.code,
      codeLanguage: codeLanguage ?? this.codeLanguage,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      headersJson: headersJson ?? this.headersJson,
      bodyJson: bodyJson ?? this.bodyJson,
      apiNotes: apiNotes ?? this.apiNotes,
    );
  }

  String get searchableContent {
    final parts = <String>[title];
    if (content != null) parts.add(content!);
    if (promptContent != null) parts.add(promptContent!);
    if (url != null) parts.add(url!);
    if (website != null) parts.add(website!);
    if (email != null) parts.add(email!);
    if (username != null) parts.add(username!);
    if (code != null) parts.add(code!);
    if (endpoint != null) parts.add(endpoint!);
    if (apiNotes != null) parts.add(apiNotes!);
    parts.addAll(tags);
    return parts.join(' ').toLowerCase();
  }

  @override
  List<Object?> get props => [id, projectId, title, type, status, isFavorite, isPinned, tags, createdAt, updatedAt];
}
