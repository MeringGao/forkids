import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../word/word_copy.dart';
import '../../utils/word.dart';

class HomeWidget extends StatefulWidget {
  HomeWidget({Key key}) : super(key: key);

  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Word word;
  double scale = 0.25;
  double width = 0.0;
  Future getWord() {
    Size size = MediaQuery.of(context).size;
    if (size.width < 256) {
      width = 256;
      scale = 0.25;
    } else if (size.width > 256 && size.width < 512) {
      width = 256;
      scale = 0.25;
    } else if (size.width > 512 && size.width < 1024) {
      width = 512;
      scale = 0.5;
    } else if (size.width > 1024) {
      width = 1024;
      scale = 1;
    }
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
        return WordWidget(word, width);
      }));
    });
  }

  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("写字")), body: IconButton(icon: Icon(Icons.access_alarm), onPressed: getWord));
  }
}
