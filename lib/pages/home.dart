import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.numPushed});

  final int numPushed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          child: ColoredBox(
            color: Colors.green,
            child: Text("Box"),
          ),
        ),
        
        const Text(
          textAlign: TextAlign.center,
          'You have pushed the button this many times:',
        ),
        Text(
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
          '$numPushed',
        ),
      ],
    );
  }
}