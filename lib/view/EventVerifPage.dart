import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour gérer les formats de date
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'ActualitePage.dart';  // Import Supabase Flutter
import 'package:path/path.dart' as path_utils; // Utilisez un alias pour éviter les conflits



class VerificationPage extends StatefulWidget {
  final String dateDebut;
  final String dateFin;
  final String heure;
  final String titre;
  final String heureFin;
  final String description;
  final File? image;

  VerificationPage({
    required this.dateDebut,
    required this.dateFin,
    required this.heure,
    required this.heureFin,
    required this.description,
    required this.image,
    required this.titre,
  });

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final SupabaseClient _client = Supabase.instance.client; // Client Supabase
  bool _isLoading = false;  // Ajout de l'état de chargement
  // Variables pour gérer les options de paiement sélectionnées
  bool isOrangeMoneySelected = false;
  bool isCreditCardSelected = false;
  bool isVisaCardSelected = false;
  late Database _database; // Instance de la base de données SQLite



  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = path_utils.join(dbPath, 'events.db');


    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            supabase_id TEXT,
            titre TEXT,
          )
        ''');
      },
    );
  }

  Future<void> _saveToSQLite(String supabaseId, String titre) async {
    await _database.insert(
      'events',
      {
        'supabase_id': supabaseId,
        'titre': titre,

      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Événement enregistré localement avec succès.');
  }

  Future<void> _saveEvent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      // Upload de l'image vers Supabase (si disponible)
      if (widget.image != null) {
        final path = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _client.storage.from('uploads').upload(path, widget.image!);
        imageUrl = _client.storage.from('uploads').getPublicUrl(path);
      }

      // Enregistrement dans Supabase
      final response = await _client.from('actualites').insert([
        {
          'date_debut': widget.dateDebut,
          'date_fin': widget.dateFin,
          'heure': widget.heure,
          'resume': widget.description,
          'titre': widget.titre,
          'statut': 'Payer',
          'image_url': imageUrl ?? '',
        }
      ]).select('id').single();

      // Récupération de l'ID généré par Supabase
      final String supabaseId = response['id'].toString();
      print(supabaseId );
      print(widget.titre );

      // Enregistrement dans SQLite
      await _saveToSQLite(supabaseId, widget.titre);

      // Succès : afficher un message et rediriger
      _showSuccessDialog();
    } catch (e) {
      print('Erreur lors de l\'enregistrement : $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de l\'enregistrement. Veuillez réessayer.')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  // Fonction pour formater la date de publication
  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);  // Exemple : 5 Oct 2024
  }

/*
  // Méthode pour enregistrer les informations de l'événement dans la table spécifique
  Future<void> _saveEvent() async {
    try {
      String? imageUrl;

      // Uploader l'image (si elle existe)
      if (widget.image != null) {
        final path = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';  // Crée un chemin unique pour l'image
        await _client.storage.from('uploads').upload(path, widget.image!);

        // Récupérer l'URL publique de l'image après l'upload
        imageUrl = _client.storage.from('uploads').getPublicUrl(path);
      }

      // Enregistrer les informations dans la table "events"
      await _client.from('actualites').insert([
        {
          'date_debut': widget.dateDebut,
          'date_fin': widget.dateFin,
          'heure': widget.heure,
          'resume': widget.description,
          'titre': widget.titre,
          'statut': 'Payer',
          'image_url': imageUrl ?? '', // Si pas d'image, on laisse un champ vide
        }
      ]).select('id').single();

      // Afficher un message de succès avec la boîte de dialogue
      _showSuccessDialog();

    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'événement : $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de l\'enregistrement. Veuillez réessayer.')));
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'events.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE events(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          supabase_id TEXT,
          titre TEXT,
          description TEXT,
          image_url TEXT
        )
      ''');
      },
    );
  }

  Future<void> _saveToLocalDatabase(String supabaseId, String titre, String description, String? imageUrl) async {
    final db = await _initDatabase();

    await db.insert(
      'events',
      {
        'supabase_id': supabaseId,
        'titre': titre,
        'description': description,
        'image_url': imageUrl ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('Événement enregistré dans SQLite avec succès.');
  }
*/

  void _showSuccessDialog() {
    Future.delayed(Duration(milliseconds: 10), () {
      setState(() {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) { // Renommé en "dialogContext"
            return AlertDialog(
              backgroundColor: Colors.teal[50],
              title: Text(
                "Succès",
                style: TextStyle(color: Colors.teal[900], fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Text(
                "L'événement a été enregistré avec succès.",
                style: TextStyle(color: Colors.black, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Fermer la boîte de dialogue
                      Navigator.of(dialogContext).pop(); // Utilise "dialogContext" ici

                      // Rediriger vers une autre page après le succès
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ActualitePage()),
                      );
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    });
  }




  @override
  Widget build(BuildContext context) {
    try {
      // Convertir les dates string en DateTime avec un format qui accepte les mois en texte (ex : 28 Nov 2024)
      DateTime dateDebutParsed = DateFormat('d MMM yyyy').parse(widget.dateDebut);
      DateTime dateFinParsed = DateFormat('d MMM yyyy').parse(widget.dateFin);

      // Formater les dates en texte avec le format d MMM yyyy
      String formattedDateDebut = _formatDate(dateDebutParsed);
      String formattedDateFin = _formatDate(dateFinParsed);

      double w = MediaQuery.of(context).size.width;
      double h = MediaQuery.of(context).size.height;

      return Scaffold(
        backgroundColor: Colors.teal[50],
        appBar: AppBar(
          backgroundColor: Colors.teal[50],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 40, color: Colors.teal[900]),
            onPressed: () {
              Navigator.pop(context); // Retourne à la page précédente
            },
          ),
          title: Text(
            'Vérifier',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal[900]),
            textAlign: TextAlign.center,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text("Récapitulatif de la commande", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))),
                SizedBox(height: 20),
                Text("${widget.titre}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                // Affichage des informations de l'événement
                Row(
                  children: [
                    Text("Date de l'évènement :", style: TextStyle(fontSize: 18)),
                    SizedBox(width: 5),
                    Text("du $formattedDateDebut", style: TextStyle(fontSize: 18, color: Colors.teal[600])),
                  ],
                ),
                Text("au $formattedDateFin", style: TextStyle(fontSize: 18, color: Colors.teal[600])),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("Heure de l'évènement :  ", style: TextStyle(fontSize: 18)),
                    SizedBox(width: 5),
                    Text(" ${widget.heure}", style: TextStyle(fontSize: 18, color: Colors.teal[600])),
                  ],
                ),
                SizedBox(height: 10),
                // Affichage de l'image si elle existe
                Center(
                  child: widget.image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15), // Ajoute des bordures arrondies
                    child: Image.file(
                      widget.image!,
                      height: h * 0.15, // Vous pouvez ajuster la taille ici pour la rendre plus petite
                      width: w * 0.8, // Vous pouvez aussi définir une largeur spécifique
                      fit: BoxFit.cover, // Ajuste le contenu de l'image
                    ),
                  )
                      : Placeholder(fallbackHeight: 200),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total: ", style: TextStyle(fontSize: 18)),
                    Text("1000 FCFA", style: TextStyle(fontSize: 18, color: Colors.deepOrangeAccent)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rabais: ", style: TextStyle(fontSize: 18)),
                    Text("10 FCFA", style: TextStyle(fontSize: 18, color: Colors.deepOrangeAccent)),
                  ],
                ),
                Divider(  // Ligne de séparation
                  color: Colors.black,  // Couleur de la ligne
                  thickness: 1,         // Épaisseur de la ligne
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total: ", style: TextStyle(fontSize: 18)),
                    Text("990 FCFA", style: TextStyle(fontSize: 18, color: Colors.deepOrangeAccent)),
                  ],
                ),

                // Options de paiement avec des cases à cocher
                SizedBox(height: 10),
                Text("Méthode de paiement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                // Option Orange Money
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.1, horizontal: 0.0),
                  leading:  Image.asset(
                    'assets/icone/orange_Money.png',  // Remplacez par le chemin de votre image locale
                    width: 40,                      // Ajustez la largeur de l'image si nécessaire
                    height: 40,                     // Ajustez la hauteur de l'image si nécessaire
                  ),  // Icône pour Orange Money
                  title: Text("Orange Money", style: TextStyle(fontSize: 18)),
                  trailing: Checkbox(
                    value: isOrangeMoneySelected,
                    onChanged: (bool? value) {
                      setState(() {
                        isOrangeMoneySelected = value!;
                        if (value) {
                          isCreditCardSelected = false;
                          isVisaCardSelected = false;
                        }
                      });
                    },
                  ),
                ),

                // Option Carte Crédit
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.1, horizontal: 0.0),
                  leading:  Image.asset(
                    'assets/icone/card-classic.png',  // Remplacez par le chemin de votre image locale
                    width: 40,                      // Ajustez la largeur de l'image si nécessaire
                    height: 40,                     // Ajustez la hauteur de l'image si nécessaire
                  ),  // Icône pour Carte de Crédit
                  title: Text("Carte Crédit", style: TextStyle(fontSize: 18)),
                  trailing: Checkbox(
                    value: isCreditCardSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        isCreditCardSelected = value!;
                        if (value) {
                          isOrangeMoneySelected = false;
                          isVisaCardSelected = false;
                        }
                      });
                    },
                  ),
                ),
                // Option Carte Visa
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.1, horizontal: 0.0),
                  leading: Icon(Icons.credit_card, color: Colors.blue),  // Icône pour Carte Visa
                  title: Text("Carte Visa", style: TextStyle(fontSize: 18)),
                  trailing: Checkbox(
                    value: isVisaCardSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        isVisaCardSelected = value!;
                        if (value) {
                          isOrangeMoneySelected = false;
                          isCreditCardSelected = false;
                        }
                      });
                    },
                  ),
                ),

                SizedBox(height: 10),


                // Affichage du bouton de validation
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator() // Affiche l'animation de chargement pendant l'enregistrement
                      : Container(
                    width: w*0.6,
                    child: ElevatedButton(
                      onPressed:  _saveEvent,
                      child: Text("Valider et Enregistrer",style: TextStyle(fontSize: 18),),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal[600],
                        padding: EdgeInsets.symmetric(vertical: 16), // Un peu plus d'espace vertical
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      );
    } catch (e) {
      // En cas d'erreur de formatage, afficher un message d'erreur
      return Scaffold(
        appBar: AppBar(
          title: Text('Erreur'),
        ),
        body: Center(child: Text('Erreur de formatage des dates : $e')),
      );
    }
  }
}
