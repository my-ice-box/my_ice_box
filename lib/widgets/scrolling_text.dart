import 'dart:async';
import 'package:flutter/material.dart';

enum TextScrolling {
  scrollNext,
  scrollPrev,
  upAndDown,
  downAndUp,
}

class ScrollingText extends StatefulWidget {
  final Duration animating;
  final Duration scrolling;
  final TextScrolling type;
  final List<String> texts;

  bool get _isScrollType =>
    type == TextScrolling.scrollNext ||
    type == TextScrolling.scrollPrev;
  bool get _isUpward =>
    type == TextScrolling.scrollNext ||
    type == TextScrolling.upAndDown;

  const ScrollingText({
    super.key,
    this.animating = const Duration(seconds: 2),
    this.scrolling = const Duration(milliseconds: 500),
    this.type = TextScrolling.scrollNext,
    this.texts = const [
      'placeholder 1',
      'placeholder 2'
    ]
  });

  @override
  State<StatefulWidget> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> {
  int _currentIndex = 0;
  bool _isAnimating = false;

  int get _nextIndex => (_currentIndex + 1) % widget.texts.length;

  void _onAnimationStart(Timer timer) {
    if (!mounted) return;
    setState(() => _isAnimating = true);

    // After Scrolling Ends
    Future.delayed(
      widget.scrolling,
      () {
        if (!mounted) return;
        setState(() {
          _currentIndex = _nextIndex;
          _isAnimating = false;
        });
      }
    );
  }

  @override
  void initState() {
    super.initState();

    final timer = Timer.periodic(
      widget.animating,
      _onAnimationStart,
    );

    // fire Now
    _onAnimationStart(timer);
  }

  _buildAnimatedText(double topOffset, String text) {
    final positioning = widget._isScrollType ?
      _isAnimating ? widget.scrolling : Duration.zero :
      widget.scrolling;

    final textStyle = TextStyle(
      fontSize: 50, 
      fontWeight: FontWeight.bold,
    );

    return AnimatedPositioned(
      duration: positioning,
      curve: Curves.easeInOut,
      top: topOffset,
      child: Text(text, style: textStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 텍스트 박스 높이 설정
    final double height = 50;

    return SizedBox(
      height: height,
      width: 300,
      child: Stack(
        children: [
          _buildAnimatedText(_isAnimating ?
              (widget._isUpward ? -height : height) : 0,
            widget.texts[_currentIndex]
          ),
          if (widget._isScrollType)
            _buildAnimatedText(_isAnimating ?
                0 : (widget._isUpward ? height : -height),
              widget.texts[_nextIndex]
            ),
        ],
      ),
    );
  }
}
