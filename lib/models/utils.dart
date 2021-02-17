import 'package:mysql1/mysql1.dart';
import 'config.dart';
import 'models.dart';

Future mainDB(List<String> condition) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    var results = await conn.query('''
      SELECT 
        C.id, P.nomProduit, P.reference, C.adresse, C.contact, C.client, 
        C.dateLivraison, C.status, C.quantite
      FROM Commande C JOIN Produit P on C.ref_produit = P.reference
      WHERE ${condition[0]} and ${condition[1]}
      ORDER BY C.dateLivraison
    ''');

    await conn.close();

    return results;
  } catch (e) {
    print(e);
    return null;
  }
}

Future login(usr, passwd, {verif = false}) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    String condVerif = verif == true ? "?" : "password = SHA2(?, 224)";

    var res = await conn.query("""
      SELECT fonction FROM Personnel
      WHERE username = ? AND $condVerif
    """, [usr, passwd]);

    await conn.close();

    return res;
  } catch (err) {
    print(err);
    return [];
  }
}

Future<bool> insertCommande(Commande commande) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    await conn.query('''
    INSERT INTO Commande(
      ref_produit, quantite, adresse, contact, client, dateCommande, dateLivraison
    ) VALUES ( 
      ?, ?, ?, ?, ?, ?, ?
    )
    ''', [
      commande.refProduit,
      commande.quantite,
      commande.adresse,
      commande.contact,
      commande.client,
      "${commande.dateCommande.year}/${commande.dateCommande.month}/${commande.dateCommande.day}",
      "${commande.dateLivraison.year}/${commande.dateLivraison.month}/${commande.dateLivraison.day}",
    ]);

    await conn.query('''
      UPDATE Produit SET
        dispo = dispo - ${commande.quantite},
        encommande = encommande + ${commande.quantite}
      WHERE reference = ?
    ''', [commande.refProduit]);

    await conn.close();

    return true;
  } catch (err) {
    print(err);
    return false;
  }
}

Future prodDispo() async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    var results = await conn.query('''
      SELECT reference FROM Produit WHERE dispo > 0
     ''');

    await conn.close();
    return results;
  } catch (e) {
    return [];
  }
}

Future<bool> majStatus(String status, int id, int quantite) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    await conn
        .query('UPDATE Commande SET status = ? WHERE id = ?', [status, id]);

    String condition;

    if (status == "LIVREE")
      condition = "  encommande=encommande-$quantite";
    else if (status == "ANNULEE")
      condition = "dispo=dispo+$quantite, encommande=encommande-$quantite";
    else
      condition = "1";

    print(condition);
    await conn.query('''
      UPDATE Produit SET $condition WHERE reference = (
        SELECT ref_produit FROM Commande WHERE id = ?
      )''', [id]);

    await conn.close();

    return true;
  } catch (err) {
    print(err);
    return false;
  }
}

Future showAllProduct({String query: "1"}) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    var res = await conn.query("""
      SELECT id, reference, nomProduit, prixAchat, prixVente, dispo, encommande
      FROM Produit WHERE $query ORDER BY dispo DESC
    """);
    await conn.close();

    return res;
  } catch (err) {
    print(err);
    return null;
  }
}

String beautyNumber(int num) {
  String val = "$num".split('').reversed.join();
  String newVal = "";

  for (int i = 0; i < val.length; i++) {
    if (i % 3 == 0) newVal += " ";
    newVal += val[i];
  }

  return newVal.split('').reversed.join();
}

Future<bool> insertProduit(Produit prod) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    await conn.query('''
      INSERT INTO Produit 
        (nomProduit, reference, dispo, prixAchat, prixVente)
      VALUES
        (?, ?, ?, ?, ?)
    ''', [
      prod.nomProduit,
      prod.reference,
      prod.dispo,
      prod.prixAchat,
      prod.prixVente
    ]);

    await conn.close();

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> updateProduit(Produit prod) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    await conn.query('''
      UPDATE Produit SET
        nomProduit = ?, dispo = ?, prixAchat = ?, prixVente = ?
      WHERE reference = ?
    ''', [
      prod.nomProduit,
      prod.dispo,
      prod.prixAchat,
      prod.prixVente,
      prod.reference
    ]);

    await conn.close();

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future statDaily(day) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    var res = await conn.query('''
        SELECT

        CASE 
          WHEN SUM(nombre) is Null
          THEN 0 ELSE SUM(nombre)
        END as nombre,

        CASE
          WHEN SUM(benefice) is Null
          THEN 0 ELSE SUM(benefice)
        END as benefice 

        FROM Statistique 

        WHERE date_stat = ?
      ''', [day]);

    await conn.close();

    return res;
  } catch (err) {
    print(err);
    return null;
  }
}

Future statMonthly(DateTime day) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    var res = await conn.query('''
        SELECT

        CASE 
          WHEN SUM(nombre) is Null
          THEN 0 ELSE SUM(nombre)
        END as nombre,

        CASE
          WHEN SUM(benefice) is Null
          THEN 0 ELSE SUM(benefice)
        END as benefice 

        FROM Statistique 

        WHERE MONTH(date_stat) = ? AND YEAR(date_stat) = ?
      ''', [day.month, day.year]);

    await conn.close();

    return res;
  } catch (err) {
    print(err);
    return null;
  }
}

Future<bool> updatePasswd(String usr, String passwd) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    await conn.query('''
      UPDATE Personnel SET password = SHA2(?, 224)
      WHERE username = ?
    ''', [passwd, usr]);

    await conn.close();

    return true;
  } catch (err) {
    print(err);
    return false;
  }
}

Future getDetail(String condition) async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db));

    var res = await conn.query('''
        SELECT C.ref_produit, P.nomProduit, S.nombre, S.benefice
        FROM Statistique S JOIN Commande C 
        ON S.id_commande = C.id JOIN Produit P
        ON C.ref_produit = P.reference
        WHERE $condition
    ''');

    await conn.close();

    return res;
  } catch (err) {
    print(err);
    return false;
  }
}

getMonthLetter(int m) {
  switch (m) {
    case 1:
      {
        return "Janvier";
      }
      break;
    case 2:
      {
        return "Fevrier";
      }
      break;
    case 3:
      {
        return "Mars";
      }
      break;
    case 4:
      {
        return "Avril";
      }
      break;
    case 5:
      {
        return "Mai";
      }
      break;
    case 6:
      {
        return "Juin";
      }
      break;
    case 7:
      {
        return "Juillet";
      }
      break;
    case 8:
      {
        return "Août";
      }
      break;
    case 9:
      {
        return "Septembre";
      }
      break;
    case 10:
      {
        return "Octobre";
      }
      break;
    case 11:
      {
        return "Novembre";
      }
      break;
    case 12:
      {
        return "Decembre";
      }
      break;
  }
}
