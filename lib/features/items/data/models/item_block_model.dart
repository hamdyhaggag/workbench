import '../../domain/entities/item_block.dart';
import '../../domain/entities/item_entity.dart';

class ItemBlockModel extends ItemBlock {
  const ItemBlockModel({
    required super.id,
    super.parentId,
    super.title,
    required super.type,
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

  factory ItemBlockModel.fromMap(Map<String, dynamic> data) {
    return ItemBlockModel(
      id: data['id'] ?? '',
      parentId: data['parentId'],
      title: data['title'],
      type: ItemType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ItemType.note,
      ),
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

  factory ItemBlockModel.fromEntity(ItemBlock entity) {
    return ItemBlockModel(
      id: entity.id,
      parentId: entity.parentId,
      title: entity.title,
      type: entity.type,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'title': title,
      'type': type.name,
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
    };
  }
}
