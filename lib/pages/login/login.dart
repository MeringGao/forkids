import 'package:flutter/material.dart';

class LoginWidget extends StatefulWidget {
  LoginWidget({Key key}) : super(key: key);

  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  TextStyle defaultStyle = TextStyle(color: Colors.white);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(fit: BoxFit.cover, image: AssetImage('assets/images/loginbackground.png'))),
            child: Stack(children: <Widget>[
              Positioned(
                  width: MediaQuery.of(context).size.width, bottom: 30, child: Align(child: Text('xxxx', style: defaultStyle))),
              Positioned(
                  width: MediaQuery.of(context).size.width, bottom: 60, child: Align(child: Text('xxxx', style: defaultStyle))),
              Positioned(
                  width: MediaQuery.of(context).size.width, bottom: 90, child: Align(child: Text('xxxx', style: defaultStyle))),
            ])));
  }
}
