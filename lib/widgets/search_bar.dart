import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? hintColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const CustomSearchBar({
    Key? key,
    this.hintText = 'Search of Product',
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.hintColor,
    this.borderRadius,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 383,  // dari W Figme
      height: 56, // dari H Figma
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF2E343B),
        borderRadius: BorderRadius.circular(borderRadius ?? 50),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: hintColor ?? Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: iconColor ?? Colors.grey[400],
            size: 20,
          ),
          border: InputBorder.none,

          // padding yang benar
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
        ),
      ),
    );
  }
}
