import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/repositories/project_repository_impl.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

final projectsStreamProvider = StreamProvider<List<ProjectEntity>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.watchProjects();
});

final projectDetailProvider = StreamProvider.family<ProjectEntity?, String>((ref, id) {
  final repo = ref.watch(projectRepositoryProvider);
  return Stream.fromFuture(repo.getProject(id));
});

final projectNotifierProvider = AsyncNotifierProvider<ProjectNotifier, void>(ProjectNotifier.new);

class ProjectNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  ProjectRepository get _repo => ref.read(projectRepositoryProvider);

  Future<String> createProject({
    required String name,
    String description = '',
    String emoji = '📁',
    String color = '#E3B119',
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final project = ProjectEntity(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.createProject(project);
    return id;
  }

  Future<void> updateProject(ProjectEntity project) async {
    await _repo.updateProject(project.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteProject(String id) async {
    await _repo.deleteProject(id);
  }

  Future<void> archiveProject(String id) async {
    await _repo.archiveProject(id);
  }

  Future<void> restoreProject(String id) async {
    await _repo.restoreProject(id);
  }
}
