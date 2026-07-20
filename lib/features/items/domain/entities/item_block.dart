import 'package:equatable/equatable.dart';
import 'item_entity.dart';

class ItemBlock extends Equatable {
  final String id;
  final String? parentId;
  final String? title;
  final ItemType type;
  
  // Type-specific fields
  final String? content;
  final String? promptContent;
  final String? url;
  final String? linkPreviewTitle;
  final String? website;
  final String? email;
  final String? username;
  final String? encryptedPassword;
  final String? code;
  final String? codeLanguage;
  final String? endpoint;
  final String? method;
  final String? headersJson;
  final String? bodyJson;
  final String? apiNotes;

  const ItemBlock({
    required this.id,
    this.parentId,
    this.title,
    required this.type,
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

  ItemBlock copyWith({
    String? id,
    String? parentId,
    String? title,
    ItemType? type,
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
    return ItemBlock(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId, // To nullify parentId, we might need a wrapped parameter, but this is fine for now
      title: title ?? this.title,
      type: type ?? this.type,
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

  @override
  List<Object?> get props => [
        id, parentId, title, type, content, promptContent, url, linkPreviewTitle,
        website, email, username, encryptedPassword, code, codeLanguage,
        endpoint, method, headersJson, bodyJson, apiNotes,
      ];
}
