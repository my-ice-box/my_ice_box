import 'package:flutter/material.dart';

class TextPlaceholder extends StatelessWidget {
  final String text;

  const TextPlaceholder({
    super.key,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Center(
        child: Text(text)
      ),
    );
  }
}