import 'package:flutter/material.dart';

import 'incident_page.dart';

class TypePage extends StatefulWidget {
  const TypePage({super.key});

  @override
  State<TypePage> createState() => _TypePageState();
}

final List<Item> items = [
  Item('assets/icone/jeter-des-dechets.png', 'Utilisation abusive des données personnelles'),
  Item('assets/icone/eclairage-public.png', 'Absence de consentement'),
  Item('assets/icone/batiment.png', 'Non-respect des droits des citoyense'),
  Item('assets/icone/ONEA.png', 'Caméras de surveillance illégales'),
  Item('assets/icone/SONABEL.jpg', 'Fuite ou piratage de données'),
  Item('assets/icone/accident-de-voiture.png', 'Entreprise non déclarée à la CIL'),
  Item('assets/icone/distraits.png', 'Exportation illégale de données hors du pays'),

];

class Item {
  final String imagePath;
  final String text;

  Item(this.imagePath, this.text);
}


class _TypePageState extends State<TypePage> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;


    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade50,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: Colors.teal.shade900),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Signaler une violation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.teal,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bannière améliorée
              Container(
                width: double.infinity,
                height: h * 0.14,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Je signale une violation',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Aidez à protéger vaux données',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/haut.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Barre de progression améliorée
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Étape 1/2',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Choisissez le type de violation',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(Colors.teal.shade500),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 30),

              // Titre de la section
              Text(
                'Type de violation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sélectionnez la catégorie qui correspond le mieux à votre signalement',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),



              // Grille d'options améliorée

          ListView.builder(
            itemCount: items.length, // Nombre d'éléments
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Désactive le défilement interne si nécessaire
            itemBuilder: (context, index) {
              return buildListItem(
                  context,
                  items[index].imagePath,
                  items[index].text
              );
            },
          ),

          ],
          ),
        ),
      ),
    );
  }



  Widget buildListItem(BuildContext context, String imagePath, String text) {
    return Container(
      height: 70,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0), // Espacement
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal,
            Colors.teal.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IncidentPage(type: text),
              ),
            );
          },
          child: Stack(
            children: [
              // Effet de brillance
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Contenu principal
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.asset(
                        imagePath,
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),

                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}