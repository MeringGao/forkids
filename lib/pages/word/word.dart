import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/word.dart';
import '../../utils/word_path.dart';

class WordWidget extends StatefulWidget {
  final Word word;
  final double width;
  WordWidget(this.word, this.width);
  @override
  State createState() => _WordWidgetState(word, width);
}

class _WordWidgetState extends State<WordWidget> with SingleTickerProviderStateMixin {
  Word word;
  int medianIndex = -2;
  double width = 256;
  Animation<int> animation;
  AnimationController controller;
  _WordWidgetState(this.word, this.width);
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
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('练习')),
        body: Stack(children: [
          // Positioned(
          //     width: width,
          //     height: width,
          //     left: (MediaQuery.of(context).size.width - width) / 2,
          //     top: 10,
          //     child: Container(
          //         alignment: Alignment.center,
          //         child: SizedBox(child: CustomPaint(painter: WordPainter(word, Colors.grey)), width: width, height: width))),
          Positioned(
              top: 10,
              width: width,
              height: width,
              left: (MediaQuery.of(context).size.width - width) / 2,
              child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                      child: CustomPaint(
                          painter: BiShunPainter(
                        word,
                        medianIndex,
                      )),
                      width: width,
                      height: width))),
          Positioned(
              width: width,
              height: width,
              left: (MediaQuery.of(context).size.width - width) / 2,
              top: width + 10,
              child: Container(
                  alignment: Alignment.center,
                  child:
                      SizedBox(child: CustomPaint(painter: WordPainter(word, Colors.lightBlue)), width: width, height: width))),
        ]));
  }
}

class WordPainter extends CustomPainter {
  Word word;
  Color color;
  WordPainter(this.word, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = Paint();
    strokePaint.color = color;
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
    medianPaint.strokeCap = StrokeCap.round;
    medianPaint.style = PaintingStyle.stroke;

    // Paint pointPaint = Paint();
    // pointPaint.color = Colors.red;
    // pointPaint.strokeWidth = 50;
    // pointPaint.strokeCap = StrokeCap.round;
    // pointPaint.style = PaintingStyle.fill;

    for (int i = 0; i <= medianIndex; i++) {
      canvas.save();
      canvas.clipPath(word.strokePaths[i]);
      canvas.drawPath(word.medianPaths[i], medianPaint);
      // WordPath lastPath = word.medians[i][word.medians[i].length - 2];
      // Offset offset = Offset(lastPath.points[0].x, lastPath.points[0].y);
      // canvas.drawPoints(PointMode.points, [offset], pointPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BiShunPainter oldDelegate) {
    return true;
    // return oldDelegate.medianIndex != medianIndex || oldDelegate.word != word;
  }
}
