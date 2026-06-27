import 'package:flutter/material.dart';

class GameButton extends StatelessWidget {
  const GameButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.compact = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null
          ? const SizedBox.shrink()
          : Icon(icon, size: compact ? 18 : 22),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: FilledButton.styleFrom(
        minimumSize: Size(compact ? 112 : 168, compact ? 42 : 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(
          fontSize: compact ? 14 : 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
