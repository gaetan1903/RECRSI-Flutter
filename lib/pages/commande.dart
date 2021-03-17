import 'package:flutter/material.dart';
import 'package:recrsi/models/models.dart';
import 'package:recrsi/models/utils.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flushbar/flushbar.dart';

class CommandePage extends StatefulWidget {
  @override
  _CommandePage createState() => _CommandePage();
}

class _CommandePage extends State<CommandePage> {
  String dropdownRef = "Reference Produit";
  final quantite = TextEditingController();
  final adresse = TextEditingController();
  final contact = TextEditingController();
  final nomClient = TextEditingController();
  final dateLivraison = TextEditingController();
  DateTime _dateLivraison = DateTime.now();
  FocusNode _focus = FocusNode();
  List<String> _produit = ["Reference Produit"];
  List<String> _produitTmp = ["Reference Produit"];
  List<int> _produitStock = [0];
  bool isDisable = false;
  bool _saving = false;
  OverlayEntry overlayEntry;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  @override
  void initState() {
    _saving = true;
    super.initState();
    listProd();
    _focus.addListener(() {
      if (_focus.hasFocus) _selectDate(context);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<Null> listProd() async {
    var allprod = await prodDispo();
    for (var row in allprod) {
      _produit.add("${row[2]} -- ${row[0]}");
      _produitTmp.add(row[0]);
      _produitStock.add(row[1]);
    }
    setState(() {
      _saving = false;
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    DateTime _datePicker = await showDatePicker(
        context: context,
        initialDate: _dateLivraison,
        firstDate: DateTime(2020),
        lastDate: DateTime(2050));

    if (_datePicker != null) {
      _dateLivraison = _datePicker;
      dateLivraison.text =
          "${_dateLivraison.day} ${getMonthLetter(_dateLivraison.month)} ${_dateLivraison.year}";
    }
    FocusManager.instance.primaryFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Commande',
            style: TextStyle(
              fontFamily: "ProductSans",
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                setState(() {
                  _saving = true;
                  dropdownRef = "Reference Produit";
                  _produit = ["Reference Produit"];
                  _produitTmp = ["Reference Produit"];
                });
                listProd();
              },
            )
          ]),
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
                                child: Text("Nouvelle Commande",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFBE0019),
                                        fontFamily: "ProductSans"))),
                            DropdownButton<String>(
                                value: dropdownRef,
                                isExpanded: true,
                                icon: IconButton(
                                  icon: Icon(Icons.camera_alt_outlined,
                                      color: Color(0xFFBE0019)),
                                  onPressed: () {
                                    showQrCode();
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
                                  });
                                },
                                items: _produit.map<DropdownMenuItem<String>>(
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
                            TextField(
                              decoration: InputDecoration(
                                  fillColor: Color(0xFFBE0019),
                                  hintText: "Quantité"),
                              keyboardType: TextInputType.number,
                              controller: quantite,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  fillColor: Color(0xFFBE0019),
                                  hintText: "Adresse"),
                              controller: adresse,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  fillColor: Color(0xFFBE0019),
                                  hintText: "Contact"),
                              keyboardType: TextInputType.number,
                              controller: contact,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  fillColor: Color(0xFFBE0019),
                                  hintText: "Nom du client"),
                              controller: nomClient,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                fillColor: Color(0xFFBE0019),
                                hintText: "Date de Livraison",
                              ),
                              keyboardType: null,
                              controller: dateLivraison,
                              focusNode: _focus,
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          dropdownRef = "Reference Produit";
                                          quantite.text = "";
                                          adresse.text = "";
                                          contact.text = "";
                                          nomClient.text = "";
                                          dateLivraison.text = "";
                                        });
                                      },
                                      textColor: Color(0xFFBE0019),
                                      padding: EdgeInsets.all(8.0),
                                      splashColor: Color(0xFFBE0019),
                                      child: Text(
                                        "EFFACER",
                                        style: TextStyle(
                                          fontFamily: "ProductSans",
                                        ),
                                      )),
                                  RaisedButton(
                                      onPressed: isDisable
                                          ? null
                                          : () {
                                              _confirmCommande();
                                            },
                                      elevation: 6,
                                      disabledColor: Colors.grey,
                                      color: Color(0xFFBE0019),
                                      textColor: Colors.white,
                                      padding: EdgeInsets.all(8.0),
                                      splashColor: Color(0xFFBE0019),
                                      child: Text(
                                        "VALIDER",
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

  Future<void> _confirmCommande({bool validate: false}) async {
    if (validate) {
      Commande commande = Commande(
          refProduit: dropdownRef.contains('--')
              ? dropdownRef.split('--')[1].trim()
              : dropdownRef,
          quantite: int.parse(quantite.text),
          adresse: adresse.text,
          contact: contact.text,
          client: nomClient.text,
          dateLivraison: _dateLivraison,
          dateCommande: DateTime.now());

      bool val = await insertCommande(commande);
      setState(() {
        isDisable = false;
        _saving = false;
      });
      if (val) {
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
                "Commande effectuée",
                style:
                    TextStyle(color: Colors.green, fontFamily: "ProductSans"),
              )),
              actions: <Widget>[
                FlatButton(
                  textColor: Color(0xFFBE0019),
                  child: Text(
                    'Fermer',
                    style: TextStyle(
                      fontFamily: "ProductSans",
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _saving = true;
                      dropdownRef = "Reference Produit";
                      _produit = ["Reference Produit"];
                    });
                    listProd();
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
    } else {
      String retVal;
      RegExp _numeric = RegExp(r'^[0-9]+$');
      if (dropdownRef == "Reference Produit")
        retVal = "Champ Produit doit être défini";
      else if (!_numeric.hasMatch(quantite.text))
        retVal = "Vérifier la quantité entrée";
      else if (adresse.text == "")
        retVal = "Champ Adresse doit être défini";
      else if (contact.text == "")
        retVal = "Champ contact doit être défini";
      else if (dateLivraison.text == "")
        retVal = "Date de livraison doit être défini";
      else {
        int _count = 0;
        for (String pd in _produit) {
          if (pd == dropdownRef) {
            if (int.parse(quantite.text) > _produitStock[_count])
              retVal =
                  "Désolé, Il ne reste que ${_produitStock[_count]} en stock";
            break;
          }
          _count++;
        }
      }

      if (retVal != null) {
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
                retVal,
                style: TextStyle(
                    color: Color(0xFFBE0019), fontFamily: "ProductSans"),
              )),
              actions: <Widget>[
                FlatButton(
                  textColor: Color(0xFFBE0019),
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
      } else
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
                "Voulez-vous enregistrer cette commande?",
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
                    'Continuer',
                    style: TextStyle(
                      fontFamily: "ProductSans",
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      isDisable = true;
                      _saving = true;
                    });
                    _confirmCommande(validate: true);
                  },
                ),
              ],
            );
          },
        );
    }
  }

  void showQrCode() {
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          left: MediaQuery.of(context).size.width * 0.05,
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderColor: Color(0xFFBE0019),
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: 300,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(
                            color: Colors.white,
                            shape: CircleBorder(),
                            onPressed: () {
                              overlayEntry.remove();
                            },
                            child: Icon(Icons.close, color: Color(0xFFBE0019)),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )),
        );
      },
    );
    Overlay.of(context).insert(overlayEntry);
    controller?.resumeCamera();
  }

  _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if (_produitTmp.contains(scanData.code)) {
          overlayEntry.remove();
          dropdownRef = _produit[_produitTmp.indexOf(scanData.code)];
        } else {
          Flushbar(
            message: "Produit Non Disponible",
            duration: Duration(seconds: 3),
          ).show(context);
        }
      });
      overlayEntry.remove();
    });
  }
}
