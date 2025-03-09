import 'package:flutter/material.dart';
import 'package:my_ice_box/widgets/custom_layout.dart';

class ContentBar extends StatelessWidget {
  final double height;
  final double padding;
  final double elevation;

  final List<Widget>? leading;
  final Widget content;
  final List<Widget>? trailing;

  final void Function()? onTap;

  const ContentBar({
    super.key,
    this.leading,
    required this.content,
    this.trailing,
    required this.height,
    this.padding = 0,
    this.elevation = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// ContentBar의 둥근 외곽 반지름
    final radius = height/2;
    final borderRadius = BorderRadius
      .circular(radius);
    /// ContentBar의 모양
    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: BorderSide(
        color: Theme.of(context).primaryColor,
      )
    );

    /// widget 배치
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
        shape: shape,
        elevation: elevation,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: row,
        ),
      ),
    );
  }
}