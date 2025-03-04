import 'dart:math';
import 'package:flutter/material.dart';

class PairEdgeFlex extends StatelessWidget {
  final List<Widget>? leading;
  final Widget? content;
  final List<Widget>? trailing;

  final double spacing;
  final EdgeInsetsGeometry padding;
  final Axis mainDirection, contentDirection;
  final CrossAxisAlignment crossAxisAlignment;
  final AlignmentGeometry contentAlign;

  const PairEdgeFlex({
    super.key,
    required this.mainDirection,
    required this.contentDirection,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.leading,
    this.content,
    this.trailing,
    this.spacing = 0,
    this.padding = const EdgeInsets.all(0),
    this.contentAlign = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Flex(
        direction: mainDirection,
        crossAxisAlignment: crossAxisAlignment,
        spacing: spacing,
        children: [
          Flex(
            direction: contentDirection,
            mainAxisSize: MainAxisSize.min,
            children: leading ?? []
          ),
          Expanded(
            child: Align(
              alignment: contentAlign,
              child: content ?? SizedBox.shrink()
            ),
          ),
          Flex(
            direction: contentDirection,
            mainAxisSize: MainAxisSize.min,
            children: trailing ?? []
          ),
        ],
      ),
    );
  }
}

class PairEdgeRow extends PairEdgeFlex {
  const PairEdgeRow({
    super.key,
    super.contentDirection = Axis.horizontal,
    super.crossAxisAlignment,
    super.leading,
    super.content,
    super.trailing,
    super.spacing,
    super.padding,
    super.contentAlign,
  }) : super(mainDirection: Axis.horizontal);
}

class PairEdgeColumn extends PairEdgeFlex {
  const PairEdgeColumn({
    super.key,
    super.contentDirection = Axis.vertical,
    super.crossAxisAlignment,
    super.leading,
    super.content,
    super.trailing,
    super.spacing,
    super.padding,
    super.contentAlign,
  }) : super(mainDirection: Axis.vertical);
}

class DynamicFlex extends StatelessWidget {
  final int maxVisibleItems;
  final double spacing;
  final List<Widget> children;

  final Axis direction;

  const DynamicFlex({
    super.key,
    required this.direction,
    this.maxVisibleItems = 4,
    this.spacing = 0,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final numVisibleItems = min(maxVisibleItems, children.length);
        final totalBoxLength = direction == Axis.horizontal ?
          constraints.maxWidth - spacing*numVisibleItems :
          constraints.maxHeight - spacing*numVisibleItems;

        final flexList = Flex(
          direction: direction,
          spacing: spacing,
          children: children.map((item) {
            return SizedBox(
              height: totalBoxLength / numVisibleItems,
              child: item,
            );
          }).toList(),
        );

        if (children.length <= maxVisibleItems) {
          return flexList;
        }
        else {
          return SingleChildScrollView(
            child: flexList,
          );
        }
      },
    );
  }
}

class DynamicRow extends DynamicFlex {
  const DynamicRow({
    super.key,
    super.maxVisibleItems,
    super.spacing,
    required super.children,
  }) : super(direction: Axis.horizontal);
}

class DynamicColumn extends DynamicFlex {
  const DynamicColumn({
    super.key,
    super.maxVisibleItems,
    super.spacing,
    required super.children,
  }) : super(direction: Axis.vertical);
}
