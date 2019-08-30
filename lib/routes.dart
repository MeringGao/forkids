import 'package:flutter/material.dart';
import 'pages/home/home.dart';
import 'pages/login/login.dart';
import 'pages/login/regist.dart';

Map<String, Widget> routes = {
  '/': HomeWidget(),
  'login': LoginWidget(),
  'regist': RegistWidget(),
};

// 路由钩子,用于路由是否进入的控制
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  return MaterialPageRoute(builder: (context) {
    String routeName = settings.name;
    Widget widget = routes[routeName];
    return widget;
  });
}
