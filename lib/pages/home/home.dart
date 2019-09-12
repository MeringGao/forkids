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
  double scale = 0.25;
  Future getWord() {
    return Dio().get("http://101.132.237.187/random_word").then((response) {
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
      setState(() {
        print('get word');
        word = Word(strokes, medians, scale, true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("写字"), actions: [IconButton(icon: Icon(Icons.access_alarm), onPressed: getWord)]),
        body: word != null ? WordWidget(word) : Text('xxx'));
  }
}

class WordWidget extends StatefulWidget {
  Word word;
  WordWidget(this.word);
  @override
  State createState() => _WordWidgetState(word);
}

class _WordWidgetState extends State<WordWidget> with SingleTickerProviderStateMixin {
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
    controller = AnimationController(duration: Duration(seconds: 5), vsync: this);
    animation = IntTween(begin: 0, end: word.strokePaths.length).animate(controller)
      ..addListener(() {
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
      SizedBox(child: word != null ? CustomPaint(painter: WordPainter(word)) : Text('xxxx'), width: 256, height: 256),
      SizedBox(child: medianIndex != null ? CustomPaint(painter: biShunPainter) : Text('xxxx'), width: 256, height: 256),
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
    Paint medianPaint = Paint();
    medianPaint.color = Colors.red;
    medianPaint.strokeWidth = 50;
    medianPaint.strokeMiterLimit = 10;
    medianPaint.style = PaintingStyle.stroke;
    canvas.clipPath(word.strokePaths[medianIndex]);
    canvas.drawPath(word.strokePaths[medianIndex], medianPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
