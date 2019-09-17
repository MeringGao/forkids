import 'dart:ui';
import 'dart:math';

import 'package:dio/dio.dart';

import './word_path.dart';

class Word {
  /// 原始的stroke数据
  List<String> rawStrokes;

  /// 原始的median数据
  List<List<List<int>>> rawMedians;

  /// 缩放参数
  double scale;

  /// 反转
  bool reverse;

  /// 经过处理的stroke数据
  List<List<WordPath>> strokes;

  ///经过处理的median数据
  List<List<WordPath>> medians;

  /// 笔顺长度数据字典
  Map<int, Map<int, double>> distances;

  /// stroke 对应的canvas Path数据
  List<Path> strokePaths;

  /// median 对应的canvas Path数据
  List<Path> medianPaths;

  /// 初始化的时候就计算出需要用到的数据
  Word(this.rawStrokes, this.rawMedians, this.scale, this.reverse) {
    /// 缩放路径数据
    strokes = scaleStrokes(rawStrokes, scale: scale, reverse: reverse);
    medians = scaleMedians(rawMedians, scale: scale, reverse: reverse);

    /// 将缩放后的数据构建为Path数据
    this.strokePaths = _buildPath(strokes);
    this.medianPaths = _buildPath(medians);
    _calculateDistance();
  }

  /// 笔画是由多个点连成的线
  /// 笔顺的动画是在笔顺的线上取多个点
  /// 比如,笔顺:[[10,15],[11,19],[13,31],[15,33]],这几个点连成的线不是一条直线,每条线斜率是不同的,
  /// 这里的想法是,每条线的长度是可以计算出来的,线的总长度也是可以计算出来的.所以如果动画的值是一个长度值,
  /// 那么就可以知道给定长度对应的点的[x,y]位置
  /// 如果计算出[x,y]在第3条线上,也就是([13,31]~[15,33]),那么可以划线:
  /// drawLine([10,15],[11,19])
  /// drawLine([11,19],[13,31])
  /// drawLine([13,31],[x,y])
  /// 这个方法是把单个笔顺的长度值计算出来,结果格式:
  /// {0:0,1:10,2:11,3:13} key对应的是第几个点,value对应的第0个点到这个点的总长度.
  /// distances保存的是每一个笔顺的长度值字典,结果格式:
  /// {0:{0:0,1:10,2:11,3:13}}
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

  /// 这个方法把笔顺数据转为Path数据
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

Future getWord(scale, {String word}) {
  String url = "http://101.132.237.187/random_word";
  if (word != null) {
    url = "http://101.132.237.187/random_word?word=$word";
  }
  return Dio().get(url).then((response) {
    List<String> strokes = response.data['graphic']['strokes'].cast<String>().toList();
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
    return Word(strokes, medians, scale, true);
  });
}

Future getHanziList() {
  String url = "http://101.132.237.187/word_list";
  return Dio().get(url).then((response) {
    List<String> words = response.data.cast<String>().toList();
    return words;
  });
}
