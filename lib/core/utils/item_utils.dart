import 'package:workbench/features/items/domain/entities/item_entity.dart';
import '../constants/app_colors.dart';
import 'package:flutter/material.dart';

class ItemUtils {
  static Color getTypeColor(ItemType type) {
    switch (type) {
      case ItemType.note:
        return AppColors.noteColor;
      case ItemType.prompt:
        return AppColors.promptColor;
      case ItemType.link:
        return AppColors.linkColor;
      case ItemType.account:
        return AppColors.accountColor;
      case ItemType.snippet:
        return AppColors.snippetColor;
      case ItemType.api:
        return AppColors.apiColor;
    }
  }

  static IconData getTypeIcon(ItemType type) {
    switch (type) {
      case ItemType.note:
        return Icons.sticky_note_2_outlined;
      case ItemType.prompt:
        return Icons.psychology_outlined;
      case ItemType.link:
        return Icons.link_rounded;
      case ItemType.account:
        return Icons.lock_outline_rounded;
      case ItemType.snippet:
        return Icons.code_rounded;
      case ItemType.api:
        return Icons.api_outlined;
    }
  }

  static String getTypeLabel(ItemType type) {
    switch (type) {
      case ItemType.note:
        return 'ملاحظة';
      case ItemType.prompt:
        return 'برومبت';
      case ItemType.link:
        return 'لينك';
      case ItemType.account:
        return 'حساب';
      case ItemType.snippet:
        return 'كود';
      case ItemType.api:
        return 'API';
    }
  }

  static String getMethodLabel(String method) {
    return method.toUpperCase();
  }

  static Color getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return AppColors.success;
      case 'POST':
        return AppColors.primary;
      case 'PUT':
        return const Color(0xFF3B82F6);
      case 'PATCH':
        return const Color(0xFF8B5CF6);
      case 'DELETE':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  static String formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'دلوقتي';
    if (diff.inMinutes < 60) return 'من ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'من ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'إمبارح';
    if (diff.inDays < 7) return 'من ${diff.inDays} أيام';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  static String maskPassword(String password) {
    return '•' * password.length.clamp(8, 20);
  }
}
