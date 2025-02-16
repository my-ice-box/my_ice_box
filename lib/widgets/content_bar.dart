import 'package:flutter/material.dart';

class ContentBar extends StatelessWidget {
  final double height;
  final double padding;
  final double elevation;
  final bool useAbsoluteSize;

  final List<Widget>? leading;
  final Widget content;
  final List<Widget>? trailing;

  const ContentBar({
    super.key,
    this.height = 40,
    this.padding = 5,
    this.elevation = 0,
    this.useAbsoluteSize = false,
    this.leading,
    required this.content,
    this.trailing = const [
      Icon(Icons.search),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final radius = height/2;
    final borderRadius = BorderRadius
      .circular(radius);

    final sizedContent = useAbsoluteSize ?
      content : 
      FittedBox(
        fit: BoxFit.fitHeight,
        child: content
      );
    final row = Row(
      children: [
        ...?leading,
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: sizedContent,
          ),
        ),
        ...?trailing,
      ],
    );

    return SizedBox(
      height: height,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: Colors.blue,
          )
        ),
        elevation: elevation,
        child: InkWell(
          onTap: () {},
          borderRadius: borderRadius,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(
              horizontal: radius,
              vertical: padding,
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}