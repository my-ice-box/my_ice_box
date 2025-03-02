import 'package:flutter/material.dart';

class PairEdgeRow extends StatelessWidget {
  final List<Widget>? leading;
  final Widget? content;
  final List<Widget>? trailing;

  const PairEdgeRow({
    super.key,
    this.leading,
    this.content,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: leading ?? []
        ),
        Expanded(
          child: content ?? SizedBox.shrink()
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: trailing ?? []
        ),
      ],
    );
  }
}
