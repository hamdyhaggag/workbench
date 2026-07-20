import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/item_block.dart';

class BlockState {
  final String id;
  ItemType type;
  String? parentId;
  TextEditingController titleCtrl = TextEditingController();
  
  TextEditingController contentCtrl = TextEditingController();
  TextEditingController promptCtrl = TextEditingController();
  TextEditingController urlCtrl = TextEditingController();
  TextEditingController websiteCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  bool showPassword = false;
  TextEditingController codeCtrl = TextEditingController();
  String codeLanguage = 'Dart';
  
  TextEditingController endpointCtrl = TextEditingController();
  String method = 'GET';
  TextEditingController headersCtrl = TextEditingController();
  TextEditingController bodyCtrl = TextEditingController();
  TextEditingController apiNotesCtrl = TextEditingController();
  
  bool isExpanded = true;

  BlockState({
    String? id,
    required this.type,
    this.parentId,
  }) : id = id ?? const Uuid().v4();

  factory BlockState.fromEntity(ItemBlock block) {
    final state = BlockState(id: block.id, type: block.type, parentId: block.parentId);
    state.titleCtrl.text = block.title ?? '';
    state.contentCtrl.text = block.content ?? '';
    state.promptCtrl.text = block.promptContent ?? '';
    state.urlCtrl.text = block.url ?? '';
    state.websiteCtrl.text = block.website ?? '';
    state.emailCtrl.text = block.email ?? '';
    state.usernameCtrl.text = block.username ?? '';
    state.passwordCtrl.text = block.encryptedPassword ?? '';
    state.codeCtrl.text = block.code ?? '';
    state.codeLanguage = block.codeLanguage ?? 'Dart';
    state.endpointCtrl.text = block.endpoint ?? '';
    state.method = block.method ?? 'GET';
    state.headersCtrl.text = block.headersJson ?? '';
    state.bodyCtrl.text = block.bodyJson ?? '';
    state.apiNotesCtrl.text = block.apiNotes ?? '';
    return state;
  }

  factory BlockState.fromRootEntity(ItemEntity item) {
    final state = BlockState(id: const Uuid().v4(), type: item.type);
    state.contentCtrl.text = item.content ?? '';
    state.promptCtrl.text = item.promptContent ?? '';
    state.urlCtrl.text = item.url ?? '';
    state.websiteCtrl.text = item.website ?? '';
    state.emailCtrl.text = item.email ?? '';
    state.usernameCtrl.text = item.username ?? '';
    state.passwordCtrl.text = item.encryptedPassword ?? '';
    state.codeCtrl.text = item.code ?? '';
    state.codeLanguage = item.codeLanguage ?? 'Dart';
    state.endpointCtrl.text = item.endpoint ?? '';
    state.method = item.method ?? 'GET';
    state.headersCtrl.text = item.headersJson ?? '';
    state.bodyCtrl.text = item.bodyJson ?? '';
    state.apiNotesCtrl.text = item.apiNotes ?? '';
    return state;
  }
  
  bool get hasContent {
    return contentCtrl.text.isNotEmpty ||
           promptCtrl.text.isNotEmpty ||
           urlCtrl.text.isNotEmpty ||
           websiteCtrl.text.isNotEmpty ||
           emailCtrl.text.isNotEmpty ||
           usernameCtrl.text.isNotEmpty ||
           passwordCtrl.text.isNotEmpty ||
           codeCtrl.text.isNotEmpty ||
           endpointCtrl.text.isNotEmpty ||
           headersCtrl.text.isNotEmpty ||
           bodyCtrl.text.isNotEmpty ||
           apiNotesCtrl.text.isNotEmpty;
  }

  ItemBlock toItemBlock() {
    return ItemBlock(
      id: id,
      parentId: parentId,
      title: titleCtrl.text.isEmpty ? null : titleCtrl.text,
      type: type,
      content: contentCtrl.text.isEmpty ? null : contentCtrl.text,
      promptContent: promptCtrl.text.isEmpty ? null : promptCtrl.text,
      url: urlCtrl.text.isEmpty ? null : urlCtrl.text,
      website: websiteCtrl.text.isEmpty ? null : websiteCtrl.text,
      email: emailCtrl.text.isEmpty ? null : emailCtrl.text,
      username: usernameCtrl.text.isEmpty ? null : usernameCtrl.text,
      encryptedPassword: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
      code: codeCtrl.text.isEmpty ? null : codeCtrl.text,
      codeLanguage: codeLanguage,
      endpoint: endpointCtrl.text.isEmpty ? null : endpointCtrl.text,
      method: method,
      headersJson: headersCtrl.text.isEmpty ? null : headersCtrl.text,
      bodyJson: bodyCtrl.text.isEmpty ? null : bodyCtrl.text,
      apiNotes: apiNotesCtrl.text.isEmpty ? null : apiNotesCtrl.text,
    );
  }

  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    promptCtrl.dispose();
    urlCtrl.dispose();
    websiteCtrl.dispose();
    emailCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    codeCtrl.dispose();
    endpointCtrl.dispose();
    headersCtrl.dispose();
    bodyCtrl.dispose();
    apiNotesCtrl.dispose();
  }
}
