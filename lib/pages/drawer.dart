import 'package:flutter/material.dart';
import 'commande.dart';
import 'stock.dart';
import 'stat.dart';
import 'login.dart';
import 'livraison.dart';
import 'admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({Key key, this.fonction}) : super(key: key);

  final String fonction;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: fonction == "ADMIN"
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return LivraisonPage(fonction: fonction);
                    }));
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
                      return CommandePage(
                        fonction: fonction,
                      );
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
                      return GestionStockPage(
                        fonction: fonction,
                      );
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
                  leading: Icon(Icons.bar_chart_outlined, color: Colors.red),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return StatistiquePage(
                        fonction: fonction,
                      );
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return AdminPage(fonction: fonction);
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
                      final prefs = await SharedPreferences.getInstance();
                      prefs.clear();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return LoginPage();
                      }));
                    }

                    deconnexion();
                  },
                )
              ]
            : fonction == "VENDEUR"
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return LivraisonPage(fonction: fonction);
                        }));
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
                          return CommandePage(
                            fonction: fonction,
                          );
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
                : fonction == "LIVREUR"
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
    );
  }
}
