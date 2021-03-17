import 'package:flutter/material.dart';
import 'commande.dart';
import 'stock.dart';
import 'stat.dart';
import 'login.dart';
import '../models/utils.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class MyApp2 extends StatelessWidget {
  MyApp2({Key key, this.fonction}) : super(key: key);

  final String fonction;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RECRSI',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'Livraison',
        fonction: fonction,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.fonction}) : super(key: key);

  final String title;
  final String fonction;
  static String tag = "Homepage";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> livraison = [];
  Widget _onLivraison = CircularProgressIndicator(
      backgroundColor: Colors.white,
      valueColor: AlwaysStoppedAnimation(Colors.red));

  String dropdownValue0 = "Aujourd'hui";
  String compteValue = "admin";
  String dropdownValue1 = "Non Livrée";
  final motdepasse = TextEditingController();
  List<String> _condition = [
    'C.dateLivraison = CURDATE()',
    'C.status = "NON LIVREE"'
  ];
  var db;
  bool _saving = false;
  String _fonction;

  @override
  void initState() {
    super.initState();
    aff();
    _fonction = widget.fonction;
  }

  Future<Null> aff() async {
    var res = await mainDB(_condition);
    livraison.clear();
    if (res == null) {
      setState(() {
        _onLivraison = Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Aucune Donnée",
              style: TextStyle(
                fontFamily: "ProductSans",
              ),
            ),
            Text(
              'Verifier votre connexion Internet',
              style: TextStyle(
                fontFamily: "ProductSans",
              ),
            ),
            FlatButton(
                textColor: Colors.red,
                onPressed: () {
                  setState(() {
                    _onLivraison = CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation(Colors.red));
                  });
                  aff();
                },
                child: Text(
                  'Actualiser',
                  style: TextStyle(
                    fontFamily: "ProductSans",
                  ),
                ))
          ],
        );
      });
    } else {
      setState(() {
        if (res.length == 0) {
          _onLivraison = Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Aucune Donnée",
                style: TextStyle(
                  fontFamily: "ProductSans",
                ),
              ),
              Text(
                "Essayer avec d'autres conditions",
                style: TextStyle(
                  fontFamily: "ProductSans",
                ),
              ),
              FlatButton(
                  textColor: Colors.red,
                  onPressed: () {
                    setState(() {
                      _onLivraison = CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation(Colors.red));
                    });
                    aff();
                  },
                  child: Text(
                    'Actualiser',
                    style: TextStyle(
                      fontFamily: "ProductSans",
                    ),
                  ))
            ],
          );
        } else {
          for (var row in res) {
            String subtitle = "${row[3]}" + " - ${row[4]}";
            subtitle += (row[5] == null || row[5] == '') ? '' : " - ${row[5]}";
            Icon icon = Icon(Icons.help);
            if (row[7] == "NON LIVREE") {
              DateTime dateL =
                  DateTime(row[6].year, row[6].month, row[6].day + 1);
              DateTime curDt = DateTime.now();
              if (dateL.diffInDays(curDt) >= 0) {
                icon = Icon(Icons.help, color: Colors.grey);
              } else
                icon = Icon(Icons.error, color: Color(0xFFBE0019));
            } else if (row[7] == "LIVREE")
              icon = Icon(Icons.check_box, color: Colors.greenAccent);
            else if (row[7] == "ANNULEE")
              icon = Icon(Icons.cancel, color: Color(0xFFBE0019));

            livraison.add(ListTile(
              onTap: () {
                _infoCommande(row);
              },
              title: Text(
                "${row[1]} - ${row[2]}",
                style: TextStyle(
                  fontFamily: "ProductSans",
                ),
              ),
              leading: icon,
              trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            value: "LIVREE-${row[0]}-${row[8]}",
                            child: Text(
                              "Livraison livrée",
                              style: TextStyle(
                                fontFamily: "ProductSans",
                              ),
                            )),
                        PopupMenuItem(
                            value: "ANNULEE-${row[0]}-${row[8]}",
                            child: Text(
                              "Livraison annulée",
                              style: TextStyle(
                                fontFamily: "ProductSans",
                              ),
                            )),
                      ],
                  onSelected: (value) {
                    List<String> valList = value.split('-');
                    setState(() {
                      _saving = true;
                    });
                    statusChange(valList[0], int.parse(valList[1]),
                        int.parse(valList[2]));
                  },
                  icon: Icon(Icons.more_vert_rounded)),
              subtitle: Text(
                subtitle,
                style: TextStyle(
                  fontFamily: "ProductSans",
                ),
              ),
            ));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(fontFamily: "ProductSans"),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: _fonction == "ADMIN"
                ? [
                    DrawerHeader(
                        decoration: BoxDecoration(
                            color: Color(0xFFBE0019),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25))),
                        child: Image.asset('assets/logo.png')),
                    ListTile(
                      title: Text(
                        "Livraison",
                        style: TextStyle(
                          fontFamily: "ProductSans",
                        ),
                      ),
                      leading: Icon(Icons.add_shopping_cart, color: Colors.red),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      title: Text(
                        "Commande",
                        style: TextStyle(
                          fontFamily: "ProductSans",
                        ),
                      ),
                      leading: Icon(Icons.add, color: Colors.red),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return CommandePage();
                        }));
                      },
                    ),
                    ListTile(
                      title: Text(
                        "Gestion de Stock",
                        style: TextStyle(
                          fontFamily: "ProductSans",
                        ),
                      ),
                      leading: Icon(Icons.store_outlined, color: Colors.red),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return GestionStockPage();
                        }));
                      },
                    ),
                    ListTile(
                      title: Text(
                        "Statistique",
                        style: TextStyle(
                          fontFamily: "ProductSans",
                        ),
                      ),
                      leading:
                          Icon(Icons.bar_chart_outlined, color: Colors.red),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return StatistiquePage();
                        }));
                      },
                    ),
                    ListTile(
                      title: Text(
                        "Administration",
                        style: TextStyle(
                          fontFamily: "ProductSans",
                        ),
                      ),
                      leading: Icon(Icons.settings_outlined, color: Colors.red),
                      onTap: () {
                        Navigator.of(context).pop();
                        adminCompte();
                      },
                    ),
                    ListTile(
                      title: Text(
                        "Deconnexion",
                        style: TextStyle(
                          fontFamily: "ProductSans",
                        ),
                      ),
                      leading: Icon(Icons.logout, color: Colors.red),
                      onTap: () {
                        Future deconnexion() async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.clear();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return LoginPage();
                          }));
                        }

                        deconnexion();
                      },
                    )
                  ]
                : _fonction == "VENDEUR"
                    ? [
                        DrawerHeader(
                            decoration: BoxDecoration(
                                color: Color(0xFFBE0019),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(25))),
                            child: Image.asset('assets/logo.png')),
                        ListTile(
                          title: Text(
                            "Livraison",
                            style: TextStyle(
                              fontFamily: "ProductSans",
                            ),
                          ),
                          leading:
                              Icon(Icons.add_shopping_cart, color: Colors.red),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            "Commande",
                            style: TextStyle(
                              fontFamily: "ProductSans",
                            ),
                          ),
                          leading: Icon(Icons.add, color: Colors.red),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return CommandePage();
                            }));
                          },
                        ),
                        ListTile(
                          title: Text(
                            "Deconnexion",
                            style: TextStyle(
                              fontFamily: "ProductSans",
                            ),
                          ),
                          leading: Icon(Icons.logout, color: Colors.red),
                          onTap: () {
                            Future deconnexion() async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.clear();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return LoginPage();
                              }));
                            }

                            deconnexion();
                          },
                        )
                      ]
                    : _fonction == "LIVREUR"
                        ? [
                            DrawerHeader(
                                decoration: BoxDecoration(
                                    color: Color(0xFFBE0019),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(25),
                                        bottomRight: Radius.circular(25))),
                                child: Image.asset('assets/logo.png')),
                            ListTile(
                              title: Text(
                                "Livraison",
                                style: TextStyle(
                                  fontFamily: "ProductSans",
                                ),
                              ),
                              leading: Icon(Icons.add_shopping_cart,
                                  color: Colors.red),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              title: Text(
                                "Deconnexion",
                                style: TextStyle(
                                  fontFamily: "ProductSans",
                                ),
                              ),
                              leading: Icon(Icons.logout, color: Colors.red),
                              onTap: () {
                                Future deconnexion() async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.clear();
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return LoginPage();
                                  }));
                                }

                                deconnexion();
                              },
                            )
                          ]
                        : [
                            DrawerHeader(
                                decoration: BoxDecoration(
                                    color: Color(0xFFBE0019),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(25),
                                        bottomRight: Radius.circular(25))),
                                child: Image.asset('assets/logo.png')),
                            ListTile(
                              title: Text(
                                "Deconnexion",
                                style: TextStyle(
                                  fontFamily: "ProductSans",
                                ),
                              ),
                              leading: Icon(Icons.logout, color: Colors.red),
                              onTap: () {
                                Future deconnexion() async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.clear();
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return LoginPage();
                                  }));
                                }

                                deconnexion();
                              },
                            )
                          ],
          ),
        ),
        body: LoadingOverlay(
            color: Colors.black,
            progressIndicator: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              strokeWidth: 2,
            ),
            child: SingleChildScrollView(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Card(
                      elevation: 10,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          margin: EdgeInsets.symmetric(vertical: 15),
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<String>(
                                value: dropdownValue0,
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.red),
                                elevation: 16,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: "ProductSans"),
                                underline: Container(
                                  height: 2,
                                  color: Colors.red,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValue0 = newValue;
                                    if (newValue == "Aujourd'hui")
                                      _condition[0] =
                                          "C.dateLivraison=CURDATE()";
                                    else if (newValue == "A venir")
                                      _condition[0] =
                                          "C.dateLivraison>=CURDATE()";
                                    else
                                      _condition[0] = "1";
                                  });
                                },
                                items: (_fonction == 'ADMIN' ||
                                        _fonction == 'VENDEUR')
                                    ? <String>[
                                        "Aujourd'hui",
                                        "A venir",
                                        "Toutes",
                                      ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList()
                                    : <String>["Aujourd'hui"]
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      livraison.clear();

                                      _onLivraison = CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.red));
                                    });
                                    aff();
                                  }),
                              DropdownButton<String>(
                                value: dropdownValue1,
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.red),
                                elevation: 16,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: "ProductSans"),
                                underline: Container(
                                  height: 2,
                                  color: Colors.red,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValue1 = newValue;
                                    if (newValue == "Livrée")
                                      _condition[1] = 'C.status = "LIVREE" ';
                                    else if (newValue == "Annulée")
                                      _condition[1] = 'C.status = "ANNULEE" ';
                                    else if (newValue == "Non Livrée")
                                      _condition[1] =
                                          'C.status = "NON LIVREE" ';
                                    else
                                      _condition[1] = '1';
                                  });
                                },
                                items: (_fonction == 'ADMIN' ||
                                        _fonction == 'VENDEUR')
                                    ? <String>[
                                        "Livrée",
                                        "Annulée",
                                        "Non Livrée",
                                        "Tous"
                                      ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList()
                                    : <String>["Non Livrée"]
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                              )
                            ],
                          ))),
                  Card(
                    elevation: 10,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.6,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      margin: EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.bottomCenter,
                      child: livraison.length == 0
                          ? _onLivraison
                          : ListView(children: livraison),
                    ),
                  ),
                ],
              ),
            )),
            isLoading: _saving)
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Future statusChange(status, id, quantite) async {
    bool res = await majStatus(status, id, quantite);
    setState(() {
      _saving = false;
    });
    if (!res) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur',
                style: TextStyle(
                    color: Color(0xFF464637), fontFamily: "ProductSans")),
            content: SingleChildScrollView(
                child: Text(
              "Une erreur s'est produite",
              style: TextStyle(
                  color: Color(0xFFBE0019), fontFamily: "ProductSans"),
            )),
            actions: <Widget>[
              FlatButton(
                textColor: Color(0xFFBE0019),
                child: Text(
                  'Fermer',
                  style: TextStyle(fontFamily: "ProductSans"),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Succes',
                style: TextStyle(
                    color: Color(0xFF464637), fontFamily: "ProductSans")),
            content: SingleChildScrollView(
                child: Text(
              'Status Changé avec succès',
              style: TextStyle(color: Colors.green),
            )),
            actions: <Widget>[
              FlatButton(
                textColor: Color(0xFFBE0019),
                child: Text(
                  'Fermer',
                  style: TextStyle(fontFamily: "ProductSans"),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _onLivraison = CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation(Colors.red));
                  });
                  livraison.clear();
                  aff();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future _infoCommande(List row) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Commande N° ${row[0]}",
            style: TextStyle(fontFamily: "ProductSans"),
          ),
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.title,
                color: Colors.red,
              ),
              title: Text(
                "${row[1]} - ${row[2]} : ${row[8]}",
                style: TextStyle(fontFamily: "ProductSans"),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.place,
                color: Colors.red,
              ),
              title: Text(
                "${row[3]} : ${row[6].day}/${row[6].month}/${row[6].year}",
                style: TextStyle(fontFamily: "ProductSans"),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.account_box_outlined,
                color: Colors.red,
              ),
              title: Text(
                "${row[5]} : ${row[4]}",
                style: TextStyle(fontFamily: "ProductSans"),
              ),
              onTap: () {},
            ),
            FlatButton(
                textColor: Color(0xFFBE0019),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Fermer",
                  style: TextStyle(fontFamily: "ProductSans"),
                ))
          ],
        );
      },
    );
  }

  Future adminCompte() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Gestion de Compte",
            style: TextStyle(fontFamily: "ProductSans"),
          ),
          children: <Widget>[
            Container(
                margin: EdgeInsets.all(15),
                child: DropdownButton<String>(
                    value: compteValue,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.red),
                    elevation: 16,
                    style:
                        TextStyle(color: Colors.red, fontFamily: "ProductSans"),
                    underline: Container(
                      height: 2,
                      color: Colors.red,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        compteValue = newValue;
                      });
                      Navigator.of(context).pop();
                      return adminCompte();
                    },
                    items: <String>[
                      "admin",
                      "vendeur",
                      "livreur",
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList())),
            Container(
                margin: EdgeInsets.all(15),
                child: TextField(
                  decoration: InputDecoration(
                      fillColor: Color(0xFFBE0019),
                      hintText: "Nouveau mot de passe"),
                  controller: motdepasse,
                )),
            Container(
              alignment: Alignment.bottomCenter,
              child: RaisedButton(
                elevation: 6,
                color: Color(0xFFBE0019),
                textColor: Colors.white,
                padding: EdgeInsets.all(8.0),
                splashColor: Color(0xFFBE0019),
                child: Text(
                  "MODIFIER",
                  style: TextStyle(
                    fontFamily: "ProductSans",
                  ),
                ),
                onPressed: () {
                  Future checkUpdate() async {
                    var res = await updatePasswd(compteValue, motdepasse.text);
                    Navigator.of(context).pop();
                    if (res == true) {
                      return showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Succes',
                                style: TextStyle(
                                    color: Color(0xFF464637),
                                    fontFamily: "ProductSans")),
                            content: SingleChildScrollView(
                                child: Text(
                              'Status Changé avec succès',
                              style: TextStyle(color: Colors.green),
                            )),
                            actions: <Widget>[
                              FlatButton(
                                textColor: Color(0xFFBE0019),
                                child: Text(
                                  'Fermer',
                                  style: TextStyle(fontFamily: "ProductSans"),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _onLivraison = CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            AlwaysStoppedAnimation(Colors.red));
                                  });
                                  livraison.clear();
                                  aff();
                                },
                              ),
                            ],
                          );
                        },
                      );
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
                              "Une erreur s'est produite",
                              style: TextStyle(
                                  color: Color(0xFFBE0019),
                                  fontFamily: "ProductSans"),
                            )),
                            actions: <Widget>[
                              FlatButton(
                                textColor: Color(0xFFBE0019),
                                child: Text(
                                  'Fermer',
                                  style: TextStyle(fontFamily: "ProductSans"),
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

                  checkUpdate();
                },
              ),
            )
          ],
        );
      },
    );
  }
}

extension DateOnlyCompare on DateTime {
  int diffInDays(DateTime date2) {
    return ((this.difference(date2) -
                    Duration(hours: this.hour) +
                    Duration(hours: date2.hour))
                .inHours /
            24)
        .round();
  }
}
