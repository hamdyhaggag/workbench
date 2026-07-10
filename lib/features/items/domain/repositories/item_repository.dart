import '../../domain/entities/item_entity.dart';

abstract class ItemRepository {
  Stream<List<ItemEntity>> watchItemsByProject(String projectId, {ItemStatus status});
  Stream<List<ItemEntity>> watchFavorites();
  Stream<List<ItemEntity>> watchPinned();
  Stream<List<ItemEntity>> watchRecent({int limit});
  Future<ItemEntity?> getItem(String id);
  Future<List<ItemEntity>> searchItems(String query);
  Future<void> createItem(ItemEntity item);
  Future<void> updateItem(ItemEntity item);
  Future<void> deleteItem(String id);
  Future<void> archiveItem(String id);
  Future<void> restoreItem(String id);
  Future<void> trashItem(String id);
  Future<void> toggleFavorite(String id, bool value);
  Future<void> togglePin(String id, bool value);
  Future<void> updateLastAccessed(String id);
  Stream<List<ItemEntity>> watchTrashed();
  Stream<List<ItemEntity>> watchArchived();
}
