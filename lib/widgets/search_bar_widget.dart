import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSearch;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Search destination...",
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.clear();
              if (onSearch != null) onSearch!();
            },
          ),
        ),
        onSubmitted: (_) {
          if (onSearch != null) onSearch!();
        },
      ),
    );
  }
}