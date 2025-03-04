import 'package:flutter/material.dart';
import 'package:my_ice_box/widgets/custom_layout.dart';

class ContentBar extends StatelessWidget {
  final double height;
  final double padding;
  final double elevation;

  final List<Widget>? leading;
  final Widget content;
  final List<Widget>? trailing;

  const ContentBar({
    super.key,
    this.leading,
    required this.content,
    this.trailing,
    required this.height,
    this.padding = 0,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = height/2;
    final borderRadius = BorderRadius
      .circular(radius);

    final row = PairEdgeRow(
      leading: leading,
      content: content,
      trailing: trailing,
      contentAlign: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
        horizontal: radius,
        vertical: padding,
      ),
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
            child: row,
        ),
      ),
    );
  }
}