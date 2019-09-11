import 'package:dio/dio.dart';

main() async {
  Response<Map> response = await Dio().get("http://101.132.237.187/random_word");
  List<String> strokes = response.data['graphic']['strokes'].cast<String>().toList();
  List<List> medians = response.data['graphic']['medians'].cast<List>();
  List<List<List<int>>> medianList = List<List<List<int>>>();
  for (List second in medians) {
    List<List<int>> threeList = List<List<int>>();
    for (List three in second) {
      List<int> fourList = List<int>();
      for (int four in three) {
        fourList.add(four);
      }
      threeList.add(fourList);
    }
    medianList.add(threeList);
  }

  print(strokes.runtimeType);
  print(medianList.runtimeType);
}
