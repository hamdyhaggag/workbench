import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workbench/core/constants/app_colors.dart';
import 'package:workbench/core/constants/app_text_styles.dart';
import 'package:workbench/features/items/domain/entities/item_entity.dart';
import 'package:workbench/features/items/presentation/providers/item_providers.dart';
import 'package:workbench/features/items/presentation/widgets/item_card.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashedAsync = ref.watch(trashedItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🗑️', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Text('المحذوفات', style: AppTextStyles.displayLarge),
                      const Spacer(),
                      // Empty trash button
                      trashedAsync.whenOrNull(
                        data: (items) => items.isNotEmpty
                            ? TextButton.icon(
                                onPressed: () => _confirmEmptyTrash(context, ref, items),
                                icon: const Icon(Icons.delete_forever_rounded, size: 16, color: AppColors.danger),
                                label: Text('مسح الكل', style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger)),
                              )
                            : null,
                      ) ?? const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'العناصر المحذوفة مؤقتاً',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          trashedAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              )),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('خطأ: $e', style: AppTextStyles.bodyMedium)),
            ),
            data: (items) => items.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyTrash())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TrashedItemCard(item: items[i], ref: ref),
                        ),
                        childCount: items.length,
                      ),
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Future<void> _confirmEmptyTrash(BuildContext context, WidgetRef ref, List<ItemEntity> items) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('مسح المحذوفات كلها؟'),
        content: Text(
          'سيتم حذف ${items.length} عنصر نهائياً بدون رجعة',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      for (final item in items) {
        await ref.read(itemNotifierProvider.notifier).deleteItem(item.id, item.projectId);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم مسح ${items.length} عنصر', style: AppTextStyles.bodyMedium)),
        );
      }
    }
  }
}

class _TrashedItemCard extends StatelessWidget {
  final ItemEntity item;
  final WidgetRef ref;
  const _TrashedItemCard({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.65,
          child: ItemCard(item: item),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Row(
            children: [
              _ActionBtn(
                icon: Icons.restore_rounded,
                label: 'استرجاع',
                color: AppColors.success,
                onTap: () async {
                  await ref.read(itemNotifierProvider.notifier).restoreItem(item.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم الاسترجاع ✓', style: AppTextStyles.bodyMedium),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.delete_forever_rounded,
                label: 'حذف نهائي',
                color: AppColors.danger,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.card,
                      title: const Text('حذف نهائي؟'),
                      content: Text('مش هتقدر ترجعه تاني', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(itemNotifierProvider.notifier).deleteItem(item.id, item.projectId);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _EmptyTrash extends StatelessWidget {
  const _EmptyTrash();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Center(
        child: Column(
          children: [
            const Text('🗑️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('المحذوفات فاضية', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('العناصر اللي بتحذفها بتيجي هنا', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
