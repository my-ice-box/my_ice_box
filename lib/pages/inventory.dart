import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // const key = String.fromEnvironment("SUPABASE_ANON_KEY");
    const numContainers = 5;

    final maxHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < numContainers; ++i)
              _ItemContainer(),
          ],
        )
      ),
    );
  }
}

class _ItemContainer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    const itemsPerRow = 5;
    const totalItems = 40;

    final maxWidth = MediaQuery.of(context).size.width;
    final itemWidth = maxWidth / itemsPerRow;

    var containerBar = Container(
      width: maxWidth,
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'container of items',
        style: Theme.of(context).textTheme.headlineMedium!,
      ),
    );
    var containerBody = SizedBox(
      width: maxWidth,
      height: itemWidth * (totalItems / itemsPerRow).ceil(),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        itemCount: 40,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(5),
            width: itemWidth,
            height: itemWidth,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ColoredBox(
              color: Colors.teal,
              child: Center(
                child: Text(
                  'item',
                  style: Theme.of(context).textTheme.bodyMedium!,
                ),
              ),
            ),
          );
        },
      ),
    );

    return Column(
      children: [
        containerBar,
        containerBody,
      ],
    );
  }
}