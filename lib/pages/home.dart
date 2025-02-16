import 'package:flutter/material.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/pages/inventory.dart';
import 'package:my_ice_box/widgets/custom_future_builder.dart';
import 'package:my_ice_box/widgets/dynamic_column.dart';
import 'package:my_ice_box/widgets/content_bar.dart';
import 'package:my_ice_box/widgets/scrolling_text.dart';
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
    final categories = ['공간별',    '종류별'];
    final     tables = [ 'place', 'category'];

    final table = tables[selectedIndex];

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 15,
        children: <Widget>[
          ContentBar(
            content: ScrollingText(),
            // content: Text(
            //   '와플? 핫도그? 마카롱?',
            // ),
          ),
          Expanded(
            child: _CategoryButtons(
              tableForGroupBy: table,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _CategoryToggle(
              categoryItems: categories,
              onPressed: (index){ setState(() {
                selectedIndex = index;
              });},
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
    required this.tableForGroupBy,
  });

  @override
  Widget build(BuildContext context) {
    final column = {
      'place': 'place_name',
      'category': 'category_name',
    }[tableForGroupBy]!;

    return CustomFutureBuilder<PostgrestList>(
      future: context.watch<MyAppState>().supabase
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
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    side: BorderSide(width: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                foregroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onPrimary
                ),
                textStyle: WidgetStateProperty.all(
                  TextTheme.of(context).displaySmall
                ),
              ),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryPage(
                      title: record[column],
                    )
                  ),
                );
              },
              child: Center(
                child: Text(record[column]),
              ),
            );
          }).toList(),
        );
      }
    );
  }
}

class _CategoryToggle extends StatefulWidget{
  final List<String> categoryItems;
  final void Function(int) onPressed;

  const _CategoryToggle({
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
      (index) => index == indexSelected
    );

    return ToggleButtons(
      borderRadius: BorderRadius.circular(4),
      constraints: const BoxConstraints(
        minWidth: 72,
        minHeight: 28,
      ),
      isSelected: isSelected,
      onPressed: (index) => setState((){
        indexSelected = index;
        widget.onPressed(index);
      }),
      children: [
        for (var item in widget.categoryItems)
          Text(item),
      ],
    );
  }
}
