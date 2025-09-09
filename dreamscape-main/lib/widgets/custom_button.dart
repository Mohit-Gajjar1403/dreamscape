// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onPressed; // nullable enables disabled state
  final Widget? leading; // optional spinner or icon

  const CustomButton({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.padding,
    this.onPressed,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          disabledBackgroundColor: backgroundColor, // keeps dimmed color passed in
        ),
        child: child,
      ),
    );
  }
}
