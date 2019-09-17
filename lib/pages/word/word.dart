import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/word.dart';
import '../../utils/word_path.dart';
import '../../utils/distance_utils.dart';

class WordWidget extends StatefulWidget {
  final String wordCharactor;
  final double scale;
  final double width;

  WordWidget(this.wordCharactor, this.scale, this.width);

  @override
  State createState() => _WordWidgetState(wordCharactor, scale, width);
}

class _WordWidgetState extends State<WordWidget>
    with SingleTickerProviderStateMixin {
  Word word;
  String wordCharactor;
  double scale;
  int medianIndex = 0;
  double animateDistance;
  double width = 256;
  Animation<double> animation;
  AnimationController controller;
  Map<String, int> speed = {
    "faster": 600,
    "fast": 700,
    "common": 800,
    "slow": 900,
    'slower': 1000
  };

  _WordWidgetState(this.wordCharactor, this.scale, this.width);

  void newAnimation() {
    animation = Tween<double>(
            begin: 0,
            end: word.distances[medianIndex]
                [word.distances[medianIndex].keys.length - 1])
        .animate(controller)
          ..addListener(() {
            if (animation.value ==
                word.distances[medianIndex]
                    [word.distances[medianIndex].keys.length - 1]) {
              if (medianIndex < word.medians.length - 1) {
                medianIndex += 1;
              } else {
                medianIndex = 0;
              }
              newAnimation();
            }
            setState(() {
              animateDistance = animation.value;
            });
          });
    controller.reset();
    controller.forward();
  }

  @override
  initState() {
    controller = AnimationController(
        duration: Duration(milliseconds: speed['common']), vsync: this);
    getWord(scale, word: wordCharactor).then((wordOrigin) {
      word = wordOrigin;
      newAnimation();
    });

    super.initState();
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('练习'),
      ),
      body: Center(
        child: SizedBox(
          child: word != null
              ? CustomPaint(
                  foregroundPainter: BiShunPainter(
                    word,
                    word.distances[medianIndex],
                    medianIndex,
                    animateDistance,
                  ),
                )
              : Text('加载中.....'),
          width: width,
          height: width,
        ),
      ),
    );
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
  double animateDistance;
  Map<int, double> medianDistance;
  int currentIndex = 0;
  Paint strokePain;
  Paint medianPaint;
  Paint animatePaint;
  Paint medianPaintStroke;

  BiShunPainter(
      this.word, this.medianDistance, this.medianIndex, this.animateDistance) {
    strokePain = Paint();
    strokePain.color = Colors.red;
    strokePain.style = PaintingStyle.fill;

    medianPaint = Paint();
    medianPaint.color = Colors.grey;
    medianPaint.strokeWidth = 1;
    medianPaint.style = PaintingStyle.fill;

    medianPaintStroke = Paint();
    medianPaintStroke.color = Colors.blue;
    medianPaintStroke.strokeWidth = 1;
    medianPaintStroke.style = PaintingStyle.stroke;

    animatePaint = Paint();
    animatePaint.color = Colors.red;
    animatePaint.strokeWidth = 50;
    animatePaint.strokeCap = StrokeCap.round;
    animatePaint.style = PaintingStyle.stroke;
  }

  List<double> _distanceToPoint() {
    WordPathPoint begin;
    WordPathPoint end;
    double distance;
    for (int i in medianDistance.keys) {
      if (animateDistance == 0) {
        return [
          word.medians[medianIndex][0].points[0].x,
          word.medians[medianIndex][0].points[0].y
        ];
      }
      double value = medianDistance[i];
      if (value < animateDistance && animateDistance <= medianDistance[i + 1]) {
        currentIndex = i;
        distance = animateDistance - value;
        begin = word.medians[medianIndex][i].points[0];
        end = word.medians[medianIndex][i + 1].points[0];
        break;
      }
    }

    return distancePoint(begin.x, begin.y, end.x, end.y, distance);
  }

  void _painStrokes(Canvas canvas, Size size) {
    /// 灰色的笔顺
    for (int k = medianIndex; k <= word.strokePaths.length - 1; k++) {
      canvas.drawPath(word.strokePaths[k], medianPaint);
    }
    // 已经画过的笔顺
    for (int i = 0; i <= medianIndex - 1; i++) {
      canvas.drawPath(word.strokePaths[i], strokePain);
    }
  }

  void _paintMedianLine(Canvas canvas, Size size) {
    // 正在画的笔顺
    var median = word.medians[medianIndex];
    List<double> endPoint = _distanceToPoint();
    canvas.clipPath(word.strokePaths[medianIndex]);
    WordPathPoint startPoint = median[0].points[0];
    WordPathPoint currentPoint;
    for (int j = 1; j < currentIndex; j++) {
      currentPoint = median[j].points[0];
      canvas.drawLine(Offset(startPoint.x, startPoint.y),
          Offset(currentPoint.x, currentPoint.y), animatePaint);
      startPoint = currentPoint;
    }
    canvas.drawLine(Offset(startPoint.x, startPoint.y),
        Offset(endPoint[0], endPoint[1]), animatePaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _painStrokes(canvas, size);
    _paintMedianLine(canvas, size);
  }

  @override
  bool shouldRepaint(BiShunPainter oldDelegate) {
    return true;
  }
}
