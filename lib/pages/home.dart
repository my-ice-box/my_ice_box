import 'package:flutter/material.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/pages/inventory.dart';
import 'package:my_ice_box/pages/search.dart';
import 'package:my_ice_box/widgets/content_bar.dart';
import 'package:my_ice_box/widgets/custom_layout.dart';
import 'package:my_ice_box/widgets/scrolling_text.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final selectedClass = selectedIndex >= 0 ?
      MyAppState.classTable[selectedIndex] : null;

    final searchbarLike = ContentBar(
      content: ScrollingText(
        ["와플?", "핫도그?", "마카롱?", "아이스크림?"],
      ),
      trailing: const [
        Icon(Icons.search),
      ],
      height: 40,
      padding: 5,
      onTap: () => showSearch(context: context, delegate: DataSearch()),
    );
    final toggle = _CategoryToggle(
      categoryItems: MyAppState.classTable.map((e){
        switch(e){
          case 'place': return '공간별';
          case 'category': return '종류별';
          default: return '';
        }
      }).toList(),
      onPressed: (index) => setState((){
        selectedIndex = selectedIndex == index ? -1 : index;
      }),
    );

    return PairEdgeColumn(
      leading: [searchbarLike],
      content: _CategoryButtons(className: selectedClass),
      trailing: [toggle],
      spacing: 15,
      padding: const EdgeInsets.all(15),
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

class _CategoryButtons extends StatelessWidget {
  final String? className;

  const _CategoryButtons({
    this.className,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    // final column = {
    //   'place': 'place_name',
    //   'category': 'category_name',
    // }[tableForGroupBy]!;

    final classMembers = className == 'place' ? appState.places :
      className == 'category' ? appState.categories : null;
    final classColumn = className == 'place' ? 'place_name' :
      className == 'category' ? 'category_name' : null;

    void gotoClassMember(String? memberName) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InventoryPage(
            title: memberName ?? '재고 처리',
            columnToGroupBy: className == 'place' ? 'category_name' :
              className == 'category' ? 'place_name' : 'expiration_date',
            items: appState.items.where((e) {
              if(memberName == null) return true;
              return e[classColumn] == memberName;
            }).toList()
          ),
        ),
      );
    }

    /// ButtonStyle of CategoryButton
    final buttonStyle = ButtonStyle(
      alignment: Alignment.center,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          side: BorderSide(width: 0.2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      foregroundColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.onPrimary,
      ),
      textStyle: WidgetStateProperty.all(
        Theme.of(context).textTheme.displaySmall,
      )
    );

    final classMemberButtons = classMembers?.map((record) {
      return ElevatedButton(
        style: buttonStyle,
        onPressed: () => gotoClassMember(record[classColumn]),
        child: Center(
          child: Text(record[classColumn]),
        ),
      );
    }).toList();

    return DynamicColumn(
      spacing: 3,
      children: classMemberButtons ?? [
        ElevatedButton(
          style: buttonStyle,
          onPressed: () => gotoClassMember(null),
          child: Center(
            child: Text('전체 보기'),
          ),
        ),
      ],
    );

    // return CustomFutureBuilder<PostgrestList>(
    //   future: context
    //     .watch<MyAppState>()
    //     .supabase
    //     .from(tableForGroupBy)
    //     .select('*')
    //     .order(column, ascending: true),
    //   builder: (context, snapshot) {
    //     final categoryButtons = snapshot.map((record) {
    //       return ElevatedButton(
    //         style: buttonStyle,
    //         onPressed: () => gotoCategory(record[column]),
    //         child: Center(
    //           child: Text(record[column]),
    //         ),
    //       );
    //     }).toList();

    //     return DynamicColumn(
    //       spacing: 3,
    //       children: categoryButtons,
    //     );
    //   },
    // );
  }
}

class _CategoryToggle extends StatefulWidget {
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
  var indexSelected = -1;

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
        indexSelected = index==indexSelected ? -1 : index;
        widget.onPressed(index);
      }),
      children: [
        for (var item in widget.categoryItems) Text(item),
      ],
    );
  }
}
