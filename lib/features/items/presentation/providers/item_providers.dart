import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../../data/repositories/item_repository_impl.dart';
import 'package:workbench/features/projects/presentation/providers/project_providers.dart';
import 'package:workbench/features/projects/domain/repositories/project_repository.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

final projectItemsProvider = StreamProvider.family<List<ItemEntity>, String>((ref, projectId) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchItemsByProject(projectId);
});

final favoritesProvider = StreamProvider<List<ItemEntity>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchFavorites();
});

final pinnedItemsProvider = StreamProvider<List<ItemEntity>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchPinned();
});

final recentItemsProvider = StreamProvider<List<ItemEntity>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchRecent(limit: 20);
});

final trashedItemsProvider = StreamProvider<List<ItemEntity>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchTrashed();
});

final archivedItemsProvider = StreamProvider<List<ItemEntity>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchArchived();
});

final itemNotifierProvider = AsyncNotifierProvider<ItemNotifier, void>(ItemNotifier.new);

class ItemNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  ItemRepository get _repo => ref.read(itemRepositoryProvider);
  ProjectRepository get _projRepo => ref.read(projectRepositoryProvider);

  Future<String> createItem({
    required String projectId,
    required String title,
    required ItemType type,
    List<String> tags = const [],
    String? content,
    String? promptContent,
    String? url,
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
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final item = ItemEntity(
      id: id,
      projectId: projectId,
      title: title,
      type: type,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      lastAccessedAt: now,
      content: content,
      promptContent: promptContent,
      url: url,
      website: website,
      email: email,
      username: username,
      encryptedPassword: encryptedPassword,
      code: code,
      codeLanguage: codeLanguage,
      endpoint: endpoint,
      method: method,
      headersJson: headersJson,
      bodyJson: bodyJson,
      apiNotes: apiNotes,
    );
    await _repo.createItem(item);
    await _projRepo.incrementItemCount(projectId);
    return id;
  }

  Future<void> updateItem(ItemEntity item) async {
    await _repo.updateItem(item.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteItem(String id, String projectId) async {
    await _repo.deleteItem(id);
    await _projRepo.decrementItemCount(projectId);
  }

  Future<void> trashItem(String id) async {
    await _repo.trashItem(id);
  }

  Future<void> archiveItem(String id) async {
    await _repo.archiveItem(id);
  }

  Future<void> restoreItem(String id) async {
    await _repo.restoreItem(id);
  }

  Future<void> toggleFavorite(String id, bool value) async {
    await _repo.toggleFavorite(id, value);
  }

  Future<void> togglePin(String id, bool value) async {
    await _repo.togglePin(id, value);
  }

  Future<void> touchItem(String id) async {
    await _repo.updateLastAccessed(id);
  }
}
