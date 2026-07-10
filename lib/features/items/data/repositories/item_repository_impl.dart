import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ItemRepositoryImpl(this._firestore, this._auth);

  String get _uid => _auth.currentUser!.uid;
  CollectionReference get _col => _firestore.collection('users').doc(_uid).collection('items');

  @override
  Stream<List<ItemEntity>> watchItemsByProject(String projectId, {ItemStatus status = ItemStatus.active}) {
    return _col
        .where('projectId', isEqualTo: projectId)
        .where('status', isEqualTo: status.name)
        .orderBy('isPinned', descending: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ItemModel.fromFirestore(d)).toList());
  }

  @override
  Stream<List<ItemEntity>> watchFavorites() {
    return _col
        .where('isFavorite', isEqualTo: true)
        .where('status', isEqualTo: ItemStatus.active.name)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ItemModel.fromFirestore(d)).toList());
  }

  @override
  Stream<List<ItemEntity>> watchPinned() {
    return _col
        .where('isPinned', isEqualTo: true)
        .where('status', isEqualTo: ItemStatus.active.name)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ItemModel.fromFirestore(d)).toList());
  }

  @override
  Stream<List<ItemEntity>> watchRecent({int limit = 10}) {
    return _col
        .where('status', isEqualTo: ItemStatus.active.name)
        .orderBy('lastAccessedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => ItemModel.fromFirestore(d)).toList());
  }

  @override
  Future<ItemEntity?> getItem(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return ItemModel.fromFirestore(doc);
  }

  @override
  Future<List<ItemEntity>> searchItems(String query) async {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    // Client-side search after fetching active items
    final snapshot = await _col
        .where('status', isEqualTo: ItemStatus.active.name)
        .orderBy('updatedAt', descending: true)
        .get();
    final all = snapshot.docs.map((d) => ItemModel.fromFirestore(d)).toList();
    return all.where((item) => item.searchableContent.contains(q)).toList();
  }

  @override
  Future<void> createItem(ItemEntity item) async {
    final model = ItemModel.fromEntity(item);
    await _col.doc(item.id).set(model.toFirestore());
  }

  @override
  Future<void> updateItem(ItemEntity item) async {
    final model = ItemModel.fromEntity(item);
    await _col.doc(item.id).update({
      ...model.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteItem(String id) async {
    await _col.doc(id).delete();
  }

  @override
  Future<void> archiveItem(String id) async {
    await _col.doc(id).update({
      'status': ItemStatus.archived.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreItem(String id) async {
    await _col.doc(id).update({
      'status': ItemStatus.active.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> trashItem(String id) async {
    await _col.doc(id).update({
      'status': ItemStatus.trashed.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> toggleFavorite(String id, bool value) async {
    await _col.doc(id).update({'isFavorite': value});
  }

  @override
  Future<void> togglePin(String id, bool value) async {
    await _col.doc(id).update({'isPinned': value});
  }

  @override
  Future<void> updateLastAccessed(String id) async {
    await _col.doc(id).update({
      'lastAccessedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<ItemEntity>> watchTrashed() {
    return _col
        .where('status', isEqualTo: ItemStatus.trashed.name)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ItemModel.fromFirestore(d)).toList());
  }

  @override
  Stream<List<ItemEntity>> watchArchived() {
    return _col
        .where('status', isEqualTo: ItemStatus.archived.name)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ItemModel.fromFirestore(d)).toList());
  }
}
