import 'package:flutter/material.dart';
import 'pages/home/home.dart';
import 'routes.dart';
import 'theme.dart';

void main() {
  // 如果设置了onError,fluter渲染时发生异常是,就会调用onError方法
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   print(details);
  // };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'For kids',
      theme: theme,
      onGenerateRoute: onGenerateRoute,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return HomeWidget();
  }
}
