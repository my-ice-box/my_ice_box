import 'dart:math';

import 'package:flutter/material.dart';

class DynamicColumn extends StatelessWidget {
  final int maxVisibleItems;
  final double spacing;
  final List<Widget> children;

  const DynamicColumn({
    super.key, 
    this.maxVisibleItems = 4,
    this.spacing = 0,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final numVisibleItems = min(maxVisibleItems, children.length);
        final totalBoxHeight = constraints.maxHeight - spacing*numVisibleItems;
    
        final columnList = Column(
          spacing: spacing,
          children: children.map((item) {
            return SizedBox(
              height: totalBoxHeight / numVisibleItems,
              child: item,
            );
          }).toList(),
        );

        if (children.length <= maxVisibleItems) {
          return columnList;
        }
        else {
          return SingleChildScrollView(
            child: columnList,
          );
        }
      },
    );
  }
}
