import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../../utils/word.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

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
  Map word;
  void getWord() async {
    try {
      Response<Map> response = await Dio().get("http://101.132.237.187/random_word");
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
        word = Map();
        word['strokes'] = strokes;
        word['medians'] = medians;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("写字"), actions: [IconButton(icon: Icon(Icons.access_alarm), onPressed: getWord)]),
        body: Center(
            child: SizedBox(
                child: word != null ? CustomPaint(painter: WordPainter(word, 0.25)) : Text('xxxx'), width: 256, height: 256)));
  }
}

class WordPainter extends CustomPainter {
  double scale;
  Map word;
  WordPainter(this.word, this.scale);
  @override
  void paint(Canvas canvas, Size size) {
    Word paintWord = Word(word['strokes'], word['medians'], scale, true);
    Paint strokePaint = Paint();
    strokePaint.color = Colors.red;
    strokePaint.strokeWidth = 1;
    strokePaint.style = PaintingStyle.fill;
    Paint medianPaint = Paint();
    medianPaint.color = Colors.blue;
    medianPaint.strokeWidth = 1;
    medianPaint.style = PaintingStyle.stroke;

    for (Path path in paintWord.strokePaths) {
      canvas.drawPath(path, strokePaint);
    }
    for (var median in paintWord.medianPaths) {
      canvas.drawPath(median, medianPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
