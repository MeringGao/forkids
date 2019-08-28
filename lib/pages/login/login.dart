import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'regist.dart';

class LoginWidget extends StatefulWidget {
  LoginWidget({Key key}) : super(key: key);

  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  TextStyle defaultStyle = TextStyle(color: Colors.white);
  String username = '';
  String password = '';

  registUser() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return RegistWidget();
      },
    ));
  }

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
                  width: MediaQuery.of(context).size.width,
                  bottom: 10,
                  child: Align(child: Text('生活不止眼前的...还有远方', style: TextStyle(color: Colors.grey, fontSize: 10)))),
              Positioned(
                  width: MediaQuery.of(context).size.width,
                  bottom: 30,
                  child: Align(
                    child: IconButton(
                      icon: Icon(FontAwesomeIcons.weixin, color: Colors.white),
                      onPressed: () {
                        print('login with weixin');
                      },
                    ),
                  )),
              Positioned(
                  width: MediaQuery.of(context).size.width,
                  bottom: 120,
                  child: Align(
                      child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 60,
                        child: TextField(
                          style: defaultStyle,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                              hintText: '手机号',
                              hintStyle: defaultStyle,
                              focusColor: Colors.white,
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2))),
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
                          //校验密码
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                              hintText: '密码',
                              hintStyle: defaultStyle,
                              focusColor: Colors.white,
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2))),
                          obscureText: true,
                          onChanged: (String value) {
                            setState(() {
                              password = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Material(
                          color: Color.fromRGBO(0, 0, 0, 0),
                          child: InkWell(
                              splashColor: Color.fromRGBO(242, 242, 242, 0.5),
                              highlightColor: Color.fromRGBO(0, 0, 0, 0),
                              child: Container(
                                  width: MediaQuery.of(context).size.width - 50,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Color.fromRGBO(121, 121, 121, 1)),
                                      color: Color.fromRGBO(242, 242, 242, 0.09),
                                      borderRadius: BorderRadius.all(Radius.circular(5))),
                                  child: Align(child: Text('登录', style: defaultStyle))),
                              onTap: () {
                                print('$username:$password');
                              })),
                      SizedBox(height: 10),
                      Container(
                          width: MediaQuery.of(context).size.width - 50,
                          height: 40,
                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            Text('没有账号?', style: defaultStyle),
                            Text(' ', style: defaultStyle),
                            InkWell(
                                child: Text('注册',
                                    style: TextStyle(
                                      color: Color.fromRGBO(2, 167, 240, 1),
                                      fontWeight: FontWeight.bold,
                                    )),
                                onTap: () {
                                  registUser();
                                })
                          ])),
                    ],
                  )))
            ])));
  }
}
