import 'package:flutter/material.dart';

class ListTileItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ListTileItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
