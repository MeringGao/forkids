import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../utils/word.dart';

void getHttp() async {
  try {
    Response response = await Dio().get("http://www.google.com");
    print(response);
  } catch (e) {
    print(e);
  }
}

class HomeWidget extends StatefulWidget {
  HomeWidget({Key key}) : super(key: key);

  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Word word;
  WordWidget wordWidget;
  double scale = 0.25;
  Future getWord() {
    return Dio().get("http://101.132.237.187/random_word").then((response) {
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
      setState(() {
        word = Word(strokes, medians, scale, true);
        wordWidget = WordWidget(word);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("写字"), actions: [
          IconButton(icon: Icon(Icons.access_alarm), onPressed: getWord)
        ]),
        body: word != null ? WordWidget(word) : Text('xxx'));
  }
}

class WordWidget extends StatefulWidget {
  Word word;
  WordWidget(this.word);
  @override
  State createState() => _WordWidgetState(word);
}

class _WordWidgetState extends State<WordWidget>
    with SingleTickerProviderStateMixin {
  Word word;
  int medianIndex;
  Animation<int> animation;
  AnimationController controller;
  BiShunPainter biShunPainter;
  _WordWidgetState(this.word) {
    biShunPainter = BiShunPainter(word, 0);
  }
  @override
  initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this);
    animation =
        IntTween(begin: -1, end: word.strokePaths.length).animate(controller)
          ..addListener(() {
            print(animation.value);
            if (animation.value == word.strokePaths.length) {
              controller.reverse();
            }
            if (animation.value == -1) {
              controller.forward();
            }
            setState(() {
              medianIndex = animation.value;
            });
          });
    controller.forward();
  }

  dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
          child: word != null
              ? CustomPaint(painter: WordPainter(word))
              : Text('xxxx'),
          width: 256,
          height: 256),
      SizedBox(
          child: medianIndex != null
              ? CustomPaint(painter: BiShunPainter(word, medianIndex))
              : Text('xxxx'),
          width: 256,
          height: 256),
    ]);
  }
}

class WordPainter extends CustomPainter {
  Word word;
  WordPainter(this.word);
  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = Paint();
    strokePaint.color = Color.fromRGBO(0, 0, 0, 0.1);
    strokePaint.strokeWidth = 1;
    strokePaint.style = PaintingStyle.fill;
    Paint medianPaint = Paint();
    medianPaint.color = Colors.red;
    medianPaint.strokeWidth = 50;
    medianPaint.strokeMiterLimit = 10;
    medianPaint.style = PaintingStyle.stroke;
    for (Path path in word.strokePaths) {
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BiShunPainter extends CustomPainter {
  Word word;
  int medianIndex;
  BiShunPainter(this.word, this.medianIndex);

  @override
  void paint(Canvas canvas, Size size) {
    if (medianIndex < 0) medianIndex = 0;
    if (medianIndex == word.strokePaths.length)
      medianIndex = word.strokePaths.length - 1;
    Paint medianPaint = Paint();
    medianPaint.color = Colors.red;
    medianPaint.strokeWidth = 5;
    medianPaint.strokeMiterLimit = 2;
    medianPaint.style = PaintingStyle.fill;
    for (int i = 0; i <= medianIndex; i++) {
      canvas.save();
      canvas.clipPath(word.strokePaths[i]);
      canvas.drawPath(word.strokePaths[i], medianPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
