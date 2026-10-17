import 'package:flutter/material.dart';

/// Reusable badge chip for displaying categories, priorities, and statuses.
class CustomBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isFilled;

  const CustomBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = isFilled ? color : color.withValues(alpha: 0.12);
    final effectiveText = isFilled ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(20),
        border: isFilled
            ? null
            : Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: effectiveText),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: effectiveText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
