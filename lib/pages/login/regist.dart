import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class RegistWidget extends StatefulWidget {
  RegistWidget({Key key}) : super(key: key);

  _RegistWidgetState createState() => _RegistWidgetState();
}

class _RegistWidgetState extends State<RegistWidget> {
  TextStyle defaultStyle = TextStyle(color: Colors.black);
  String username;
  String password;
  String passwordEnsure;
  String code;
  Color bottomBorderColor;

  @override
  initState() {
    super.initState();
  }

  registUser() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return RegistWidget();
      },
    ));
  }

  InputDecoration defaultInputDecoration(hint) {
    return InputDecoration(
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: bottomBorderColor, width: 1)),
        hintText: ' $hint',
        hintStyle: defaultStyle,
        focusColor: Colors.white,
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: bottomBorderColor, width: 1)));
  }

  @override
  Widget build(BuildContext context) {
    bottomBorderColor = Theme.of(context).primaryColor;
    return Scaffold(
        appBar: AppBar(),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(),
            child: Stack(children: <Widget>[
              Positioned(
                  width: MediaQuery.of(context).size.width,
                  top: 120,
                  child: Align(
                      child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 60,
                        child: TextField(
                          style: defaultStyle,
                          cursorColor: bottomBorderColor,
                          decoration: defaultInputDecoration('手机号'),
                          onChanged: (String value) {
                            setState(() {
                              username = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 60,
                        child: TextField(
                          style: defaultStyle,
                          cursorColor: bottomBorderColor,
                          //校验密码
                          decoration: defaultInputDecoration('密码'),
                          obscureText: true,
                          onChanged: (String value) {
                            setState(() {
                              password = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 60,
                        child: TextField(
                          style: defaultStyle,
                          cursorColor: bottomBorderColor,
                          //校验密码
                          decoration: defaultInputDecoration('确认密码'),
                          obscureText: true,
                          onChanged: (String value) {
                            setState(() {
                              passwordEnsure = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 60,
                        child: Row(children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: defaultStyle,
                              cursorColor: bottomBorderColor,
                              //校验密码
                              decoration: defaultInputDecoration('验证码'),
                              obscureText: true,
                              onChanged: (String value) {
                                setState(() {
                                  code = value;
                                });
                              },
                            ),
                          ),
                          OutlineButton(
                              borderSide: BorderSide(color: bottomBorderColor),
                              splashColor: bottomBorderColor,
                              highlightColor: Color.fromRGBO(0, 0, 0, 0),
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              child: Text('发送验证码'),
                              onPressed: () {
                                print('send code');
                              })
                        ]),
                      ),
                      SizedBox(height: 20),
                      Material(
                          color: Color.fromRGBO(0, 0, 0, 0),
                          child: InkWell(
                              splashColor: bottomBorderColor,
                              highlightColor: Color.fromRGBO(0, 0, 0, 0),
                              child: Container(
                                  width: MediaQuery.of(context).size.width - 50,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: bottomBorderColor),
                                      color: Color.fromRGBO(242, 242, 242, 0.09),
                                      borderRadius: BorderRadius.all(Radius.circular(5))),
                                  child: Align(child: Text('确认', style: defaultStyle))),
                              onTap: () {
                                print('$username:$password:$passwordEnsure');
                                Navigator.of(context).pop();
                              })),
                    ],
                  )))
            ])));
  }
}
