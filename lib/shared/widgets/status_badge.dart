import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  const StatusBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    Color bg;
    Color fg;

    if (lower == 'paid') {
      bg = const Color(0xFFE9F9EF);
      fg = const Color(0xFF1A7F37);
    } else if (lower.contains('partial')) {
      bg = const Color(0xFFFFF4E5);
      fg = const Color(0xFFB26A00);
    } else if (lower.contains('cancel')) {
      bg = const Color(0xFFFFECEC);
      fg = const Color(0xFFC62828);
    } else if (lower.contains('draft')) {
      bg = const Color(0xFFF1F3F8);
      fg = const Color(0xFF5F6B7A);
    } else {
      bg = const Color(0xFFEAF1FF);
      fg = const Color(0xFF1F5EFF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12.5),
      ),
    );
  }
}
