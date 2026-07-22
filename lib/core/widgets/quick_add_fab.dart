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
  late Animation<double> _expandAnimation;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _expandAnimation = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _anim.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggle() {
    if (_open) {
      _anim.reverse().then((_) {
        _removeOverlay();
      });
      setState(() => _open = false);
    } else {
      setState(() => _open = true);
      _showOverlay();
      _anim.forward();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Dark Backdrop Scrim (tapping outside dismisses menu)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                behavior: HitTestBehavior.opaque,
                child: AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, _) => Container(
                    color: Colors.black.withValues(alpha: 0.45 * _expandAnimation.value),
                  ),
                ),
              ),
            ),

            // Speed Dial Options Column
            Positioned(
              left: isRtl ? 16 : null,
              right: isRtl ? null : 16,
              bottom: (MediaQuery.of(context).size.height - offset.dy) + 12,
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _expandAnimation,
                    child: ScaleTransition(
                      scale: _expandAnimation,
                      alignment: isRtl ? Alignment.bottomLeft : Alignment.bottomRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FabOption(label: 'ملاحظة', emoji: '📝', onTap: () => _navigate(ItemType.note)),
                          _FabOption(label: 'برومبت', emoji: '💻', onTap: () => _navigate(ItemType.prompt)),
                          _FabOption(label: 'لينك', emoji: '🔗', onTap: () => _navigate(ItemType.link)),
                          _FabOption(label: 'حساب', emoji: '🔑', onTap: () => _navigate(ItemType.account)),
                          _FabOption(label: 'كود', emoji: '📄', onTap: () => _navigate(ItemType.snippet)),
                          _FabOption(label: 'API', emoji: '🌐', onTap: () => _navigate(ItemType.api)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
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
    return FloatingActionButton(
      onPressed: _toggle,
      backgroundColor: _open ? AppColors.card : AppColors.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _open ? AppColors.border : Colors.transparent,
          width: 1,
        ),
      ),
      child: AnimatedRotation(
        turns: _open ? 0.125 : 0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _open ? Icons.close_rounded : Icons.add_rounded,
          color: _open ? AppColors.text : AppColors.background,
          size: 26,
        ),
      ),
    );
  }
}

class _FabOption extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;

  const _FabOption({
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
