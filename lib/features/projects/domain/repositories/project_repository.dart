import '../../domain/entities/project_entity.dart';

abstract class ProjectRepository {
  Stream<List<ProjectEntity>> watchProjects();
  Future<ProjectEntity?> getProject(String id);
  Future<void> createProject(ProjectEntity project);
  Future<void> updateProject(ProjectEntity project);
  Future<void> deleteProject(String id);
  Future<void> archiveProject(String id);
  Future<void> restoreProject(String id);
  Future<void> incrementItemCount(String projectId);
  Future<void> decrementItemCount(String projectId);
}
