import 'package:flutter/material.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_card.dart';

class PlaceholderModulePage extends StatelessWidget {
  final String title;
  const PlaceholderModulePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: title,
          subtitle: 'Module architecture is ready. Business implementation comes in the next build phase.',
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SectionCard(
            child: Center(
              child: Text(
                '$title module is prepared inside the architecture and ready for full business logic.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
