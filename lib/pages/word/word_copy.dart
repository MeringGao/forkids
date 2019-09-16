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

class _WordWidgetState extends State<WordWidget>
    with SingleTickerProviderStateMixin {
  Word word;
  double distance;
  int medianIndex = 2;
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
        distance +=
            (sqrt(pow((point.x - start.x), 2) + pow((point.y - start.y), 2)))
                .abs();
        start = point;
        distanceIndex[i] = distance;
      }
    }
  }

  @override
  initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 7000), vsync: this);
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
          Positioned(
              width: width,
              height: width,
              top: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                      child:
                          CustomPaint(painter: WordPainter(word, Colors.grey)),
                      width: width,
                      height: width))),
          Positioned(
              top: 10,
              width: width,
              height: width,
              child: Container(
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
              top: width + 10,
              child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                      child: CustomPaint(
                          painter: WordPainter(word, Colors.lightBlue)),
                      width: width,
                      height: width))),
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

  BiShunPainter(
      this.word, this.distanceIndex, this.medianIndex, this.medianDistance);

  List<double> _distanceToPoint() {
    double x;
    double y;
    double distance;
    WordPathPoint begin = word.medians[medianIndex][0].points[0];
    for (int i in distanceIndex.keys) {
//      if (medianDistance == 0) {
//        currentIndex = 0;
//        return [begin.x, begin.y];
//      }
//      if (medianDistance ==
//          distanceIndex[word.medians[medianIndex].length - 2]) {
//        WordPathPoint point =
//            word.medians[medianIndex][word.medians[medianIndex].length-2].points[0];
//        currentIndex = word.medians[medianIndex].length-2;
//        return [point.x, point.y];
//      }
      double value = distanceIndex[i];
      if (value < medianDistance && medianDistance <= distanceIndex[i + 1]) {
        currentIndex = i;
        distance = medianDistance - value;
        WordPathPoint begin = word.medians[medianIndex][i].points[0];
        WordPathPoint end = word.medians[medianIndex][i + 1].points[0];
        double slope = (end.y - begin.y) / (end.x - begin.x);
        double verticalHeight = end.y - slope * end.x;
//      (x-x1)**2+(y-y1)**2=d**2
//      x**2 -2*x*x1+x1**2 +y**2+y1**2-2*y*y1=d**2
//      x**2 -2*x*x1+x1**2 + (s*x+v)**2+y1**2-2*(s*x+v)*y1=d**2
//      x**2 -2*x*x1 + x1**2 + s**2*x**2+v**2+2*s*v*x - 2*y1*s*x -2*y1*s*v =d**2

        double a = 1 + pow(slope, 2);
        double c = pow(begin.x, 2) +
            pow(verticalHeight, 2) +
            pow(begin.y, 2) -
            2 * begin.y * verticalHeight -
            pow(distance, 2);
        double b =
            -2 * begin.x + 2 * slope * verticalHeight - 2 * begin.y * slope;
        double x1 = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
        double y1 = slope * x1 + verticalHeight;
        double x2 = (-b - sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
        double y2 = slope * x2 + verticalHeight;
        if (end.x >= begin.x) {
          if (x1 > begin.x && x1 <= end.x) {
            x = x1;
            y = y1;
          } else {
            x = x2;
            y = y2;
          }
        }
        if (end.x < begin.x) {
          if (x1 >= end.x && x1 < begin.x) {
            x = x1;
            y = y1;
          } else {
            x = x2;
            y = y2;
          }
        }
//        print([x1, y1, x2, y2]);
        return [x, y];
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
    medianPaint.color = Colors.grey;
    medianPaint.style = PaintingStyle.fill;

    Paint animatePaint = Paint();
    animatePaint.color = Colors.red;
    animatePaint.strokeWidth = 50;
    animatePaint.strokeCap = StrokeCap.round;
    animatePaint.style = PaintingStyle.stroke;

    for (int i = 0; i <= medianIndex - 1; i++) {
      canvas.save();
      canvas.clipPath(word.strokePaths[i]);
      canvas.drawPath(word.strokePaths[i], strokePain);
      canvas.restore();
    }
    for (int k = medianIndex; k <= word.strokePaths.length - 1; k++) {
      canvas.save();
      canvas.drawPath(word.strokePaths[k], medianPaint);
      canvas.restore();
    }
    canvas.save();
    canvas.clipPath(word.strokePaths[medianIndex]);
    WordPathPoint startPoint = word.medians[medianIndex][0].points[0];
    List<double> endPoint = _distanceToPoint();
    print(distanceIndex);
    print(medianDistance);
    print(distanceIndex[word.medians[medianIndex].length - 2]);
    print(endPoint);
////    print(word.medians[medianIndex][word.medians[medianIndex].length - 2].points[0]);

    Path path = Path();
    path.moveTo(startPoint.x, startPoint.y);

    for (int j = 1; j < currentIndex; j++) {
      WordPathPoint currentPoint =
          word.medians[medianIndex][currentIndex].points[0];
      path.lineTo(currentPoint.x, currentPoint.y);
    }
    path.lineTo(endPoint[0], endPoint[1]);
    canvas.drawPath(path, animatePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(BiShunPainter oldDelegate) {
    return true;
    // return oldDelegate.medianIndex != medianIndex || oldDelegate.word != word;
  }
}
