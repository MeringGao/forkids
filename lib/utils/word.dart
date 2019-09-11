import './word_path.dart';
import 'dart:ui';

class Word {
  List<String> rawStrokes;
  List<List<List<int>>> rawMedians;
  double scale;
  bool reverse;
  List<List<WordPath>> strokes;
  List<List<WordPath>> medians;
  List<Path> strokePaths;
  List<Path> medianPaths;

  Word(this.rawStrokes, this.rawMedians, this.scale, this.reverse) {
    strokes = scaleStrokes(rawStrokes, scale: scale, reverse: reverse);
    medians = scaleMedians(rawMedians, scale: scale, reverse: reverse);
    this.strokePaths = _buildPath(strokes);
    this.medianPaths = _buildPath(medians);
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
