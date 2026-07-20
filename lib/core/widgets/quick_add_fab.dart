import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../../features/items/domain/entities/item_entity.dart';

class QuickAddFab extends StatefulWidget {
  final String? defaultProjectId;
  const QuickAddFab({super.key, this.defaultProjectId});

  @override
  State<QuickAddFab> createState() => _QuickAddFabState();
}

class _QuickAddFabState extends State<QuickAddFab> with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  void _navigate(ItemType type) {
    _toggle();
    context.push('/add', extra: {
      'type': type,
      'projectId': widget.defaultProjectId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_open) ...[
          _FabOption(label: 'ملاحظة', emoji: '📝', onTap: () => _navigate(ItemType.note)),
          _FabOption(label: 'برومبت', emoji: '💻', onTap: () => _navigate(ItemType.prompt)),
          _FabOption(label: 'لينك', emoji: '🔗', onTap: () => _navigate(ItemType.link)),
          _FabOption(label: 'حساب', emoji: '🔑', onTap: () => _navigate(ItemType.account)),
          _FabOption(label: 'كود', emoji: '📄', onTap: () => _navigate(ItemType.snippet)),
          _FabOption(label: 'API', emoji: '🌐', onTap: () => _navigate(ItemType.api)),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: _open ? AppColors.border : AppColors.primary,
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(_open ? Icons.close_rounded : Icons.add_rounded,
                color: _open ? AppColors.text : AppColors.background),
          ),
        ),
      ],
    );
  }
}

class _FabOption extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;

  const _FabOption({required this.label, required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(label, style: AppTextStyles.labelLarge),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
          ),
        ],
      ),
    );
  }
}
