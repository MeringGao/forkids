const _svgWidth = 1024;
const _svgTopOffset = 124;

class WordPathPoint {
  double x;
  double y;

  WordPathPoint(this.x, this.y);

  @override
  String toString() {
    return "WordPathPoint($x, $y)";
  }
}

class WordPath {
  List<WordPathPoint> points;
  String pathType;

  WordPath(this.pathType, this.points);

  @override
  String toString() {
    return "WordPath($pathType, $points)";
  }
}

List<WordPath> _convertStrokePath(String stroke, {double scale = 1, bool reverse = true}) {
  List<String> points = stroke.split(" ");
  WordPathPoint _parsePoint(int indexX, indexY) {
    double x = double.parse(points[indexX]) * scale;
    double y = double.parse(points[indexY]) * scale;
    if (reverse) {
      double scaledWidth = _svgWidth * scale;
      double topPadding = _svgTopOffset * scale;
      // x = double.parse((x - scaledWidth).abs().toStringAsFixed(2));
      y = double.parse((y - scaledWidth + topPadding).abs().toStringAsFixed(2));
    }
    return WordPathPoint(x, y);
  }

  List<WordPath> path = List<WordPath>();
  int i = 0;
  while (i < points.length) {
    switch (points[i]) {
      case "M":
        {
          path.add(WordPath('M', [_parsePoint(i + 1, i + 2)]));
          i += 3;
          break;
        }
      case "Q":
        {
          path.add(WordPath('Q', [
            _parsePoint(i + 1, i + 2),
            _parsePoint(i + 3, i + 4),
          ]));
          i += 5;
          break;
        }
      case "C":
        {
          path.add(WordPath('C', [
            _parsePoint(i + 1, i + 2),
            _parsePoint(i + 3, i + 4),
            _parsePoint(i + 5, i + 6),
          ]));
          i += 7;
          break;
        }
      case "L":
        {
          path.add(WordPath('L', [
            _parsePoint(i + 1, i + 2),
          ]));
          i += 3;
          break;
        }
      case "Z":
        {
          path.add(WordPath('Z', []));
          return path;
        }
      default:
        i += 1;
    }
  }
  return path;
}

List<WordPath> _convertMedianPath(List<List<int>> median, {double scale = 1, bool reverse = true}) {
  WordPathPoint _parsePoint(int cx, int cy) {
    double x = cx * scale;
    double y = cy * scale;
    if (reverse) {
      double scaledWidth = _svgWidth * scale;
      double topPadding = _svgTopOffset * scale;
      // x = double.parse((x - scaledWidth).abs().toStringAsFixed(2));
      y = double.parse((y - scaledWidth + topPadding).abs().toStringAsFixed(2));
    }
    return WordPathPoint(x, y);
  }

  List<WordPath> path = List<WordPath>();
  path.add(WordPath('M', [_parsePoint(median[0][0], median[0][1])]));
  int i = 1;
  while (i < median.length) {
    path.add(WordPath('L', [_parsePoint(median[i][0], median[i][1])]));
    i++;
  }
  path.add(WordPath('Z', []));
  return path;
}

List<List<WordPath>> scaleStrokes(List<String> strokes, {double scale = 1, bool reverse = true}) {
  List<List<WordPath>> paths = [];
  for (String stroke in strokes) {
    paths.add(_convertStrokePath(stroke, scale: scale, reverse: reverse));
  }
  return paths;
}

List<List<WordPath>> scaleMedians(List<List<List<int>>> medians, {double scale = 1, bool reverse = true}) {
  List<List<WordPath>> paths = [];
  for (List<List<int>> median in medians) {
    paths.add(_convertMedianPath(median, scale: scale, reverse: reverse));
  }
  return paths;
}
