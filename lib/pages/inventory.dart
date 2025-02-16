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
    // "재고 처리" 탭은 유효기간이 임박했거나 지난 항목만 필터링
    if (title == '재고 처리') {
      // nearExpiryThreshold: 현재부터 3일 이내의 유통기한
      final threshold = DateTime.now().add(const Duration(days: 3)).toIso8601String();

      return CustomFutureBuilder<PostgrestList>(
        future: context.watch<MyAppState>().supabase.from('items')
            .select('*, ...ingredient!inner(*)')
            .lte('expiration_date', threshold),
        builder: (context, snapshot) {
          // 각 항목의 유효기간을 확인해 "만료됨" 또는 "임박" 그룹으로 나눕니다.
          final groupedData = groupBy(snapshot, (item) {
            final expDate = DateTime.parse(item['expiration_date']);
            return expDate.isBefore(DateTime.now()) ? '만료됨' : '임박';
          });
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: SingleChildScrollView(
              child: Column(
                children: groupedData.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ItemContainerBar(title: entry.key),
                    _ItemContainerBody(items: entry.value),
                  ],
                )).toList(),
              ),
            ),
          );
        },
      );
    } else {
      // 기존의 냉동실, 냉장실, 미분류, 채소 등 다른 카테고리 처리
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
        },
      );
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 5),
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
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: itemsPerRow,
      children: [
        for (var item in items)
          Container(
            padding: const EdgeInsets.all(5),
            height: itemWidth,
            decoration: BoxDecoration(
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
