import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor = AppTheme.accentCyan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glowColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
