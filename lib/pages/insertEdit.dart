import 'package:flutter/material.dart';
import 'package:recrsi/models/models.dart';
import 'package:recrsi/models/utils.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ProductPage extends StatefulWidget {
  ProductPage({Key key, this.title, this.row}) : super(key: key);
  final String title;
  final row;

  @override
  _ProductPage createState() => _ProductPage();
}

class _ProductPage extends State<ProductPage> {
  final nomProduit = TextEditingController();
  final reference = TextEditingController();
  final dispo = TextEditingController();
  final prixAchat = TextEditingController();
  final prixVente = TextEditingController();
  bool _saving = false;
  OverlayEntry overlayEntry;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  @override
  void initState() {
    if (widget.row != null) {
      nomProduit.text = widget.row[2];
      reference.text = widget.row[1];
      prixAchat.text = "${widget.row[3]}";
      prixVente.text = "${widget.row[4]}";
      dispo.text = "${widget.row[5]}";
    }
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              fontFamily: "ProductSans",
            ),
          ),
        ),
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
                            vertical:
                                MediaQuery.of(context).size.height * 0.02),
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
                                  child: Text("Nouveau Produit",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFBE0019),
                                          fontFamily: "ProductSans"))),
                              TextField(
                                decoration: InputDecoration(
                                    fillColor: Color(0xFFBE0019),
                                    hintText: "Nom Produit"),
                                controller: nomProduit,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    fillColor: Color(0xFFBE0019),
                                    suffix: IconButton(
                                      icon: Icon(Icons.camera_alt_outlined,
                                          color: Color(0xFFBE0019)),
                                      onPressed: () {
                                        showQrCode();
                                      },
                                    ),
                                    hintText: "Reference Produit"),
                                controller: reference,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    fillColor: Color(0xFFBE0019),
                                    hintText: "Stock"),
                                keyboardType: TextInputType.number,
                                controller: dispo,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    fillColor: Color(0xFFBE0019),
                                    hintText: "Prix d'Achat"),
                                keyboardType: TextInputType.number,
                                controller: prixAchat,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    fillColor: Color(0xFFBE0019),
                                    hintText: "Prix de Vente"),
                                keyboardType: TextInputType.number,
                                controller: prixVente,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 15),
                                child: RaisedButton(
                                    onPressed: () {
                                      _confirmProduit();
                                    },
                                    elevation: 10,
                                    color: Color(0xFFBE0019),
                                    textColor: Colors.white,
                                    padding: EdgeInsets.all(8.0),
                                    splashColor: Color(0xFFBE0019),
                                    child: Text(
                                      widget.row == null
                                          ? "Enregistrer"
                                          : "Mettre à jour",
                                      style: TextStyle(
                                        fontFamily: "ProductSans",
                                      ),
                                    )),
                              )
                            ]),
                      ),
                    ))),
            isLoading: _saving));
  }

  Future<void> _confirmProduit({bool validate: false}) async {
    if (validate) {
      Produit prod = Produit(
          nomProduit: nomProduit.text,
          reference: reference.text,
          prixAchat: int.parse(prixAchat.text),
          prixVente: int.parse(prixVente.text),
          dispo: int.parse(dispo.text));

      bool val = widget.row == null
          ? await insertProduit(prod)
          : await updateProduit(prod);
      setState(() {
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
                widget.row == null
                    ? "Insertion effectuée"
                    : "Modification effectuée",
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
      if (!_numeric.hasMatch(dispo.text))
        retVal = "Vérifier le nombre stock";
      else if (!_numeric.hasMatch(prixAchat.text))
        retVal = "Vérifier le prix d'achat entrée";
      else if (!_numeric.hasMatch(prixVente.text))
        retVal = "Vérifier le prix de vente entrée";
      else if (nomProduit.text == "")
        retVal = "Verifier le nom du produit";
      else if (reference.text == "")
        retVal = "Champ reference doit être défini";

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
                  child: Text('Fermer'),
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
                widget.row == null
                    ? "Confirmez-vous l'ajout du nouveau produit?"
                    : "Apportez-vous ces modifications?",
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
                      _saving = true;
                    });
                    _confirmProduit(validate: true);
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
          top: MediaQuery.of(context).size.height * 0.15,
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
        reference.text = scanData.code;
      });
      overlayEntry.remove();
    });
  }
}
