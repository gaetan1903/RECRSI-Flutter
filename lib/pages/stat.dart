import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:recrsi/models/utils.dart';

class StatistiquePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StatistiquePage();
  }
}

class _StatistiquePage extends State<StatistiquePage> {
  bool _isload1 = false;
  bool _isload2 = false;
  bool _isload0 = false;
  int _dlivr = 0;
  int _mlivr = 0;
  int _dbenf = 0;
  int _mbenf = 0;
  FocusNode _focus0 = FocusNode();
  FocusNode _focus1 = FocusNode();
  final dayStat = TextEditingController();
  final monthStat = TextEditingController();
  DateTime statD = DateTime.now();
  DateTime statM = DateTime.now();
  List<ListTile> detailProduit = [];

  Future _getDetail(String dday) async {
    var res = await getDetail(dday);
    print(res);
    detailProduit.clear();
    setState(() {
      _isload0 = false;
    });
    if (res == null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              "Erreur ",
              style: TextStyle(fontFamily: "ProductSans"),
            ),
            children: <Widget>[
              Text("Une erreur s'est produite",
                  style: TextStyle(fontFamily: "ProductSans")),
            ],
          );
        },
      );
    }
    for (var row in res) {
      detailProduit.add(ListTile(
        title: Text("${row[1]} ${row[0]}",
            style: TextStyle(fontFamily: "ProductSans")),
        subtitle: Text("nombre: ${row[2]} \nbenefice: ${beautyNumber(row[3])}",
            style: TextStyle(fontFamily: "ProductSans")),
        leading: Icon(Icons.details, color: Color(0xFFBE0019)),
      ));
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Détail Statistique",
            style: TextStyle(fontFamily: "ProductSans"),
          ),
          children: <Widget>[
            Container(
                height: 200,
                child: ListView(
                  children: detailProduit,
                )),
            FlatButton(
              textColor: Color(0xFFBE0019),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Fermer",
                style: TextStyle(fontFamily: "ProductSans"),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _changeDay();
    _changeMonth();
    super.initState();
    _focus0.addListener(() {
      if (_focus0.hasFocus) _selectDate(context);
    });
    _focus1.addListener(() {
      if (_focus1.hasFocus) _selectMonth();
    });
    _statDay(statD);
    _statMonth(statM);
  }

  _changeDay() {
    dayStat.text = "${statD.day} ${getMonthLetter(statD.month)} ${statD.year}";
  }

  _changeMonth() {
    monthStat.text = "${getMonthLetter(statM.month)} ${statM.year}";
  }

  Future<Null> _selectDate(BuildContext context) async {
    DateTime _datePicker = await showDatePicker(
      context: context,
      initialDate: statD,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (_datePicker != null) {
      statD = _datePicker;
      setState(() {
        _changeDay();
      });
      _statDay(statD);
    }
    FocusManager.instance.primaryFocus.unfocus();
  }

  Future _statDay(DateTime sday) async {
    setState(() {
      _isload1 = true;
    });
    String day = "${sday.year}/${sday.month}/${sday.day}";
    var res = await statDaily(day);

    if (res == null) {
      setState(() {
        _dlivr = null;
        _dbenf = null;
      });
    } else {
      for (var row in res) {
        setState(() {
          _dlivr = row[0].round();
          _dbenf = row[1].round();
        });
      }
    }
    setState(() {
      _isload1 = false;
    });
  }

  Future _statMonth(DateTime sday) async {
    setState(() {
      _isload2 = true;
    });
    var res = await statMonthly(sday);

    if (res == null) {
      setState(() {
        _mlivr = null;
        _mbenf = null;
      });
    } else {
      for (var row in res) {
        setState(() {
          _mlivr = row[0].round();
          _mbenf = row[1].round();
        });
      }
    }
    setState(() {
      _isload2 = false;
    });
  }

  _selectMonth() async {
    showMonthPicker(
      context: context,
      firstDate: DateTime(2021, 5),
      lastDate: DateTime(DateTime.now().year + 1, 9),
      initialDate: DateTime.now(),
      locale: Locale("fr"),
    ).then(
      (date) {
        if (date != null) {
          setState(() {
            statM = date;
            _changeMonth();
            _isload2 = true;
          });
          _statMonth(statM);
        }
      },
    );

    FocusManager.instance.primaryFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Statistique",
            style: TextStyle(
              fontFamily: "ProductSans",
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: LoadingOverlay(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 50,
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.35,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: LoadingOverlay(
                        color: Colors.white,
                        progressIndicator: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFBE0019)),
                          strokeWidth: 2,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Stat Journalier",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFFBE0019),
                                      fontFamily: "ProductSans")),
                              TextField(
                                style: TextStyle(fontFamily: "ProductSans"),
                                decoration: InputDecoration(
                                  fillColor: Color(0xFFBE0019),
                                  hintText: "Statistique Date",
                                ),
                                keyboardType: null,
                                controller: dayStat,
                                focusNode: _focus0,
                              ),
                              RichText(
                                  text: TextSpan(
                                      style:
                                          TextStyle(fontFamily: "ProductSans"),
                                      children: [
                                    TextSpan(
                                        text: "Livrée:   ",
                                        style: TextStyle(
                                            color: Color(0xFFBE0019))),
                                    TextSpan(
                                        text: "  ${beautyNumber(_dlivr)}",
                                        style: TextStyle(color: Colors.black)),
                                  ])),
                              RichText(
                                  text: TextSpan(
                                      style:
                                          TextStyle(fontFamily: "ProductSans"),
                                      children: [
                                    TextSpan(
                                        text: "Benéfice:   ",
                                        style: TextStyle(
                                            color: Color(0xFFBE0019))),
                                    TextSpan(
                                        text: "  ${beautyNumber(_dbenf)}",
                                        style: TextStyle(color: Colors.black)),
                                  ])),
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      _isload0 = true;
                                    });
                                    String cond =
                                        'date_stat = "${statD.year}-${statD.month}-${statD.day}"';
                                    _getDetail(cond);
                                  },
                                  color: Color(0xFFBE0019),
                                  textColor: Colors.white,
                                  child: Text(
                                    "Détails",
                                    style: TextStyle(fontFamily: "ProductSans"),
                                  ))
                            ]),
                        isLoading: _isload1),
                  )),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 50,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.35,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  alignment: Alignment.center,
                  child: LoadingOverlay(
                      color: Colors.white,
                      progressIndicator: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFBE0019)),
                        strokeWidth: 2,
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Stat Mensuel",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFBE0019),
                                    fontFamily: "ProductSans")),
                            TextField(
                              style: TextStyle(fontFamily: "ProductSans"),
                              decoration: InputDecoration(
                                fillColor: Color(0xFFBE0019),
                                hintText: "Statistique Date",
                              ),
                              keyboardType: null,
                              controller: monthStat,
                              focusNode: _focus1,
                            ),
                            RichText(
                                text: TextSpan(
                                    style: TextStyle(fontFamily: "ProductSans"),
                                    children: [
                                  TextSpan(
                                      text: "Livrée:   ",
                                      style:
                                          TextStyle(color: Color(0xFFBE0019))),
                                  TextSpan(
                                      text: "  ${beautyNumber(_mlivr)}",
                                      style: TextStyle(color: Colors.black)),
                                ])),
                            RichText(
                                text: TextSpan(
                                    style: TextStyle(fontFamily: "ProductSans"),
                                    children: [
                                  TextSpan(
                                      text: "Benéfice:   ",
                                      style:
                                          TextStyle(color: Color(0xFFBE0019))),
                                  TextSpan(
                                      text: "  ${beautyNumber(_mbenf)}",
                                      style: TextStyle(color: Colors.black)),
                                ])),
                            FlatButton(
                                onPressed: () {
                                  setState(() {
                                    _isload0 = true;
                                  });
                                  String cond =
                                      'MONTH(date_stat) = "${statM.month}" AND YEAR(date_stat) = "${statM.year}" ';
                                  _getDetail(cond);
                                },
                                color: Color(0xFFBE0019),
                                textColor: Colors.white,
                                child: Text(
                                  "Détails",
                                  style: TextStyle(fontFamily: "ProductSans"),
                                ))
                          ]),
                      isLoading: _isload2),
                ),
              )
            ],
          )),
          isLoading: _isload0,
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
