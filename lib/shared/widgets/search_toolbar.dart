import 'package:flutter/material.dart';

class SearchToolbar extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onSearchChanged;
  final VoidCallback onAdd;

  const SearchToolbar({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onSearchChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
            onChanged: (_) => onSearchChanged(),
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add new'),
        ),
      ],
    );
  }
}
