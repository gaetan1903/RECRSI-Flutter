import 'package:flutter/material.dart';
import 'package:recrsi/models/utils.dart';
import 'package:recrsi/pages/insertEdit.dart';

class GestionStockPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GestionStockPage();
  }
}

class _GestionStockPage extends State<GestionStockPage> {
  List<Widget> produit = [];
  Widget _onProduit = CircularProgressIndicator(
      backgroundColor: Colors.white,
      valueColor: AlwaysStoppedAnimation(Color(0xFFBE0019)));
  TextEditingController _keySearch = TextEditingController();
  String query = "1";

  @override
  void initState() {
    super.initState();
    aff();
  }

  Future<Null> aff() async {
    produit.clear();
    var res = await showAllProduct(query: query);
    var subtitle;
    Icon icon;
    setState(() {
      if (res == null) {
        _onProduit = Column(
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
                  textColor: Color(0xFFBE0019),
                  onPressed: () {
                    setState(() {
                      _onProduit = CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor:
                              AlwaysStoppedAnimation(Color(0xFFBE0019)));
                    });
                    aff();
                  },
                  child: Text(
                    'Actualiser',
                    style: TextStyle(
                      fontFamily: "ProductSans",
                    ),
                  ))
            ]);
      } else if (res.length == 0) {
        _onProduit = Column(
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
              "Il semble n'y avoir aucun produit",
              style: TextStyle(
                fontFamily: "ProductSans",
              ),
            ),
            FlatButton(
                textColor: Color(0xFFBE0019),
                onPressed: () {
                  setState(() {
                    _onProduit = CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFBE0019)));
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
          if (row[5] > 1) {
            subtitle = "${row[5]} stock disponible ";
            icon = Icon(Icons.check_box, color: Colors.teal);
          } else if (row[5] == 1) {
            subtitle = "${row[5]} stock disponible ";
            icon = Icon(Icons.error, color: Colors.orange);
          } else {
            subtitle = "Stock epuisé ";
            icon = Icon(Icons.error, color: Color(0xFFBE0019));
          }

          produit.add(ListTile(
            onTap: () {
              _infoProduit(row);
            },
            title: Text(
              "${row[2]} - ${row[1]}",
              style: TextStyle(
                fontFamily: "ProductSans",
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontFamily: "ProductSans",
              ),
            ),
            leading: icon,
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return ProductPage(
                    row: row,
                    title: "Modification Produit",
                  );
                }));
              },
            ),
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gestion de Stock",
          style: TextStyle(
            fontFamily: "ProductSans",
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return ProductPage(
              row: null,
              title: "Ajout Produit",
            );
          }));
        },
        child: Icon(Icons.add),
      ),

      body: Center(
          child: Column(
        children: [
          Card(
              elevation: 10,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.05,
                margin: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextField(
                        decoration: InputDecoration(
                            fillColor: Color(0xFFBE0019),
                            hintText: "Rechercher ici..."),
                        controller: _keySearch,
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Color(0xFFBE0019),
                        ),
                        onPressed: () {
                          String val = _keySearch.text.trim();
                          if (val == "")
                            query = "1";
                          else
                            query =
                                'reference LIKE "%$val%" OR nomProduit LIKE "%$val%"';
                          setState(() {
                            produit.clear();
                            _onProduit = CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                valueColor:
                                    AlwaysStoppedAnimation(Color(0xFFBE0019)));
                          });
                          aff();
                        })
                  ],
                ),
              )),
          SingleChildScrollView(
            child: Card(
              elevation: 10,
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.6,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  margin: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  child: produit.length == 0
                      ? _onProduit
                      : ListView(children: produit)),
            ),
          )
        ],
      )),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future _infoProduit(List row) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Produit N° ${row[0]}",
            style: TextStyle(
              fontFamily: "ProductSans",
            ),
          ),
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.title,
                color: Color(0xFFBE0019),
              ),
              title: Text(
                "${row[2]} - ${row[1]}",
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.format_list_numbered,
                color: Color(0xFFBE0019),
              ),
              title: Text(
                "dispo: ${row[5]}",
                style: TextStyle(
                  fontFamily: "ProductSans",
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.add_shopping_cart,
                color: Color(0xFFBE0019),
              ),
              title: Text(
                "en commande:  ${row[6]}",
                style: TextStyle(
                  fontFamily: "ProductSans",
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.attach_money,
                color: Color(0xFFBE0019),
              ),
              title: Text(
                "Achat: ${beautyNumber(row[3])}",
                style: TextStyle(
                  fontFamily: "ProductSans",
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.attach_money,
                color: Color(0xFFBE0019),
              ),
              title: Text(
                "Vente: ${beautyNumber(row[4])}",
                style: TextStyle(
                  fontFamily: "ProductSans",
                ),
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
                  style: TextStyle(
                    fontFamily: "ProductSans",
                  ),
                ))
          ],
        );
      },
    );
  }
}
