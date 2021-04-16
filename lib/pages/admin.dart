import 'package:flutter/material.dart';
import 'package:recrsi/models/utils.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flushbar/flushbar.dart';
import 'drawer.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key key, this.fonction}) : super(key: key);
  final String fonction;

  @override
  _AdminPage createState() => _AdminPage();
}

class _AdminPage extends State<AdminPage> {
  String dropdownRef = "Utilisateur";
  String dropdownFonction = "Fonction";
  final motdepasse = TextEditingController();

  final userNew = TextEditingController();
  final mdpNew = TextEditingController();
  String newFonction = "LIVREUR";

  List<String> personnel = ["Utilisateur"];
  bool _saving = false;
  OverlayEntry overlayEntry;
  String fonction;
  var users;

  @override
  void initState() {
    fonction = widget.fonction;
    _saving = true;
    listeUser();
    super.initState();
  }

  Future<void> listeUser() async {
    users = await getUsers();
    personnel = ['Utilisateur'];
    for (var user in users) personnel.add(user[1]);
    setState(() {
      _saving = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Administration',
        style: TextStyle(
          fontFamily: "ProductSans",
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addUser();
        },
        child: Icon(Icons.add),
      ),
      drawer: MyDrawer(fonction: fonction),
      body: LoadingOverlay(
          color: Colors.black,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE0019)),
            strokeWidth: 2,
          ),
          child: Center(
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 25,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: MediaQuery.of(context).size.height * 0.02),
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.8,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 15),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(bottom: 10),
                                child: Text("Gestion de Compte",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFBE0019),
                                        fontFamily: "ProductSans"))),
                            DropdownButton<String>(
                                value: dropdownRef,
                                isExpanded: true,
                                icon: IconButton(
                                  icon: Icon(Icons.delete_outline_outlined),
                                  color: Color(0xFFBE0019),
                                  onPressed: () {
                                    deleteUser();
                                  },
                                ),
                                elevation: 16,
                                underline: Container(
                                  height: 1,
                                  color: Colors.black38,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownRef = newValue;
                                    for (var user in users) {
                                      if (user[1] == newValue) {
                                        setState(() {
                                          dropdownFonction = user[3];
                                        });
                                      }
                                    }
                                  });
                                },
                                items: personnel.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontFamily: "ProductSans",
                                      ),
                                    ),
                                  );
                                }).toList()),
                            DropdownButton<String>(
                                value: dropdownFonction,
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.red),
                                isExpanded: true,
                                elevation: 16,
                                underline: Container(
                                    height: 1, color: Color(0xFFBE0019)),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownFonction = newValue;
                                  });
                                },
                                items: [
                                  "Fonction",
                                  "ADMIN",
                                  "VENDEUR",
                                  "LIVREUR"
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontFamily: "ProductSans",
                                      ),
                                    ),
                                  );
                                }).toList()),
                            TextField(
                                decoration: InputDecoration(
                                  fillColor: Color(0xFFBE0019),
                                  hintText: "Mot de passe",
                                ),
                                controller: motdepasse,
                                obscureText: true),
                            Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RaisedButton(
                                      onPressed: () {
                                        Future updateU() async {
                                          var res;
                                          if (motdepasse.text == '')
                                            res = await updateUser(dropdownRef,
                                                '', dropdownFonction, false);
                                          else
                                            res = await updateUser(
                                                dropdownRef,
                                                motdepasse.text,
                                                dropdownFonction,
                                                true);
                                          if (res == true)
                                            Flushbar(
                                              title: "Réussi",
                                              icon: Icon(
                                                  Icons.verified_outlined,
                                                  color: Colors.green),
                                              message: motdepasse.text != ''
                                                  ? "Mise à jour effectuer avec nouveau mot de passe"
                                                  : 'Mise à jour effectuer',
                                              duration: Duration(seconds: 3),
                                            ).show(context);
                                          else
                                            Flushbar(
                                              title: "Erreur",
                                              icon: Icon(
                                                  Icons.error_outline_outlined,
                                                  color: Colors.red),
                                              message:
                                                  "Une erreur s'est produite",
                                              duration: Duration(seconds: 3),
                                            ).show(context);
                                        }

                                        if (dropdownRef == 'Utilisateur') {
                                          Flushbar(
                                            title: "Erreur",
                                            icon: Icon(
                                                Icons.error_outline_outlined,
                                                color: Colors.red),
                                            message:
                                                "Utilisateur doit être defini",
                                            duration: Duration(seconds: 3),
                                          ).show(context);
                                        } else if (dropdownFonction ==
                                            'Fonction') {
                                          Flushbar(
                                            title: "Erreur",
                                            icon: Icon(
                                                Icons.error_outline_outlined,
                                                color: Colors.red),
                                            message:
                                                "Fonction doit être defini",
                                            duration: Duration(seconds: 3),
                                          ).show(context);
                                        } else {
                                          _saving = true;
                                          setState(() {});
                                          updateU();
                                          listeUser();
                                        }
                                      },
                                      elevation: 6,
                                      disabledColor: Colors.grey,
                                      color: Color(0xFFBE0019),
                                      textColor: Colors.white,
                                      padding: EdgeInsets.all(8.0),
                                      splashColor: Color(0xFFBE0019),
                                      child: Text(
                                        "Mettre à jour",
                                        style: TextStyle(
                                          fontFamily: "ProductSans",
                                        ),
                                      ))
                                ],
                              ),
                            )
                          ]),
                    ),
                  ))),
          isLoading: _saving),
    );
  }

  Future addUser() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
            title: Text(
              "Creation de Compte",
              style: TextStyle(fontFamily: "ProductSans"),
            ),
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(15),
                  child: TextField(
                    decoration: InputDecoration(
                        fillColor: Color(0xFFBE0019), hintText: "Utilisateur"),
                    controller: userNew,
                  )),
              Container(
                  margin: EdgeInsets.all(15),
                  child: DropdownButton<String>(
                      value: newFonction,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.red),
                      elevation: 16,
                      style: TextStyle(
                          color: Colors.red, fontFamily: "ProductSans"),
                      underline: Container(
                        height: 2,
                        color: Colors.red,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          newFonction = newValue;
                        });
                        Navigator.of(context).pop();
                        return addUser();
                      },
                      items: <String>[
                        "ADMIN",
                        "VENDEUR",
                        "LIVREUR",
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
                      hintText: "Nouveau mot de passe",
                      fillColor: Color(0xFFBE0019),
                    ),
                    controller: mdpNew,
                    obscureText: true,
                  )),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  textColor: Color(0xFFBE0019),
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Fermer",
                    style: TextStyle(
                      fontFamily: "ProductSans",
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (userNew.text == '') {
                      Flushbar(
                        title: "Erreur",
                        icon: Icon(Icons.error_outline_outlined,
                            color: Colors.red),
                        message: "Champ Utilisateur ne peut pas être vide",
                        duration: Duration(seconds: 3),
                      ).show(context);
                      return addUser();
                    }
                    if (mdpNew.text == '') {
                      Flushbar(
                        title: "Erreur",
                        icon: Icon(Icons.error_outline_outlined,
                            color: Colors.red),
                        message: "Champ Mot de passe ne peut pas être vide",
                        duration: Duration(seconds: 3),
                      ).show(context);
                      return addUser();
                    }
                    for (var user in users) {
                      if (user[1] == userNew.text) {
                        Flushbar(
                          title: "Erreur",
                          icon: Icon(Icons.error_outline_outlined,
                              color: Colors.red),
                          message: "Utilisateur existe déjà",
                          duration: Duration(seconds: 3),
                        ).show(context);
                        return addUser();
                      }
                    }
                    setState(() {
                      _saving = true;
                    });
                    ajouterUser();
                  },
                  textColor: Color(0xFFBE0019),
                  padding: EdgeInsets.all(8.0),
                  splashColor: Color(0xFFBE0019),
                  child: Text(
                    "CREER",
                    style: TextStyle(
                      fontFamily: "ProductSans",
                    ),
                  ),
                )
              ])
            ]);
      },
    );
  }

  Future ajouterUser() async {
    var res = await addNewUser(userNew.text, newFonction, mdpNew.text);
    if (res == true) {
      Flushbar(
        title: "Réussi",
        icon: Icon(Icons.verified_outlined, color: Colors.green),
        message: "Mise à jour effectuer avec nouveau mot de passe",
        duration: Duration(seconds: 3),
      ).show(context);
      listeUser();
    } else
      Flushbar(
        title: "Erreur",
        icon: Icon(Icons.error_outline_outlined, color: Colors.red),
        message: "Une erreur s'est produite",
        duration: Duration(seconds: 3),
      ).show(context);
  }

  Future deleteUser({bool confirm: true}) async {
    if (dropdownRef == 'Utilisateur' || dropdownRef == 'admin')
      return Flushbar(
        title: "Erreur",
        icon: Icon(Icons.error_outline_outlined, color: Colors.red),
        message: "Selectionner un utilisateur valide",
        duration: Duration(seconds: 3),
      ).show(context);
    if (confirm)
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation',
                style: TextStyle(
                    color: Color(0xFF464637), fontFamily: "ProductSans")),
            content: SingleChildScrollView(
                child: Text(
              "Voulez-vous vraiment Supprimer l'utilidsateur $dropdownRef ?",
              style: TextStyle(
                fontFamily: "ProductSans",
              ),
            )),
            actions: <Widget>[
              FlatButton(
                textColor: Color(0xFFBE0019),
                child: Text(
                  'Annulé',
                  style: TextStyle(
                    fontFamily: "ProductSans",
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                textColor: Color(0xFFBE0019),
                child: Text(
                  'Confirmer',
                  style: TextStyle(
                    fontFamily: "ProductSans",
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _saving = true;
                  });
                  deleteUser(confirm: false);
                },
              ),
            ],
          );
        },
      );
    else {
      var res = await deletedUser(dropdownRef);

      if (res == true) {
        Flushbar(
          title: "Réussi",
          icon: Icon(Icons.verified_outlined, color: Colors.green),
          message: "$dropdownRef supprimé avec succes",
          duration: Duration(seconds: 3),
        ).show(context);
      } else
        Flushbar(
          title: "Erreur",
          icon: Icon(Icons.error_outline_outlined, color: Colors.red),
          message: "Une erreur s'est produite",
          duration: Duration(seconds: 3),
        ).show(context);
      dropdownRef = 'Utilisateur';
      listeUser();
    }
  }

// Flushbar(
//             message: "Produit Non Disponible",
//             duration: Duration(seconds: 3),
//           ).show(context);
}
