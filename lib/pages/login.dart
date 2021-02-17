import 'package:flutter/material.dart';
import 'package:recrsi/models/utils.dart';
import 'livraison.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_overlay/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usrIn = TextEditingController();
  final passwdIn = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        fontFamily: "ProductSans",
      ),
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Utilisateur',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      controller: usrIn,
    );

    final password = TextFormField(
        autofocus: false,
        style: TextStyle(
          fontFamily: "ProductSans",
        ),
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Mot de passe',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        controller: passwdIn);

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          Future connexion(usr, passwd) async {
            var res = await login(usr, passwd);
            String fonction;
            for (var r in res) fonction = r[0];
            setState(() {
              _loading = false;
            });
            if (res.length == 1) {
              final prefs = await SharedPreferences.getInstance();
              prefs.clear();
              prefs.setString('login', usr);
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return MyApp2(fonction: fonction);
              }));
            } else {
              return showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Erreur',
                        style: TextStyle(
                            color: Color(0xFF464637),
                            fontFamily: "ProductSans")),
                    content: SingleChildScrollView(
                        child: Text(
                      "Username ou Mot de passe incorrecte",
                      style: TextStyle(
                          color: Color(0xFFBE0019), fontFamily: "ProductSans"),
                    )),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          'Fermer',
                          style: TextStyle(
                            fontFamily: "ProductSans",
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }

          FocusScope.of(context).unfocus();
          setState(() {
            _loading = true;
          });
          connexion(usrIn.text, passwdIn.text);
        },
        padding: EdgeInsets.all(12),
        color: Color(0xFFBE0019),
        child: Text('Connexion',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "ProductSans",
            )),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        "Contacter l'Admin si perte de mot de passe",
        style: TextStyle(
          color: Colors.black54,
          fontFamily: "ProductSans",
        ),
      ),
      onPressed: () {},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        color: Colors.black,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE0019)),
          strokeWidth: 2,
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              logo,
              SizedBox(height: 48.0),
              email,
              SizedBox(height: 32.0),
              password,
              SizedBox(height: 24.0),
              loginButton,
              forgotLabel
            ],
          ),
        ),
        isLoading: _loading,
      ),
    );
  }
}
