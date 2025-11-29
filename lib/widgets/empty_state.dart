import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String text;

  const EmptyStateWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }
}
