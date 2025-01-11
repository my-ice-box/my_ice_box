import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ice_box/pages/inventory.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedCategoryName = '공간별';

  @override
  Widget build(BuildContext context) {
    var categories = {
      '공간별': {
        'majorColor': Colors.blue.shade200,
        'minorColor': Colors.blue.shade100,
        'pages': {
          '냉동고': InventoryPage(),
          '냉장고': Placeholder(),
          '이외...': Placeholder(),
        },
      },
      '종류별': {
        'majorColor': Colors.amber.shade200,
        'minorColor': Colors.amber.shade100,
        'pages': {
          '채소류': Placeholder(),
          '고기류': Placeholder(),
          '과일류': Placeholder(),
          '유제품': Placeholder(),
        },
      },
    };

    var categoryNames = categories.keys.toList();

    var categoryInfo = categories[selectedCategoryName]!;
    var categoryPages = categoryInfo['pages'] as Map<String, Widget>;

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: _CategoryButtons(
              majorColor: categoryInfo['majorColor'] as Color,
              minorColor: categoryInfo['minorColor'] as Color,
              items: categoryPages.keys.toList(),
              onPressed: (index){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => categoryPages.values.toList()[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerLeft,
            child: _CategoryToggle(
              color: const Color(0xFF6200EE),
              categoryItems: categoryNames,
              onPressed: (index){ setState(() {
                  selectedCategoryName = categoryNames[index];
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryButtons extends StatefulWidget{
  final Color majorColor;
  final Color minorColor;
  final List<String> items;
  final void Function(int) onPressed;

  const _CategoryButtons({
    required this.majorColor,
    required this.minorColor,
    required this.items,
    required this.onPressed,
  });

  @override
  State<_CategoryButtons> createState() => _CategoryButtonsState();
}

class _CategoryButtonsState extends State<_CategoryButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.items.length; ++i)
          Expanded(
            child: ElevatedButton(
              style: ButtonStyle(
                alignment: Alignment.center,
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  i%2==0 ? widget.majorColor : widget.minorColor
                ),
                textStyle: WidgetStateProperty.all(
                  GoogleFonts.jua( 
                    textStyle: const TextStyle(
                      fontSize: 50,
                    ),
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  widget.items[i],
                  style: GoogleFonts.jua( 
                    textStyle: const TextStyle(
                      fontSize: 50
                    ),
                  ),
                ),
              ),
              onPressed: (){ widget.onPressed(i); },
            ),
          ),
      ],
    );
  }
}

class _CategoryToggle extends StatefulWidget{
  final Color color;
  final List<String> categoryItems;
  final void Function(int) onPressed;

  const _CategoryToggle({
    required this.color,
    required this.categoryItems,
    required this.onPressed,
  });

  @override
  State<StatefulWidget> createState() => _CategoryToggleState();
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
      color: Colors.black.withValues(alpha: 0.6),
      selectedColor: widget.color,
      selectedBorderColor: widget.color,
      fillColor: widget.color.withValues(alpha: 0.08),
      splashColor: widget.color.withValues(alpha: 0.12),
      hoverColor: widget.color.withValues(alpha: 0.04),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              item,
              style: GoogleFonts.jua(),
            ),
          ),
      ],
    );
  }
}
