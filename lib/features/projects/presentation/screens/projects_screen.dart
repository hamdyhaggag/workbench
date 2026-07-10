import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workbench/core/constants/app_colors.dart';
import 'package:workbench/core/constants/app_text_styles.dart';
import '../providers/project_providers.dart';
import 'package:workbench/features/projects/domain/entities/project_entity.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Row(
                children: [
                  Text('المشاريع', style: AppTextStyles.displayLarge),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateDialog(context, ref),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('مشروع جديد'),
                  ),
                ],
              ),
            ),
          ),
          projectsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              )),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium)),
            ),
            data: (projects) => projects.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyProjects())
                : SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ProjectCard(project: projects[i], ref: ref),
                        childCount: projects.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.3,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _CreateProjectDialog(
        onCreated: (name, emoji) async {
          await ref.read(projectNotifierProvider.notifier).createProject(name: name, emoji: emoji);
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final WidgetRef ref;

  const _ProjectCard({required this.project, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/projects/${project.id}'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(project.emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 18),
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onSelected: (v) async {
                    if (v == 'archive') {
                      await ref.read(projectNotifierProvider.notifier).archiveProject(project.id);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'archive', child: Text('أرشفة')),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(project.name, style: AppTextStyles.headlineMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(project.description, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Text('${project.itemCount} عنصر', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(60),
      child: Center(
        child: Column(
          children: [
            Text('📁', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('مفيش مشاريع لسه', style: AppTextStyles.headlineMedium),
            SizedBox(height: 8),
            Text('ابدأ بإنشاء مشروعك الأول', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _CreateProjectDialog extends StatefulWidget {
  final Function(String name, String emoji) onCreated;
  const _CreateProjectDialog({required this.onCreated});

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _nameCtrl = TextEditingController();
  String _selectedEmoji = '📁';
  final _emojis = ['📁', '🚀', '💡', '🌐', '📱', '⚙️', '🔧', '🎯', '💼', '🏗️', '🌱', '🔬'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('مشروع جديد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji picker
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emojis.map((e) => GestureDetector(
              onTap: () => setState(() => _selectedEmoji = e),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: e == _selectedEmoji ? AppColors.primary : AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                  color: e == _selectedEmoji ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                ),
                child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'اسم المشروع',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.isNotEmpty) {
              widget.onCreated(_nameCtrl.text, _selectedEmoji);
            }
          },
          child: const Text('إنشاء'),
        ),
      ],
    );
  }
}
