import 'package:flutter/material.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/widgets/custom_future_builder.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collection/collection.dart';

class InventoryPage extends StatelessWidget {
  final String title;

  const InventoryPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final column = {
      '냉동실': 'place_name',
      '냉장실': 'place_name',
      '(미분류)': 'place_name',
      '채소': 'ingredient.category_name',
      '육류': 'ingredient.category_name',
      '과일': 'ingredient.category_name',
      '유제품': 'ingredient.category_name',
    }[title]!;

    return CustomFutureBuilder<PostgrestList>(
      future: context.watch<MyAppState>().supabase.from('items')
        .select('*, ...ingredient!inner(*)')
        .eq(column, title),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: SingleChildScrollView(
            child: Column(
              children: groupBy(
                snapshot,
                (item) => item[{
                  'place_name': 'category_name',
                  'ingredient.category_name': 'place_name',
                }[column]!]
              ).entries.map(
                (entry) => Column(
                  children: [
                    _ItemContainerBar(title: entry.key as String),
                    _ItemContainerBody(items: entry.value),
                  ],
                ),
              ).toList(),
            ),
          ),
        );
      }
    );
  }
}

class _ItemContainerBar extends StatelessWidget {
  final String title;

  const _ItemContainerBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;

    return Container(
      width: maxWidth,
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(title),
    );
  }
}

class _ItemContainerBody extends StatelessWidget {
  final PostgrestList items;

  const _ItemContainerBody({required this.items});
  
  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;

    const itemsPerRow = 5;
    final itemWidth = maxWidth / itemsPerRow;

    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: itemsPerRow,
      children: [
        for (var item in items)
          Container(
            padding: EdgeInsets.all(5),
            height: itemWidth,
            decoration: BoxDecoration(
              // color: Theme.of(context).primaryColorLight,
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item['ingredient_name']),
            ),
          ),
      ],
    );
  }
}