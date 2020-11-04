CREATE TRIGGER before_insert_stat BEFORE INSERT  
ON Statistique FOR EACH ROW 
BEGIN 
    SET NEW.date_stat = CURDATE(), 
    NEW.benefice = (NEW.prixVente - NEW.prixAchat) * NEW.nombre ;  
END |



CREATE TRIGGER after_update_commande AFTER UPDATE 
ON Commande FOR EACH ROW 
BEGIN
    IF NEW.status = "LIVREE" THEN
        INSERT INTO Statistique (prixAchat, prixVente, nombre, id_commande)
        VALUES (
            (SELECT prixAchat FROM Produit WHERE reference = NEW.ref_produit), 
            (SELECT prixVente FROM Produit WHERE reference = NEW.ref_produit),
            NEW.quantite,
            NEW.id
        );
    ELSEIF NEW.status ="ANNULEE" AND OLD.status = "LIVREE" THEN
        DELETE FROM Statistique WHERE id_commande = NEW.id;
    END IF;
END |