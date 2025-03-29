import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'EventVerifPage.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _dateDebutController = TextEditingController();
  TextEditingController _dateFinController = TextEditingController();
  TextEditingController _heureController = TextEditingController();
  TextEditingController _heureFinController = TextEditingController();
  TextEditingController _titreController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  
  File? _imageFile;
  late final SupabaseClient _client;
  late final Stream<List<Map<String, dynamic>>> _actualitesStream;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDateFin = DateTime.now();
  List<DateTime> _actualiteDates = []; // Liste des dates réservées
  bool _isLoading = false;

  // Méthode pour prendre une image avec la caméra ou la galerie
  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  // Afficher un dialogue pour choisir la source de l'image
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.teal[50],
          title: Text('Choisir une source', style: TextStyle(color: Colors.teal[900])),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library, color: Colors.teal),
                  title: Text('Galerie'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Colors.teal),
                  title: Text('Caméra'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;

    // Écouter les changements dans la table 'actualites' en temps réel
    _actualitesStream = _client
        .from('actualites')
        .stream(primaryKey: ['id'])
        .eq('statut', 'pending')
        .execute();

    // Écouter les données du flux
    _actualitesStream.listen((data) {
      setState(() {
        _actualiteDates = data
            .map((actualite) => DateTime.parse(actualite['date_debut']))
            .toList();
      });
    }, onError: (error) {
      print('Erreur lors de l\'écoute des actualite : $error');
    });
  }

  // Formater la date
  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  // Fonction pour vérifier si une date est réservée
  bool _isDateReserved(DateTime date) {
    return _actualiteDates.any((actualiteDates) =>
        actualiteDates.year == date.year &&
        actualiteDates.month == date.month &&
        actualiteDates.day == date.day);
  }

  // Fonction pour afficher le sélecteur de date avec dates réservées grises
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate ? _selectedDate : _selectedDateFin;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.teal[50]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
      selectableDayPredicate: (DateTime day) {
        // Griser les dates réservées
        if (isStartDate) {
          return !_isDateReserved(day) && day.isAfter(DateTime.now().subtract(Duration(days: 1)));
        } else {
          return !_isDateReserved(day) && day.isAfter(_selectedDate.subtract(Duration(days: 1)));
        }
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedDate = picked;
          _dateDebutController.text = _formatDate(_selectedDate);
          // Si la date de fin est avant la date de début, la mettre à jour
          if (_selectedDateFin.isBefore(_selectedDate)) {
            _selectedDateFin = _selectedDate;
            _dateFinController.text = _formatDate(_selectedDateFin);
          }
        } else {
          _selectedDateFin = picked;
          _dateFinController.text = _formatDate(_selectedDateFin);
        }
      });
    }
  }

  // Fonction pour sélectionner une heure
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay initialTime = controller == _heureController 
        ? TimeOfDay.now() 
        : TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
        
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.teal[50]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  // Validation de formulaire
  bool _validateForm() {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      return true;
    } else {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Veuillez ajouter une image pour l'événement"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Créer un événement',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section d'image
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Affiche de l'événement",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[900],
                            ),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              height: h * 0.25,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.teal[200]!, width: 1),
                              ),
                              child: _imageFile == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 64,
                                          color: Colors.teal,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Ajouter une affiche',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.teal[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Section des détails de l'événement
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Détails de l'événement",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[900],
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Titre de l'événement
                          TextFormField(
                            controller: _titreController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Le titre est obligatoire";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Titre de l'événement",
                              labelStyle: TextStyle(color: Colors.teal[700]),
                              prefixIcon: Icon(Icons.title, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.teal[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.teal, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Date de début et Date de fin
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _dateDebutController,
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Date requise";
                                    }
                                    return null;
                                  },
                                  onTap: () => _selectDate(context, true),
                                  decoration: InputDecoration(
                                    labelText: "Date de début",
                                    labelStyle: TextStyle(color: Colors.teal[700]),
                                    prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.teal, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _dateFinController,
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Date requise";
                                    }
                                    return null;
                                  },
                                  onTap: () => _selectDate(context, false),
                                  decoration: InputDecoration(
                                    labelText: "Date de fin",
                                    labelStyle: TextStyle(color: Colors.teal[700]),
                                    prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.teal, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Heures
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _heureController,
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Heure requise";
                                    }
                                    return null;
                                  },
                                  onTap: () => _selectTime(context, _heureController),
                                  decoration: InputDecoration(
                                    labelText: "Heure de début",
                                    labelStyle: TextStyle(color: Colors.teal[700]),
                                    prefixIcon: Icon(Icons.access_time, color: Colors.teal),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.teal, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _heureFinController,
                                  readOnly: true,
                                  validator: (value) {
                                    // Cette validation est optionnelle si l'heure de fin n'est pas obligatoire
                                    return null;
                                  },
                                  onTap: () => _selectTime(context, _heureFinController),
                                  decoration: InputDecoration(
                                    labelText: "Heure de fin",
                                    labelStyle: TextStyle(color: Colors.teal[700]),
                                    prefixIcon: Icon(Icons.access_time, color: Colors.teal),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.teal, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "La description est obligatoire";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Description de l'événement",
                              labelStyle: TextStyle(color: Colors.teal[700]),
                              alignLabelWithHint: true,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 80),
                                child: Icon(Icons.description, color: Colors.teal),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.teal, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Bouton de soumission
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading 
                          ? null 
                          : () {
                              if (_validateForm()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                // Simuler un chargement pour montrer l'animation
                                Future.delayed(Duration(milliseconds: 500), () {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VerificationPage(
                                        dateDebut: _dateDebutController.text,
                                        dateFin: _dateFinController.text,
                                        heure: _heureController.text,
                                        titre: _titreController.text,
                                        heureFin: _heureFinController.text,
                                        description: _descriptionController.text,
                                        image: _imageFile,
                                      ),
                                    ),
                                  );
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        elevation: 8,
                        shadowColor: Colors.teal.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,color: Colors.white,),
                                SizedBox(width: 8),
                                Text(
                                  'Vérifier les informations',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}