import 'package:flutter/material.dart';

class SearchText extends StatelessWidget {
  final String text;
  final int matchedIndex;

  const SearchText({
    super.key,
    required this.text,
    required this.matchedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = DefaultTextStyle.of(context).style;
    final matchedText = text.substring(0, matchedIndex);
    final unmatchedText = text.substring(matchedIndex);

    return RichText(
      text: TextSpan(
        text: matchedText,
        style: textStyle.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: unmatchedText,
            style: textStyle.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}