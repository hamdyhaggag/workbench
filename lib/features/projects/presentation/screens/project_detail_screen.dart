import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workbench/core/constants/app_colors.dart';
import 'package:workbench/core/constants/app_text_styles.dart';
import 'package:workbench/core/utils/item_utils.dart';
import 'package:workbench/features/items/domain/entities/item_entity.dart';
import '../providers/project_providers.dart';
import 'package:workbench/features/items/presentation/providers/item_providers.dart';
import 'package:workbench/features/items/presentation/widgets/item_card.dart';
import 'package:workbench/core/widgets/quick_add_fab.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  ItemType? _filterType;

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));
    final itemsAsync = ref.watch(projectItemsProvider(widget.projectId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (project) {
          if (project == null) {
            return Center(child: Text('المشروع مش موجود', style: AppTextStyles.bodyMedium));
          }
          return CustomScrollView(
            slivers: [
              // Project Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/projects'),
                            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              ref.invalidate(projectDetailProvider(widget.projectId));
                              ref.invalidate(projectItemsProvider(widget.projectId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تحديث البيانات'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                            tooltip: 'تحديث',
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/add', extra: {
                              'type': ItemType.note,
                              'projectId': widget.projectId,
                            }),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('إضافة'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(project.emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: 10),
                      Text(project.name, style: AppTextStyles.displayLarge),
                      if (project.description.isNotEmpty)
                        Text(project.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text('${project.itemCount} عنصر', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ),

              // Type filter chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'الكل',
                          selected: _filterType == null,
                          onTap: () => setState(() => _filterType = null),
                        ),
                        const SizedBox(width: 8),
                        ...ItemType.values.map((t) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: ItemUtils.getTypeLabel(t),
                            selected: _filterType == t,
                            onTap: () => setState(() => _filterType = _filterType == t ? null : t),
                            icon: ItemUtils.getTypeIcon(t),
                            color: ItemUtils.getTypeColor(t),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),

              // Items
              itemsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                  )),
                ),
                error: (e, _) => SliverToBoxAdapter(child: Text('$e')),
                data: (items) {
                  final filtered = _filterType != null
                      ? items.where((i) => i.type == _filterType).toList()
                      : items;
                  if (filtered.isEmpty) {
                    return const SliverToBoxAdapter(child: _EmptyItems());
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ItemCard(item: filtered[i]),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: QuickAddFab(defaultProjectId: widget.projectId),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const _FilterChip({required this.label, required this.selected, required this.onTap, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: selected ? c : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: selected ? c : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyItems extends StatelessWidget {
  const _EmptyItems();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(60),
      child: Center(
        child: Column(
          children: [
            Text('📭', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('مفيش حاجات لسه', style: AppTextStyles.headlineMedium),
            SizedBox(height: 8),
            Text('اضغط + لإضافة عنصر جديد', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
