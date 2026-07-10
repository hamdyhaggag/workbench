import 'package:flutter/material.dart';
import 'package:workbench/core/constants/app_text_styles.dart';
import 'package:workbench/core/utils/item_utils.dart';
import 'package:workbench/features/items/domain/entities/item_entity.dart';

class ItemTypeBadge extends StatelessWidget {
  final ItemType type;
  final bool compact;

  const ItemTypeBadge({super.key, required this.type, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = ItemUtils.getTypeColor(type);
    final label = ItemUtils.getTypeLabel(type);
    final icon = ItemUtils.getTypeIcon(type);

    if (compact) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 15),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
