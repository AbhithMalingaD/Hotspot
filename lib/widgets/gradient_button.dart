import 'package:flutter/material.dart';
import '../theme.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final bool isAdmin;
  final VoidCallback onTap;

  const GradientButton({
    super.key,
    required this.label,
    required this.isAdmin,
    required this.onTap,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.isAdmin
        ? [AppColors.adminAccent, AppColors.adminAccent2]
        : [AppColors.appAccent, AppColors.appAccent2];

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}