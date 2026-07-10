import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workbench/features/items/domain/entities/item_entity.dart';
import 'package:workbench/features/items/data/repositories/item_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.family<List<ItemEntity>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repo = ItemRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
  return repo.searchItems(query.trim());
});

final activeSearchProvider = StateProvider<bool>((ref) => false);
