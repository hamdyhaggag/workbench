import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProjectRepositoryImpl(this._firestore, this._auth);

  String get _uid => _auth.currentUser!.uid;
  CollectionReference get _col => _firestore.collection('users').doc(_uid).collection('projects');

  @override
  Stream<List<ProjectEntity>> watchProjects() {
    return _col
        .where('isArchived', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ProjectModel.fromFirestore(d)).toList());
  }

  @override
  Future<ProjectEntity?> getProject(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return ProjectModel.fromFirestore(doc);
  }

  @override
  Future<void> createProject(ProjectEntity project) async {
    final model = ProjectModel.fromEntity(project);
    await _col.doc(project.id).set(model.toFirestore());
  }

  @override
  Future<void> updateProject(ProjectEntity project) async {
    final model = ProjectModel.fromEntity(project);
    await _col.doc(project.id).update({
      ...model.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteProject(String id) async {
    await _col.doc(id).delete();
  }

  @override
  Future<void> archiveProject(String id) async {
    await _col.doc(id).update({
      'isArchived': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreProject(String id) async {
    await _col.doc(id).update({
      'isArchived': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> incrementItemCount(String projectId) async {
    await _col.doc(projectId).update({
      'itemCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> decrementItemCount(String projectId) async {
    await _col.doc(projectId).update({
      'itemCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
