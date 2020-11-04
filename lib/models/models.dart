class Commande {
  int id = 0;
  String refProduit;
  int quantite;
  String adresse;
  String contact;
  String client = "";
  DateTime dateCommande;
  DateTime dateLivraison;
  String status = "NON LIVREE";

  Commande(
      {this.id,
      this.refProduit,
      this.quantite,
      this.adresse,
      this.contact,
      this.client,
      this.dateCommande,
      this.dateLivraison,
      this.status});
}

class Produit {
  int id;
  String nomProduit;
  String reference;
  int dispo;
  int prixAchat;
  int prixVente;

  Produit(
      {this.id,
      this.nomProduit,
      this.reference,
      this.dispo,
      this.prixAchat,
      this.prixVente});
}
