import 'package:flutter/material.dart';
import 'package:my_ice_box/pages/note_detail.dart';
import 'package:my_ice_box/widgets/custom_layout.dart';

class NotePage extends StatelessWidget{
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final blueBorder = BoxDecoration(
      border: Border.all(
        color: Colors.blue,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(8.0),
    );

    final tabtitle = Container(
      decoration: blueBorder,
      padding: EdgeInsets.all(5),
      child: Text('목록입니다.'),
    );
    final notebox = Container(
      decoration: blueBorder,
      padding: EdgeInsets.all(5),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.amber),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailPage(),
          ),
        ),
        child: Center(child: Text('Hello')),
      ),
    );
    final notetab = Container(
      decoration: blueBorder,
      // padding: EdgeInsets.all(5),
      child: PairEdgeColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        leading: [tabtitle],
        content: DynamicRow(
          children: [
            notebox, notebox, notebox, notebox,
            notebox,
          ],
        ),
      ),
    );

    return PairEdgeColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      content: DynamicColumn(
        // spacing: 5,
        children: [
          notetab,
          notetab,
          notetab,
          notetab,
          notetab,
        ]
      ),
    );
  }
}