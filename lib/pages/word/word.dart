import 'package:flutter/material.dart';
import '../../utils/word.dart';

class WordWidget extends StatefulWidget {
  final Word word;
  WordWidget(this.word);
  @override
  State createState() => _WordWidgetState(word);
}

class _WordWidgetState extends State<WordWidget> with SingleTickerProviderStateMixin {
  Word word;
  int medianIndex = -2;
  Animation<int> animation;
  AnimationController controller;
  _WordWidgetState(this.word);
  @override
  initState() {
    super.initState();
    controller = AnimationController(duration: Duration(seconds: 5), vsync: this);
    animation = IntTween(begin: -2, end: word.strokePaths.length).animate(controller)
      ..addListener(() {
        if (animation.value == word.strokePaths.length) {
          controller.reset();
          controller.forward();
        }
        setState(() {
          medianIndex = animation.value;
        });
      });
    controller.forward();
  }

  dispose() {
    super.dispose();
    controller.reset();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('练习')),
        body: Stack(children: [
          SizedBox(child: CustomPaint(painter: WordPainter(word)), width: 256, height: 256),
          SizedBox(child: CustomPaint(painter: BiShunPainter(word, medianIndex)), width: 256, height: 256),
        ]));
  }
}

class WordPainter extends CustomPainter {
  Word word;
  WordPainter(this.word);
  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = Paint();
    strokePaint.color = Colors.grey;
    strokePaint.strokeWidth = 1;
    strokePaint.style = PaintingStyle.fill;
    for (Path path in word.strokePaths) {
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(WordPainter oldDelegate) {
    return oldDelegate.word != word;
  }
}

class BiShunPainter extends CustomPainter {
  Word word;
  int medianIndex;
  BiShunPainter(this.word, this.medianIndex);

  @override
  void paint(Canvas canvas, Size size) {
    if (medianIndex >= word.strokePaths.length) {
      medianIndex = word.strokePaths.length - 1;
    }
    Paint medianPaint = Paint();
    medianPaint.color = Colors.red;
    medianPaint.strokeWidth = 500;
    medianPaint.style = PaintingStyle.fill;
    for (int i = 0; i <= medianIndex; i++) {
      canvas.save();
      canvas.clipPath(word.strokePaths[i]);
      canvas.drawPath(word.strokePaths[i], medianPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BiShunPainter oldDelegate) {
    return true;
    // return oldDelegate.medianIndex != medianIndex || oldDelegate.word != word;
  }
}
