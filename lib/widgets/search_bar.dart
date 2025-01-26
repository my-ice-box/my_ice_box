import 'package:flutter/material.dart';

class SearchBarWithRotatingText extends StatefulWidget {
  const SearchBarWithRotatingText({super.key});

  @override
  State<StatefulWidget> createState() => _SearchBarWithRotatingTextState();
}

class _SearchBarWithRotatingTextState extends State<SearchBarWithRotatingText> {
  final _texts = [
    'apple',
    'banana',
    'orange',
    'grape',
    'watermelon',
  ];
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}