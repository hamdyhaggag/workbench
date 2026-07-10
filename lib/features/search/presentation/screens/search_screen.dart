import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workbench/core/constants/app_colors.dart';
import 'package:workbench/core/constants/app_text_styles.dart';
import 'package:workbench/core/utils/item_utils.dart';
import 'package:workbench/features/items/domain/entities/item_entity.dart';
import 'package:workbench/features/items/presentation/providers/item_providers.dart';
import 'package:workbench/features/items/presentation/widgets/item_type_badge.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  ItemType? _filterType;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentAsync = ref.watch(recentItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('البحث', style: AppTextStyles.displayLarge),
                  const SizedBox(height: 20),
                  // Search field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _query.isNotEmpty ? AppColors.primary : AppColors.border),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'دور على أي حاجة...',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 20),
                                onPressed: () {
                                  _ctrl.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TypeChip(
                          label: 'الكل',
                          selected: _filterType == null,
                          onTap: () => setState(() => _filterType = null),
                        ),
                        const SizedBox(width: 8),
                        ...ItemType.values.map((t) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _TypeChip(
                            label: ItemUtils.getTypeLabel(t),
                            selected: _filterType == t,
                            icon: ItemUtils.getTypeIcon(t),
                            color: ItemUtils.getTypeColor(t),
                            onTap: () => setState(() => _filterType = _filterType == t ? null : t),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Results
          if (_query.isEmpty)
            recentAsync.when(
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (items) {
                final filtered = _filterType != null ? items.where((i) => i.type == _filterType).toList() : items;
                if (filtered.isEmpty) return const SliverToBoxAdapter(child: _EmptySearch());
                return _ResultsList(
                  title: 'الأخيرة',
                  items: filtered,
                );
              },
            )
          else
            recentAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                )),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (allItems) {
                // Client-side search
                final q = _query.toLowerCase();
                var results = allItems.where((item) {
                  return item.title.toLowerCase().contains(q) ||
                      (item.content?.toLowerCase().contains(q) ?? false) ||
                      (item.promptContent?.toLowerCase().contains(q) ?? false) ||
                      (item.url?.toLowerCase().contains(q) ?? false) ||
                      (item.code?.toLowerCase().contains(q) ?? false) ||
                      (item.endpoint?.toLowerCase().contains(q) ?? false) ||
                      item.tags.any((tag) => tag.toLowerCase().contains(q));
                }).toList();

                if (_filterType != null) {
                  results = results.where((i) => i.type == _filterType).toList();
                }

                if (results.isEmpty) {
                  return SliverToBoxAdapter(child: _NoResults(query: _query));
                }
                return _ResultsList(
                  title: '${results.length} نتيجة',
                  items: results,
                  query: _query,
                );
              },
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final String title;
  final List<ItemEntity> items;
  final String? query;
  const _ResultsList({required this.title, required this.items, this.query});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(title, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
              );
            }
            final item = items[i - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SearchResultCard(item: item, query: query),
            );
          },
          childCount: items.length + 1,
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final ItemEntity item;
  final String? query;
  const _SearchResultCard({required this.item, this.query});

  String _getSubtitle() {
    switch (item.type) {
      case ItemType.note:
        return item.content ?? '';
      case ItemType.prompt:
        return item.promptContent ?? '';
      case ItemType.link:
        return item.url ?? '';
      case ItemType.account:
        return item.website ?? item.email ?? '';
      case ItemType.snippet:
        return item.codeLanguage != null ? '${item.codeLanguage} snippet' : '';
      case ItemType.api:
        return '${item.method ?? 'GET'} ${item.endpoint ?? ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = ItemUtils.getTypeColor(item.type);
    final subtitle = _getSubtitle();

    return GestureDetector(
      onTap: () => context.go('/items/${item.id}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(ItemUtils.getTypeIcon(item.type), color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            ItemTypeBadge(type: item.type),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  const _TypeChip({required this.label, required this.selected, required this.onTap, this.icon, this.color});

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
            Text(label, style: AppTextStyles.labelSmall.copyWith(
              color: selected ? c : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Center(
        child: Column(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('دور على أي حاجة', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('ملاحظة، برومبت، كود، حساب...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Center(
        child: Column(
          children: [
            const Text('😶', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('مفيش نتايج لـ "$query"', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('جرب كلمات تانية', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
