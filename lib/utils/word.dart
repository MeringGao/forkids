import 'dart:ui';
import 'dart:math';

import './word_path.dart';

class Word {
  List<String> rawStrokes;
  List<List<List<int>>> rawMedians;
  double scale;
  bool reverse;
  List<List<WordPath>> strokes;
  List<List<WordPath>> medians;
  Map<int, Map<int, double>> distances;
  List<Path> strokePaths;
  List<Path> medianPaths;

  Word(this.rawStrokes, this.rawMedians, this.scale, this.reverse) {
    strokes = scaleStrokes(rawStrokes, scale: scale, reverse: reverse);
    medians = scaleMedians(rawMedians, scale: scale, reverse: reverse);
    this.strokePaths = _buildPath(strokes);
    this.medianPaths = _buildPath(medians);
    _calculateDistance();
  }
  void _calculateDistance() {
    distances = Map<int, Map<int, double>>();
    for (int i = 0; i < medians.length; i++) {
      List<WordPath> median = medians[i];
      double distance = 0.0;
      Map<int, double> distanceIndex = Map();
      distanceIndex[0] = 0.0;
      WordPathPoint start = median[0].points[0];
      for (int j = 1; j < median.length; j++) {
        WordPath wordPath = median[j];
        if (wordPath.points.length > 0) {
          WordPathPoint point = wordPath.points[0];
          distance += (sqrt(pow((point.x - start.x), 2) + pow((point.y - start.y), 2))).abs();
          start = point;
          distanceIndex[j] = distance;
        }
      }
      distances[i] = distanceIndex;
    }
  }

  List<Path> _buildPath(List<List<WordPath>> word) {
    List<Path> paths = [];
    for (List<WordPath> wordPaths in word) {
      Path path = Path();
      for (WordPath wordPath in wordPaths) {
        List<WordPathPoint> points = wordPath.points;
        switch (wordPath.pathType) {
          case 'M':
            {
              path.moveTo(points[0].x, points[0].y);
              break;
            }
          case 'L':
            {
              path.lineTo(points[0].x, points[0].y);
              break;
            }
          case 'Q':
            {
              path.quadraticBezierTo(points[0].x, points[0].y, points[1].x, points[1].y);
              break;
            }
          case 'C':
            {
              path.cubicTo(points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y);
              break;
            }
          case 'Z':
            {
              break;
            }
        }
      }
      paths.add(path);
    }
    return paths;
  }
}
