import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ScrollType {
  scrollNext,
  scrollPrev,
  upAndDown,
  downAndUp,
}

@immutable
class ScrollStyle with Diagnosticable {
  final ScrollType type;
  final Duration animating;
  final Duration waiting;

  const ScrollStyle({
    required this.type,
    required this.animating,
    this.waiting = Duration.zero,
  });

  bool get _isScrollType =>
    type == ScrollType.scrollNext ||
    type == ScrollType.scrollPrev;
  bool get _isUpward =>
    type == ScrollType.scrollNext ||
    type == ScrollType.upAndDown;

  Duration get duration => animating + waiting;
}

class ScrollingText extends StatefulWidget {
  final List<String> texts;
  final TextStyle? textStyle;
  final ScrollStyle scrollStyle;

  const ScrollingText(
    this.texts, {
    super.key,
    this.textStyle,
    this.scrollStyle = const ScrollStyle(
      type: ScrollType.scrollNext,
      animating: Duration(milliseconds: 500),
      waiting: Duration(milliseconds: 1500),
    ),
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
      widget.scrollStyle.animating,
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
      widget.scrollStyle.duration,
      _onAnimationStart,
    );
    // fire Now
    _onAnimationStart(timer);
  }

  _buildAnimatedText(double topOffset, String text, double height) {
    final positioning = widget.scrollStyle._isScrollType ?
      _isAnimating ? widget.scrollStyle.animating : Duration.zero :
      widget.scrollStyle.animating;

    return AnimatedPositioned(
      duration: positioning,
      curve: Curves.easeInOut,
      top: topOffset,
      child: SizedBox(
        height: height,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            text,
            style: widget.textStyle
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double height = constraints.maxHeight;

      return Stack(
        children: [
          _buildAnimatedText(_isAnimating ?
              (widget.scrollStyle._isUpward ? -height : height) : 0,
            widget.texts[_currentIndex],
            height
          ),
          if (widget.scrollStyle._isScrollType)
            _buildAnimatedText(_isAnimating ?
                0 : (widget.scrollStyle._isUpward ? height : -height),
              widget.texts[_nextIndex],
              height
            ),
        ],
      );
    });
  }
}
