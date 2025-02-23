import 'package:flutter/material.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/pages/inventory.dart';
import 'package:my_ice_box/widgets/custom_future_builder.dart';
import 'package:my_ice_box/widgets/dynamic_column.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 기존에 '공간별', '종류별' 두 그룹 선택 옵션
    final categories = ['공간별', '종류별'];
    final tables = ['place', 'category'];
    final table = tables[selectedIndex];

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          // 그룹별로 분류한 카테고리 버튼 영역 (데이터베이스에서 가져옴)
          Expanded(
            child: _CategoryButtons(
              tableForGroupBy: table,
            ),
          ),
          const SizedBox(height: 15),
          // 하단 토글 버튼으로 '공간별', '종류별' 선택
          Align(
            alignment: Alignment.centerLeft,
            child: _CategoryToggle(
              categoryItems: categories,
              onPressed: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryButtons extends StatelessWidget {
  final String tableForGroupBy;

  const _CategoryButtons({
    super.key,
    required this.tableForGroupBy,
  });

  @override
  Widget build(BuildContext context) {
    final column = {
      'place': 'place_name',
      'category': 'category_name',
    }[tableForGroupBy]!;

    return CustomFutureBuilder<PostgrestList>(
      future: context
          .watch<MyAppState>()
          .supabase
          .from(tableForGroupBy)
          .select('*')
          .order(column, ascending: true),
      builder: (context, snapshot) {
        return DynamicColumn(
          spacing: 3,
          children: snapshot.map((record) {
            return ElevatedButton(
              style: ButtonStyle(
                alignment: Alignment.center,
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    side: BorderSide(width: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                foregroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.onPrimary,
                ),
                textStyle: MaterialStateProperty.all(
                  Theme.of(context).textTheme.displaySmall,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryPage(
                      title: record[column],
                    ),
                  ),
                );
              },
              child: Center(
                child: Text(record[column]),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CategoryToggle extends StatefulWidget {
  final List<String> categoryItems;
  final void Function(int) onPressed;

  const _CategoryToggle({
    super.key,
    required this.categoryItems,
    required this.onPressed,
  });

  @override
  State<_CategoryToggle> createState() => _CategoryToggleState();
}

class _CategoryToggleState extends State<_CategoryToggle> {
  var indexSelected = 0;

  @override
  Widget build(BuildContext context) {
    final isSelected = List<bool>.generate(
      widget.categoryItems.length,
          (index) => index == indexSelected,
    );

    return ToggleButtons(
      borderRadius: BorderRadius.circular(4),
      constraints: const BoxConstraints(
        minWidth: 72,
        minHeight: 28,
      ),
      isSelected: isSelected,
      onPressed: (index) => setState(() {
        indexSelected = index;
        widget.onPressed(index);
      }),
      children: [
        for (var item in widget.categoryItems) Text(item),
      ],
    );
  }
}
