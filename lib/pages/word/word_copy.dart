import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
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
  double distance;
  int medianIndex = 1;
  double medianDistance;
  double width = 256;
  Map<int, double> distanceIndex;
  Animation<double> animation;
  AnimationController controller;
  _WordWidgetState(this.word, this.width) {
    distance = 0.0;
    distanceIndex = Map();
    distanceIndex[0] = 0.0;
    WordPathPoint start = word.medians[medianIndex][0].points[0];
    for (int i = 1; i < word.medians[medianIndex].length; i++) {
      WordPath wordPath = word.medians[medianIndex][i];
      if (wordPath.points.length > 0) {
        WordPathPoint point = wordPath.points[0];
        distance += (sqrt(pow((point.x - start.x), 2) + pow((point.y - start.y), 2))).abs();
        start = point;
        distanceIndex[i] = distance;
        print(distance);
      }
    }
  }

  @override
  initState() {
    super.initState();
    controller = AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: 0, end: distance).animate(controller)
      ..addListener(() {
        // if (animation.value == word.strokePaths.length) {
        //   controller.reset();
        //   controller.forward();
        // }
        setState(() {
          medianDistance = animation.value;
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
                        distanceIndex,
                        medianIndex,
                        medianDistance,
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
  double medianDistance;
  Map<int, double> distanceIndex;
  int currentIndex;
  BiShunPainter(this.word, this.distanceIndex, this.medianIndex, this.medianDistance);

  List<double> _distanceToPoint(double animateDistance) {
    double x;
    double y;
    WordPathPoint begin = word.medians[medianIndex][0].points[0];
    for (int i in distanceIndex.keys) {
      if (medianDistance == 0) {
        return [begin.x, begin.y];
      }
      double value = distanceIndex[i];
      if (value < animateDistance && distanceIndex[i + 1] <= animateDistance) {
        currentIndex = i;
        WordPathPoint begin = word.medians[medianIndex][i].points[0];
        WordPathPoint end = word.medians[medianIndex][i + 1].points[0];
        double slope = (end.y - begin.y) / (end.x - begin.x);
        double verticalHeight = end.y - ((end.y - begin.y) * end.x) / (end.x - begin.x);
        print(verticalHeight);
        double a = 1 + pow(slope, 2);
        double c = pow((end.x - begin.x), 2) + pow((end.y - begin.y), 2) - pow(animateDistance, 2);
        double b = -2 * begin.x - 2 * slope * begin.y;
        double x1 = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
        double y1 = slope * x1;
        double x2 = (-b - sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
        double y2 = slope * x2;

        if (end.x >= begin.x) {
          if (x1 > begin.x && x1 <= end.x) {
            x = x2;
            y = y2;
          } else {
            x = x1;
            y = y1;
          }
        }
        if (end.x < begin.x) {
          if (x1 >= end.x && x1 < begin.x) {
            x = x2;
            y = y2;
          } else {
            x = x1;
            y = y1;
          }
        }
        print(verticalHeight);
        print([x1, y1, x2, y2]);
        break;
      }
    }

    return [x, y];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (medianIndex >= word.strokePaths.length) {
      medianIndex = word.strokePaths.length - 1;
    }
    Paint strokePain = Paint();
    strokePain.color = Colors.red;
    strokePain.style = PaintingStyle.fill;

    Paint medianPaint = Paint();
    medianPaint.color = Colors.blue;
    medianPaint.strokeWidth = 5;
    medianPaint.strokeCap = StrokeCap.round;
    medianPaint.style = PaintingStyle.stroke;
    WordPathPoint startPoint = word.medians[medianIndex][0].points[0];
    List<double> endPoint = _distanceToPoint(medianDistance);
    Offset startOffset = Offset(startPoint.x, startPoint.y);
    Offset endOffset = Offset(endPoint[0], endPoint[1]);
    print('=========');
    print(word.medians[medianIndex]);
    print(medianDistance);
    print('start offset');
    print(startOffset);
    print('end offset');
    print(endOffset);
    // canvas.drawLine(startOffset, endOffset, medianPaint);
    // for (int i = 0; i <= medianIndex - 1; i++) {
    //   canvas.save();
    //   canvas.clipPath(word.strokePaths[i]);
    //   canvas.drawPath(word.strokePaths[i], strokePain);
    //   canvas.restore();
    // }
  }

  @override
  bool shouldRepaint(BiShunPainter oldDelegate) {
    return true;
    // return oldDelegate.medianIndex != medianIndex || oldDelegate.word != word;
  }
}
