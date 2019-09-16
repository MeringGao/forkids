import 'package:dio/dio.dart';
import 'lib/utils/word.dart';
import 'lib/utils/word_path.dart';
import 'dart:math';

List<double> distanceToPoint(Word word, Map<int, double> distanceIndex,
    int medianIndex, double animateDistance) {
  double x;
  double y;
  int currentIndex = 0;
  double distance;
  WordPathPoint begin = word.medians[medianIndex][0].points[0];
  for (int i in distanceIndex.keys) {
    if (animateDistance == 0) {
      return [begin.x, begin.y];
    }
    double value = distanceIndex[i];
    if (value < animateDistance && animateDistance <= distanceIndex[i + 1]) {
      currentIndex = i;
      distance = animateDistance - value;
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
      print(verticalHeight);
      print([x1, y1, x2, y2]);
      break;
    }
  }

  return [x, y];
}

main() {
  Dio().get("http://101.132.237.187/random_word?word=我").then((response) {
    List<String> strokes =
        response.data['graphic']['strokes'].cast<String>().toList();
    List<List> mediansRaw = response.data['graphic']['medians'].cast<List>();
    List<List<List<int>>> medians = List<List<List<int>>>();
    for (List second in mediansRaw) {
      List<List<int>> threeList = List<List<int>>();
      for (List three in second) {
        List<int> fourList = List<int>();
        for (int four in three) {
          fourList.add(four);
        }
        threeList.add(fourList);
      }
      medians.add(threeList);
    }
    Word word = Word(strokes, medians, 0.25, true);
    print(word);

    int medianIndex = 1;

    double distance = 0.0;
    Map<int, double> distanceIndex = Map();
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
        print(distance);
      }
    }
    print(distanceIndex);
    print(word.medians[medianIndex]);
    print(distanceToPoint(word, distanceIndex, 1, 5));
  });
}
