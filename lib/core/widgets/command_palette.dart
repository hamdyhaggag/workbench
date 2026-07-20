import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../../features/items/domain/entities/item_entity.dart';
import '../../features/search/presentation/providers/search_providers.dart';
import 'package:workbench/core/utils/item_utils.dart';

class CommandPalette extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  const CommandPalette({super.key, required this.onClose});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final _controller = TextEditingController();
  late final FocusNode _focusNode;
  String _query = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(onKeyEvent: _handleKeyEvent);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowDown) {
        _moveSelection(1);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowUp) {
        _moveSelection(-1);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.enter) {
        _selectCurrentItem();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _moveSelection(int direction) {
    final items = ref.read(searchResultsProvider(_query)).value ?? [];
    if (items.isEmpty) return;
    setState(() {
      _selectedIndex = (_selectedIndex + direction).clamp(0, items.length - 1);
    });
  }

  void _selectCurrentItem() {
    final items = ref.read(searchResultsProvider(_query)).value ?? [];
    if (items.isEmpty) return;
    final index = _selectedIndex.clamp(0, items.length - 1);
    final selectedItem = items[index];
    widget.onClose();
    context.push('/items/${selectedItem.id}');
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider(_query));

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search input
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'دور على أي حاجة...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {
                                      _query = '';
                                      _selectedIndex = 0;
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        onChanged: (v) => setState(() {
                          _query = v;
                          _selectedIndex = 0;
                        }),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    // Results
                    if (_query.isEmpty)
                      _buildEmptyState()
                    else
                      results.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text('حصل خطأ', style: AppTextStyles.bodyMedium),
                        ),
                        data: (items) => items.isEmpty
                            ? _buildNoResults()
                            : _buildResults(items),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 32),
          const SizedBox(height: 12),
          Text('ابدأ الكتابة للبحث', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('هتدور في كل المشاريع والعناصر', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('مفيش نتايج لـ "$_query"', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildResults(List<ItemEntity> items) {
    if (_selectedIndex >= items.length) {
      _selectedIndex = items.isEmpty ? 0 : items.length - 1;
    }

    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
        itemBuilder: (_, i) {
          final item = items[i];
          final isSelected = i == _selectedIndex;

          return Container(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : null,
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ItemUtils.getTypeColor(item.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
                ),
                child: Icon(ItemUtils.getTypeIcon(item.type), color: ItemUtils.getTypeColor(item.type), size: 18),
              ),
              title: Text(
                item.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.text,
                ),
              ),
              subtitle: Text(
                ItemUtils.getTypeLabel(item.type),
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.7) : AppColors.textSecondary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.keyboard_return_rounded, size: 14, color: AppColors.primary)
                  : const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
              onTap: () {
                widget.onClose();
                context.push('/items/${item.id}');
              },
            ),
          );
        },
      ),
    );
  }
}
