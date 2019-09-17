import 'package:flutter/material.dart';
import '../word/word.dart';
import '../../utils/word.dart';

class HomeWidget extends StatefulWidget {
  HomeWidget({Key key}) : super(key: key);

  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Word word;
  double scale = 0.25;
  double width = 256.0;
  List<String> words;
  Future _getWord(String word) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return WordWidget(word, scale, width);
    }));
  }

  Future _getWordList() {
    return getHanziList().then((wordList) {
      setState(() {
        words = wordList;
      });
    });
  }

  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("写字"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.access_time), onPressed: _getWordList),
        ],
      ),
      body: Wrap(
        children: words != null
            ? words
                .map((word) => FlatButton(
                      child: Text(word),
                      onPressed: () {
                        _getWord(word);
                      },
                    ))
                .toList()
            : [FlatButton(child: Text('随机获取汉字'), onPressed: _getWordList)],
      ),
    );
  }
}
