import 'package:flutter/material.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/pages/inventory.dart';
import 'package:my_ice_box/pages/search_v2.dart';
import 'package:my_ice_box/widgets/custom_future_builder.dart';
import 'package:my_ice_box/widgets/content_bar.dart';
import 'package:my_ice_box/widgets/custom_layout.dart';
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
  String? expiryFilter;

  @override
  Widget build(BuildContext context) {
    final categories = ['공간별', '종류별', '기간별'];
    final tables = ['place', 'category', 'expiry'];
    final table = tables[selectedIndex];

    final searchbarLike = ContentBar(
      content: ScrollingText(["와플?", "핫도그?", "마카롱?", "아이스크림?"]),
      trailing: const [Icon(Icons.search)],
      height: 40,
      padding: 5,
      onTap: () => showSearch(context: context, delegate: DataSearch()),
    );

    Widget categoryTable;

    if (table == 'expiry') {
      if (expiryFilter == null) {
        categoryTable = Expanded(
          child: DynamicColumn(
            spacing: 3,
            children: [
              ElevatedButton(
                style: _buttonStyle(context),
                onPressed: () => setState(() => expiryFilter = '유효기한 임박 품목'),
                child: const Text('유효기한 임박 품목'),
              ),
              ElevatedButton(
                style: _buttonStyle(context),
                onPressed: () => setState(() => expiryFilter = '유효기한 지난 품목'),
                child: const Text('유효기한 지난 품목'),
              ),
            ],
          ),
        );
      } else {
        categoryTable = Expanded(
          child: _ExpiryItems(expiryStatus: expiryFilter!),
        );
      }
    } else {
      categoryTable = Expanded(
        child: _CategoryButtons(tableForGroupBy: table),
      );
    }

    final toggle = _CategoryToggle(
      categoryItems: categories,
      onPressed: (index) => setState(() {
        selectedIndex = index;
        expiryFilter = null;
      }),
    );

    return PairEdgeColumn(
      leading: [searchbarLike],
      content: categoryTable,
      trailing: [toggle],
      spacing: 15,
      padding: const EdgeInsets.all(15),
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ButtonStyle(
      alignment: Alignment.center,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          side: const BorderSide(width: 0.2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      foregroundColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.onPrimary,
      ),
      textStyle: WidgetStateProperty.all(
        Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}

class _CategoryButtons extends StatelessWidget {
  final String tableForGroupBy;

  const _CategoryButtons({super.key, required this.tableForGroupBy});

  @override
  Widget build(BuildContext context) {
    final column = {
      'place': 'place_name',
      'category': 'category_name',
    }[tableForGroupBy]!;

    final buttonStyle = ButtonStyle(
      alignment: Alignment.center,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          side: const BorderSide(width: 0.2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      foregroundColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.onPrimary,
      ),
      textStyle: WidgetStateProperty.all(
        Theme.of(context).textTheme.displaySmall,
      ),
    );

    void gotoCategory(String categoryName) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InventoryPage(title: categoryName)),
      );
    }

    return CustomFutureBuilder<PostgrestList>(
      future: context.watch<MyAppState>().supabase
          .from(tableForGroupBy)
          .select('*')
          .order(column, ascending: true),
      builder: (context, snapshot) {
        final categoryButtons = snapshot.map((record) {
          return ElevatedButton(
            style: buttonStyle,
            onPressed: () => gotoCategory(record[column]),
            child: Center(child: Text(record[column])),
          );
        }).toList();

        return DynamicColumn(spacing: 3, children: categoryButtons);
      },
    );
  }
}

class _ExpiryItems extends StatelessWidget {
  final String expiryStatus;

  const _ExpiryItems({super.key, required this.expiryStatus});

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      alignment: Alignment.center,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          side: const BorderSide(width: 0.2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      foregroundColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.onPrimary,
      ),
      textStyle: WidgetStateProperty.all(
        Theme.of(context).textTheme.displaySmall,
      ),
    );

    void gotoItem(String itemName) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InventoryPage(title: itemName)),
      );
    }

    return CustomFutureBuilder<PostgrestList>(
      future: context.watch<MyAppState>().supabase
          .from('expiry')
          .select('*')
          .eq('expiry_name', expiryStatus)
          .order('expiration_date', ascending: true),
      builder: (context, snapshot) {
        final expiryItems = snapshot.map((record) {
          final displayText = "${record['ingredient_name']} (${record['expiration_date']})";
          return ElevatedButton(
            style: buttonStyle,
            onPressed: () => gotoItem(displayText),
            child: Center(child: Text(displayText)),
          );
        }).toList();

        return DynamicColumn(spacing: 3, children: expiryItems);
      },
    );
  }
}

class _CategoryToggle extends StatefulWidget {
  final List<String> categoryItems;
  final void Function(int) onPressed;

  const _CategoryToggle({super.key, required this.categoryItems, required this.onPressed});

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
      constraints: const BoxConstraints(minWidth: 72, minHeight: 28),
      isSelected: isSelected,
      onPressed: (index) => setState(() {
        indexSelected = index;
        widget.onPressed(index);
      }),
      children: [for (var item in widget.categoryItems) Text(item)],
    );
  }
}
