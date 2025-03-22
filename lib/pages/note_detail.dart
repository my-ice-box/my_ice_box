import 'package:flutter/material.dart';

class NoteDetailPage extends StatelessWidget {
  final fakeShoppingList = [
    '사과',
    '오렌지',
    '복숭아',
    '딸기',
    '바나나'
  ];

  NoteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Note Title',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Divider(),
              const Text('Shopping Check-list:'),
              ...fakeShoppingList.map((item) => Row(
                children: [
                  Checkbox(value: false, onChanged: (newval) {}),
                  Text(item),
                ],
              ),),
              const Divider(),
              const Text('Note content goes here...'),
              const Text(String.fromEnvironment('PLACEHOLDER_TEXT')),
            ],
          ),
        ),
      ),
    );
  }

}