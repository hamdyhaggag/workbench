import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workbench/core/constants/app_colors.dart';
import 'package:workbench/core/constants/app_text_styles.dart';
import 'package:workbench/core/utils/item_utils.dart';
import 'package:workbench/features/items/domain/entities/item_entity.dart';
import 'package:workbench/features/items/presentation/providers/item_providers.dart';
import 'package:workbench/features/items/presentation/widgets/item_type_badge.dart';

class ItemCard extends ConsumerStatefulWidget {
  final ItemEntity item;
  final bool compact;

  const ItemCard({super.key, required this.item, this.compact = false});

  @override
  ConsumerState<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends ConsumerState<ItemCard> {
  bool _isHovered = false;
  bool _obscurePassword = true;

  String _getCopyLabel() {
    switch (widget.item.type) {
      case ItemType.prompt: return 'نسخ البرومبت';
      case ItemType.link: return 'نسخ اللينك';
      case ItemType.account: return 'نسخ الباسورد';
      case ItemType.snippet: return 'نسخ الكود';
      case ItemType.api: return 'نسخ الـ Endpoint';
      default: return 'نسخ';
    }
  }

  void _copyItem(BuildContext context) {
    String? text;
    switch (widget.item.type) {
      case ItemType.note: text = widget.item.content; break;
      case ItemType.prompt: text = widget.item.promptContent; break;
      case ItemType.link: text = widget.item.url; break;
      case ItemType.account: text = widget.item.encryptedPassword; break;
      case ItemType.snippet: text = widget.item.code; break;
      case ItemType.api: text = widget.item.endpoint; break;
    }
    if (text != null) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Text('اتنسخت', style: AppTextStyles.bodyMedium),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(itemNotifierProvider.notifier);
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          notifier.touchItem(item.id);
          context.push('/items/${item.id}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(0.0, _isHovered ? -3.0 : 0.0, 0.0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? AppColors.primary : AppColors.border,
              width: _isHovered ? 1.2 : 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  ItemTypeBadge(type: item.type, compact: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.push_pin_rounded, size: 14, color: AppColors.primary),
                    ),
                  if (item.isFavorite)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD700)),
                    ),
                  // Direct Copy Action Button
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _isHovered ? 1.0 : 0.4,
                    child: Tooltip(
                      message: _getCopyLabel(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _copyItem(context),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _ItemMoreMenu(item: item, notifier: notifier),
                ],
              ),
              // Preview
              if (!widget.compact) _buildPreview(),
              // Footer
              const SizedBox(height: 8),
              Row(
                children: [
                  ItemTypeBadge(type: item.type),
                  const Spacer(),
                  if (item.tags.isNotEmpty) ...[
                    for (var tag in item.tags.take(2))
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text('#$tag', style: AppTextStyles.caption),
                      ),
                    if (item.tags.length > 2)
                      Text('+${item.tags.length - 2}', style: AppTextStyles.caption),
                  ],
                  const SizedBox(width: 8),
                  Text(
                    ItemUtils.formatDate(item.updatedAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    String preview = '';
    switch (widget.item.type) {
      case ItemType.note:
        preview = widget.item.content ?? '';
        break;
      case ItemType.prompt:
        preview = widget.item.promptContent ?? '';
        break;
      case ItemType.link:
        preview = widget.item.url ?? '';
        break;
      case ItemType.account:
        preview = widget.item.email ?? widget.item.username ?? '';
        break;
      case ItemType.snippet:
        preview = widget.item.code ?? '';
        break;
      case ItemType.api:
        preview = '${widget.item.method ?? 'GET'} ${widget.item.endpoint ?? ''}';
        break;
    }
    
    // Explicit password hide/show for accounts
    if (widget.item.type == ItemType.account) {
      final email = widget.item.email ?? widget.item.username ?? '';
      final password = widget.item.encryptedPassword ?? '';
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email.isNotEmpty)
              Text(
                'الاسم: $email',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _obscurePassword ? '••••••••' : password,
                    style: _obscurePassword
                        ? AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, letterSpacing: 2.0)
                        : AppTextStyles.mono.copyWith(color: AppColors.primary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (preview.isEmpty) return const SizedBox(height: 4);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        preview,
        style: widget.item.type == ItemType.snippet
            ? AppTextStyles.mono.copyWith(color: AppColors.textSecondary, fontSize: 11)
            : AppTextStyles.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ItemMoreMenu extends ConsumerWidget {
  final ItemEntity item;
  final ItemNotifier notifier;

  const _ItemMoreMenu({required this.item, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded, size: 18, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.card,
      onSelected: (v) async {
        switch (v) {
          case 'copy':
            _copyItem(context);
            break;
          case 'pin':
            await notifier.togglePin(item.id, !item.isPinned);
            break;
          case 'favorite':
            await notifier.toggleFavorite(item.id, !item.isFavorite);
            break;
          case 'edit':
            context.push('/items/${item.id}/edit');
            break;
          case 'archive':
            await notifier.archiveItem(item.id);
            break;
          case 'trash':
            await notifier.trashItem(item.id);
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'copy', child: _menuItem(Icons.copy_rounded, _getCopyLabel())),
        PopupMenuItem(value: 'pin', child: _menuItem(
          item.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
          item.isPinned ? 'إلغاء التثبيت' : 'تثبيت',
        )),
        PopupMenuItem(value: 'favorite', child: _menuItem(
          item.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          item.isFavorite ? 'إلغاء المفضلة' : 'مفضلة',
        )),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'edit', child: _menuItem(Icons.edit_outlined, 'تعديل')),
        PopupMenuItem(value: 'archive', child: _menuItem(Icons.archive_outlined, 'أرشفة')),
        PopupMenuItem(
          value: 'trash',
          child: _menuItem(Icons.delete_outline_rounded, 'حذف', color: AppColors.danger),
        ),
      ],
    );
  }

  String _getCopyLabel() {
    switch (item.type) {
      case ItemType.prompt: return 'انسخ البرومبت';
      case ItemType.link: return 'انسخ اللينك';
      case ItemType.account: return 'انسخ الباسورد';
      case ItemType.snippet: return 'انسخ الكود';
      case ItemType.api: return 'انسخ الـ Endpoint';
      default: return 'نسخ';
    }
  }

  void _copyItem(BuildContext context) {
    String? text;
    switch (item.type) {
      case ItemType.note: text = item.content; break;
      case ItemType.prompt: text = item.promptContent; break;
      case ItemType.link: text = item.url; break;
      case ItemType.account: text = item.encryptedPassword; break;
      case ItemType.snippet: text = item.code; break;
      case ItemType.api: text = item.endpoint; break;
    }
    if (text != null) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Text('اتنسخت', style: AppTextStyles.bodyMedium),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      );
    }
  }

  Widget _menuItem(IconData icon, String label, {Color? color}) {
    final c = color ?? AppColors.text;
    return Row(
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: c)),
      ],
    );
  }
}
