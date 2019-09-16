import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../word/word.dart';
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
      word = Word(strokes, medians, scale, true);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return WordWidget(word);
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("写字")), body: IconButton(icon: Icon(Icons.access_alarm), onPressed: getWord));
  }
}
