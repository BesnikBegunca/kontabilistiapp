import 'package:flutter/material.dart';

class MetricBarChart extends StatelessWidget {
  final List<MetricBarItem> items;
  final String title;
  final String subtitle;

  const MetricBarChart({
    super.key,
    required this.items,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = items.isEmpty ? 1.0 : items.map((e) => e.value).reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
            const SizedBox(height: 22),
            ...items.map((item) {
              final factor = item.value / maxValue;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    SizedBox(width: 120, child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: factor.isNaN ? 0 : factor,
                          minHeight: 14,
                          backgroundColor: const Color(0xFFEAF0FA),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: Text(item.displayValue, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class MetricBarItem {
  final String label;
  final double value;
  final String displayValue;

  const MetricBarItem({
    required this.label,
    required this.value,
    required this.displayValue,
  });
}
