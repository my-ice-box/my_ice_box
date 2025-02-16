import 'dart:async';
import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  const ScrollingText({super.key});

  @override
  State<StatefulWidget> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> {
  final List<String> texts = ["와플?", "핫도그?", "마카롱?", "아이스크림?"];
  int _currentIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    Timer.periodic(
      Duration(seconds: 2),
      (timer) {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % texts.length;
          _isAnimating = false;
        });

        Future.delayed(
          Duration(milliseconds: 1500),
          () {
            if (!mounted) return;
            setState(() {
              _isAnimating = true;
            });
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // 텍스트 박스 높이 설정
      width: 300,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: _isAnimating ? Duration(milliseconds: 500) : Duration.zero,
            curve: Curves.easeInOut,
            top: _isAnimating ? -50 : 0,
            child: Text(
              texts[_currentIndex],
              style: TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: _isAnimating ? Duration(milliseconds: 500) : Duration.zero,
            curve: Curves.easeInOut,
            top: _isAnimating ? 0 : 50,
            child: Text(
              texts[(_currentIndex + 1) % texts.length],
              style: TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
