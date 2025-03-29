import 'package:flutter/material.dart';

class FormulaireDeclarationPage extends StatefulWidget {
  const FormulaireDeclarationPage({super.key});

  @override
  State<FormulaireDeclarationPage> createState() => _FormulaireDeclarationPageState();
}

class _FormulaireDeclarationPageState extends State<FormulaireDeclarationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _entrepriseController = TextEditingController();
  final TextEditingController _identificationController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _paysController = TextEditingController();
  final TextEditingController _secteurController = TextEditingController();
  final TextEditingController _dpoNomController = TextEditingController();
  final TextEditingController _dpoEmailController = TextEditingController();
  final TextEditingController _dpoTelController = TextEditingController();

  bool _isNomPrenomChecked = false;
  bool _isAdresseChecked = false;
  bool _isEmailChecked = false;
  bool _isPhoneChecked = false;
  bool _isDataCollecteChecked = false;
  bool _isSourcePartenaire = false;
  bool _isSourceAchetee = false;
  bool _isSourceAutre = false;

  String _message = ''; // Variable pour afficher le message de succès

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.shade100,
                Colors.teal.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Formulaire de déclaration des données",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Arrière-plan blanc
                borderRadius: BorderRadius.circular(12), // Bordures arrondies
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4), // Ombre portée
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16), // Padding autour du contenu
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1️⃣ Informations sur l’entité déclarante',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  _buildTextFormField('Nom de l’entreprise / organisation', _entrepriseController),
                  _buildTextFormField('Numéro d’identification', _identificationController),
                  _buildTextFormField('Adresse physique (siège social)', _adresseController),
                  // Ligne 1 : Deux champs sur la même ligne
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacement égal entre les champs
                    children: [
                      Expanded(child: _buildTextFormField('Pays d’hébergement des données', _paysController)),
                      const SizedBox(width: 10), // Espace entre les champs
                      Expanded(child: _buildTextFormField('Secteur d’activité', _secteurController)),
                    ],
                  ),
                  const SizedBox(height: 10), // Espacement entre les lignes

                  // Ligne 2 : Deux champs sur la même ligne
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacement égal entre les champs
                    children: [
                      Expanded(child: _buildTextFormField('Nom et fonction du responsable de la protection des données (DPO)', _dpoNomController)),
                      const SizedBox(width: 10), // Espace entre les champs
                      Expanded(child: _buildTextFormField('Email du DPO', _dpoEmailController)),
                    ],
                  ),
                  const SizedBox(height: 10), // Espacement entre les lignes

                  // Ligne 3 : Un champ sur une ligne seule
                  _buildTextFormField('Numéro de téléphone du DPO', _dpoTelController),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Description des données collectées
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Arrière-plan blanc
                borderRadius: BorderRadius.circular(12), // Bordures arrondies
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4), // L'ombre portée
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16), // Padding autour du contenu
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2️⃣ Description des données collectées',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  _buildCheckBoxFormField('Nom et prénom', (value) {
                    setState(() {
                      _isNomPrenomChecked = value!;
                    });
                  }, _isNomPrenomChecked),
                  _buildCheckBoxFormField('Adresse', (value) {
                    setState(() {
                      _isAdresseChecked = value!;
                    });
                  }, _isAdresseChecked),
                  _buildCheckBoxFormField('Email', (value) {
                    setState(() {
                      _isEmailChecked = value!;
                    });
                  }, _isEmailChecked),
                  _buildCheckBoxFormField('Numéro de téléphone', (value) {
                    setState(() {
                      _isPhoneChecked = value!;
                    });
                  }, _isPhoneChecked),
                  _buildCheckBoxFormField('Données biométriques', (value) {
                    setState(() {
                      _isDataCollecteChecked = value!;
                    });
                  }, _isDataCollecteChecked),
                  _buildCheckBoxFormField('Données bancaires', (value) {
                    setState(() {
                      _isDataCollecteChecked = value!;
                    });
                  }, _isDataCollecteChecked),
                  _buildCheckBoxFormField('Données de santé', (value) {
                    setState(() {
                      _isDataCollecteChecked = value!;
                    });
                  }, _isDataCollecteChecked),
                  const SizedBox(height: 10),
                  Text('Source des données :', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Colors.black)),
                  _buildCheckBoxFormField('Collectées directement auprès des utilisateurs', (value) {
                    setState(() {
                      _isSourcePartenaire = value!;
                    });
                  }, _isSourcePartenaire),
                  _buildCheckBoxFormField('Obténues via des partenaires', (value) {
                    setState(() {
                      _isSourcePartenaire = value!;
                    });
                  }, _isSourcePartenaire),
                  _buildCheckBoxFormField('Achetées auprès d’un tiers', (value) {
                    setState(() {
                      _isSourceAchetee = value!;
                    });
                  }, _isSourceAchetee),
                  _buildCheckBoxFormField('Autres', (value) {
                    setState(() {
                      _isSourceAutre = value!;
                    });
                  }, _isSourceAutre),
                  const SizedBox(height: 10),
                  Text('Finalité de la collecte des données :', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Colors.black)),
                  _buildCheckBoxFormField('Gestion des clients', (value) {
                    setState(() {
                      _isSourcePartenaire = value!;
                    });
                  }, _isSourcePartenaire),
                  _buildCheckBoxFormField('Marketing et publicités', (value) {
                    setState(() {
                      _isSourcePartenaire = value!;
                    });
                  }, _isSourcePartenaire),
                  _buildCheckBoxFormField('Sécurité et prévention des fraudes', (value) {
                    setState(() {
                      _isSourceAchetee = value!;
                    });
                  }, _isSourceAchetee),
                  _buildCheckBoxFormField('Autres', (value) {
                    setState(() {
                      _isSourceAutre = value!;
                    });
                  }, _isSourceAutre),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Ajout du message de succès
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Simuler une soumission
                      setState(() {
                        // Afficher le message de succès
                        _message = 'Message soumis avec succès';

                        // Réinitialiser les champs du formulaire
                        _entrepriseController.clear();
                        _identificationController.clear();
                        _adresseController.clear();
                        _paysController.clear();
                        _secteurController.clear();
                        _dpoNomController.clear();
                        _dpoEmailController.clear();
                        _dpoTelController.clear();
                        _isNomPrenomChecked = false;
                        _isAdresseChecked = false;
                        _isEmailChecked = false;
                        _isPhoneChecked = false;
                        _isDataCollecteChecked = false;
                        _isSourcePartenaire = false;
                        _isSourceAchetee = false;
                        _isSourceAutre = false;
                      });

                      // Vous pouvez aussi ajouter une logique pour soumettre les données à un backend ici
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Soumettre',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.teal.shade50,  // background color for the page
    );
  }

  Widget _buildTextFormField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade900, // couleur du label
          ),
          border: InputBorder.none, // Supprimer toutes les bordures
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.teal, // Couleur de la bordure du bas
              width: 1.5, // Épaisseur de la bordure
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.teal, // Couleur de la bordure du bas quand le champ est sélectionné
              width: 2, // Épaisseur de la bordure
            ),
          ),
          filled: true,
          fillColor: Colors.white, // Couleur de fond
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez remplir ce champ';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCheckBoxFormField(String labelText, ValueChanged<bool?> onChanged, bool value) {
    return CheckboxListTile(
      title: Text(labelText),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.teal,  // Change the color of the checked box
      checkColor: Colors.white,  // Change the color of the check mark
      contentPadding: EdgeInsets.zero,
      tileColor: Colors.teal.shade50,  // Set background color for each checkbox tile
    );
  }
}
