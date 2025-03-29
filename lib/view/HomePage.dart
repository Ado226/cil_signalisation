import 'package:cil_signalisation/view/question.dart';
import 'package:cil_signalisation/view/type_page.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'ActualitePage.dart';
import 'article.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _selectedItems = [];

  // Obtenir la date actuelle
  String _getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(now);
  }

  final _infos = [
    {
      'code': 'L\'actualité du Burkina 24h/24h',
      'titre': '', // Titre à remplir avec la date actuelle
      'description': 'Description 1',
      'image': 'assets/images/cil1.jpg',
    },
    {
      'code': 'Météo du jour',
      'titre': '', // Titre à remplir avec la date actuelle
      'description': 'Description 2',
      'image': 'assets/images/metheo1.jpg',
    },
    {
      'code': 'Divers du Pays',
      'titre': '', // Titre à remplir avec la date actuelle
      'description': 'Description 3',
      'image': 'assets/images/rtb.png',
    },
  ];

  int _currentInfo = 0;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentInfo = _pageController.page!.round();
      });
    });
    // Remplir les titres avec la date actuelle
    String currentDate = _getCurrentDate();
    for (var info in _infos) {
      info['titre'] = currentDate;
    }
    _loadSelectedItems(); // Load previously selected items when the widget initializes
  }

  @override
  void dispose() {
    _saveSelectedItems(); // Save selected items when the widget is disposed
    super.dispose();
  }

  void _loadSelectedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? items = prefs.getStringList('selected_items');
    if (items != null) {
      setState(() {
        _selectedItems = items.map((item) => _parseSelectedItem(item)).toList();
      });
    }
  }

  void _saveSelectedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> items =
        _selectedItems.map((item) => _stringifySelectedItem(item)).toList();
    await prefs.setStringList('selected_items', items);
  }

  // Methods for parsing and stringifying selected items
  Map<String, dynamic> _parseSelectedItem(String itemString) {
    // Implement parsing logic based on your item structure
    return {}; // Placeholder for your parsing logic
  }

  String _stringifySelectedItem(Map<String, dynamic> item) {
    // Implement stringification logic based on your item structure
    return ''; // Placeholder for your stringification logic
  }

  // Method to update selected items after navigating back from IncidentPage
  void _updateSelectedItems(Map<String, dynamic> newItem) {
    setState(() {
      _selectedItems.add(newItem);
    });
    _saveSelectedItems(); // Save updated selected items
  }

  void _launchURL() async {
    const url = 'https://www.rtb.bf/television/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _navigateToDetailPage(int index) {
    switch (index) {
      case 0:
        _launchURL(); // Ouvre le site web

        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
        break;
      default:
        print('Navigating to custom page for index: $index');
    }
  }

  int conteurindex = 0;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
     double h = MediaQuery.of(context).size.height;
      Size size = MediaQuery.of(context).size;

    return Scaffold(
      //backgroundColor: Colors.teal[50],
      backgroundColor: Color.fromARGB(255, 234, 246, 245),
      appBar: AppBar(
       // backgroundColor: Colors.teal[50],
         backgroundColor: const Color.fromARGB(255, 234, 246, 245),
        title: Text(
          'CIL Signalisation App',
          style: TextStyle(
            color: Colors.teal[900],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        ///#########################################
        automaticallyImplyLeading: false,
      //  leading: Container(), // Suppression de l'icône de retour
        actions: [
          IconButton(
            icon:  Icon(Icons.notifications_none,size: w*0.075,),
            ///#### J'ai defini la taille de l'icone
            ///Par rapport a l'ecran de l'ordinateur ce qui le rend sa taille constante peu importe l'ecran
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
            iconSize: 40,
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined,size: w*0.075,),
            onPressed: () {},
            iconSize: 40,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                width: double.infinity,
                height: h * 0.23,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  image: DecorationImage(
                    image: AssetImage(_infos[_currentInfo]['image']!),
                    fit: BoxFit.cover,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black45.withOpacity(0.5),
                      Colors.black54.withOpacity(0.5),
                      Colors.black87.withOpacity(0.5),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
               //   border: Border.all(width: 0.5, color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                   border: Border.all(color: const Color.fromARGB(255, 207, 205, 205), width: w*0.010), // Bordure rouge de 2px
                     boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3), // Couleur de l'ombre
        spreadRadius: 2, // Étendue de l'ombre
        blurRadius: 5, // Flou de l'ombre
        offset: Offset(3, 3), // Position de l'ombre (X, Y)
      ),
    ],
                ),
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      children: _infos
                          .asMap()
                          .entries
                          .map((entry) => _buildInfo(entry.value, entry.key))
                          .toList(),
                    ),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: EdgeInsets.only(bottom: 17),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _infos
                            .map((info) => _buildPagination(_infos.indexOf(info)))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
          /*  Container(
  width: w,
  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: const Color.fromRGBO(0, 0, 0, 0),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ActualitePage(),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Image.asset(
                        'assets/icone/news.png',
                        height: 24,
                        width: 24,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.0),
                    // j'Utilise Flexible pour permettre au texte de s'adapter et ne pas deborder
                   Flexible( 
                      child: Text(
                        'Événements',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15, // Réduit la taille de la police
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                        overflow: TextOverflow.ellipsis, // Ajoute des points de suspension si nécessaire
                        maxLines: 1, // Limite à une seule ligne
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 16.0),
      Expanded(
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
///##### j'ai remplace les inkwells a la place des boutons
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AgendoPage(),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Image.asset(
                        'assets/icone/agenda1.png',
                        height: 24,
                        width: 24,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.0),
                        Flexible( 
                      child: Text(
                        'Agenda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Réduit la taille de la police
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis, // Ajoute des points de suspension si nécessaire
                        maxLines: 1, // Limite à une seule ligne
                      ),
                    ),
                  
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),*/
              Container(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  child: Container(
    height: 70,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.deepOrange.shade400,
          Colors.deepOrange.shade600,
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
              builder: (context) => TypePage(),
            ),
          ).then((value) {
            if (value != null) {
              _updateSelectedItems(value);
            }
          });
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
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Signaler une violation',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Informez-nous de tout problème',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: w*0.05),
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
  ),
),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Padding(
                        padding: const EdgeInsets.only(left:20.0),
                        child: Text(
                                          'Autres options disponibles',
                                          style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                                          ),
                                        ),
                      ),
                    ]
                  )
                ),
              ),
          Container(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  child: Stack(
    children: [
      GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildCustomButton(
            context,
            icon: 'assets/icone/townHall.png',
            text: 'Poser une question a la CIL',
             size: size,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => questionPage())),
          ),
          _buildCustomButton(
            context,
            icon: 'assets/icone/newspaper.png',
            text: 'CIL articles',
            size: size,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  ActualitePage())),
          ),
          _buildCustomButton(
            context,
            icon: 'assets/icone/booking.png',
            text: "Quels sont mes droits ?",
            size: size,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const article())),
          ),

        ],
      ),
    ],
  ),
),



            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 7,
              spreadRadius: 2,
              offset: const Offset(2, 4),
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey.shade600,
            currentIndex: conteurindex,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                ),
                label: "Acceuil",
              ),
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.bookmarks_outlined,
                ),
                label: "Déclaration",
              ),
            
              const BottomNavigationBarItem(
                icon: Icon(Icons.history_edu_outlined),
                label: "Historique",
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.pushNamed(context, '/home');
              }  else if (index == 1) {
                Navigator.pushNamed(context, '/Declaration');
              } else {
                Navigator.pushNamed(context, '/history');
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(int index) {
    return Container(
      width: index == _currentInfo ? 30 : 10,
      height: 10,
      margin: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: index == _currentInfo ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildInfo(Map<String, String> info, int index) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(bottom: 17),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2), // Couleur sombre
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              _infos.length,
              (index) => _buildPagination(index),
            ),
          ),
        ),
        // Ajoutez un filtre de couleur sombre sur l'image
        /*Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4), // Couleur sombre
            borderRadius: BorderRadius.circular(19),
          ),
        ),*/
        Positioned(
          top: 60,
          left: 29,
          child: Text(
            info['code']!.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          top: 129,
          left: 29,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: info['titre']!.split('\n').map((word) {
                return Text(
                  word.trim(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(
                growable: false,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _navigateToDetailPage(index);
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
  /// Fonction pour créer des boutons stylisés
Widget _buildCustomButton(BuildContext context, {
  required String icon,
  required String text,
  required Size size,
  required VoidCallback onTap
}) {
  return Padding(
    padding: EdgeInsets.all(5),
    child: Container(
      width: size.width * 0.6,
      height: size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Zone d'icône - réduite à 60% de la hauteur
                SizedBox(
                  height: constraints.maxHeight * 0.6,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset(
                        icon,
                        fit: BoxFit.contain,
                        height: constraints.maxHeight * 0.4,
                      ),
                    ),
                  ),
                ),
                
                // Zone de texte - augmentée à 40% de l'espace
                SizedBox(
                  height: constraints.maxHeight * 0.25,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    ),
  );
}
}