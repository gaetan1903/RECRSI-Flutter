import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login.dart';
import 'models/utils.dart';
import 'pages/livraison.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Widget> loadFromFuture() async {
    final prefs = await SharedPreferences.getInstance();

    final usr = prefs.getString('login') ?? '';
    var res = await login(usr, '1', verif: true);

    if (res.length == 1) {
      String fonction;
      for (var r in res) fonction = r[0];
      return Future.value(Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return MyApp2(
          fonction: fonction,
        );
      })));
    }

    return Future.value(LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        navigateAfterFuture: loadFromFuture(),
        image: new Image.asset('assets/logo.png'),
        backgroundColor: Color(0xFFBE0019),
        loadingText: new Text(
          "chargement...",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "ProductSans",
          ),
        ),
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 90,
        loaderColor: Colors.white);
  }
}
