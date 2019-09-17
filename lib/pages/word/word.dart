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
  int medianIndex = 0;
  double medianDistance;
  double width = 256;
  Animation<double> animation;
  AnimationController controller;
  Map<String, int> speed = {"fast": 700, "common": 1000, "slow": 1300};

  _WordWidgetState(this.word, this.width);

  @override
  initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: speed['slow']), vsync: this);
    animation = Tween<double>(begin: 0, end: 512).animate(controller)
      ..addListener(() {
        if (animation.value > word.distances[medianIndex][word.distances[medianIndex].keys.length - 1]) {
          if (medianIndex < word.medians.length - 1) {
            medianIndex += 1;
          } else {
            medianIndex = 0;
          }
          setState(() {
            medianIndex = medianIndex;
          });
          controller.reset();
          controller.forward();
        }
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
              left: (MediaQuery.of(context).size.width - width) / 2,
              top: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(child: CustomPaint(painter: WordPainter(word, Colors.grey)), width: width, height: width))),
          Positioned(
              top: 10,
              left: (MediaQuery.of(context).size.width - width) / 2,
              width: width,
              height: width,
              child: Container(
                  child: SizedBox(
                      child: CustomPaint(
                          painter: BiShunPainter(
                        word,
                        word.distances[medianIndex],
                        medianIndex,
                        medianDistance,
                      )),
                      width: width,
                      height: width))),
          // Positioned(
          //     width: width,
          //     height: width,
          //     top: width + 10,
          //     child: Container(
          //         alignment: Alignment.center,
          //         child:
          //             SizedBox(child: CustomPaint(painter: WordPainter(word, Colors.lightBlue)), width: width, height: width))),
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

  List<double> _distanceToPoint() {
    double x;
    double y;
    double distance;
    WordPathPoint begin = word.medians[medianIndex][0].points[0];
    for (int i in distanceIndex.keys) {
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
        double c = pow(begin.x, 2) + pow(verticalHeight, 2) + pow(begin.y, 2) - 2 * begin.y * verticalHeight - pow(distance, 2);
        double b = -2 * begin.x + 2 * slope * verticalHeight - 2 * begin.y * slope;
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
        return [x, y];
      }
    }

    return [x, y];
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePain = Paint();
    strokePain.color = Colors.red;
    strokePain.style = PaintingStyle.fill;

    Paint medianPaint = Paint();
    medianPaint.color = Colors.grey;
    medianPaint.strokeWidth = 1;
    medianPaint.style = PaintingStyle.fill;

    Paint animatePaint = Paint();
    animatePaint.color = Colors.red;
    animatePaint.strokeWidth = 90;
    animatePaint.strokeCap = StrokeCap.round;
    animatePaint.style = PaintingStyle.stroke;

    for (int k = medianIndex; k <= word.strokePaths.length - 1; k++) {
      canvas.save();
      canvas.drawPath(word.strokePaths[k], medianPaint);
      canvas.restore();
    }

    for (int i = 0; i <= medianIndex - 1; i++) {
      canvas.save();
      canvas.drawPath(word.strokePaths[i], strokePain);
      canvas.restore();
    }

    canvas.clipPath(word.strokePaths[medianIndex]);
    WordPathPoint startPoint = word.medians[medianIndex][0].points[0];
    List<double> endPoint = _distanceToPoint();
    Path path = Path();
    path.moveTo(startPoint.x, startPoint.y);

    for (int j = 1; j < currentIndex; j++) {
      WordPathPoint currentPoint = word.medians[medianIndex][currentIndex].points[0];
      path.lineTo(currentPoint.x, currentPoint.y);
    }
    path.lineTo(endPoint[0], endPoint[1]);
    canvas.drawPath(path, animatePaint);
  }

  @override
  bool shouldRepaint(BiShunPainter oldDelegate) {
    return true;
    // return oldDelegate.medianIndex != medianIndex || oldDelegate.word != word;
  }
}
