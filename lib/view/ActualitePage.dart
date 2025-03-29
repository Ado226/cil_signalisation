import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'CreateEvent.dart';

class ActualitePage extends StatefulWidget {
  @override
  _ActualitePageState createState() => _ActualitePageState();
}

class _ActualitePageState extends State<ActualitePage> {
  late final SupabaseClient _client;
  late final Stream<List<Map<String, dynamic>>> _actualitesStream;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;

    // Création d'un flux pour récupérer les actualités depuis Supabase
    _actualitesStream = _client
        .from('actualites')
        .stream(primaryKey: ['id'])
        .order('date_publication', ascending: false)
        .execute();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fonction pour formater la date de publication
  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar:AppBar(
  automaticallyImplyLeading: true, // Supprimer la flèche de retour si tu en as besoin
  title: Text(
    'Actualités',
    style: TextStyle(color: Colors.teal[900]),
  ),
  centerTitle: true,
  flexibleSpace: Container(
    color:Color.fromARGB(255, 234, 246, 245)
  /*/  decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFa5d6a7),  // Vert clair (menthe)
          Color(0xFF81c784),  // Vert pastel (douceur)
          Color(0xFF66bb6a),  // Vert tendre
        ],
      ),
    ),*/
  ),
  elevation: 4.0, // Pour ajouter une légère ombre
),


      body:CustomScrollView(
  slivers: [
   SliverAppBar(
  automaticallyImplyLeading: false, // Supprime la flèche de retour
  expandedHeight: 150.0, // Hauteur maximale (quand déplié)
  collapsedHeight: 80.0, // Hauteur minimale (quand rétracté)
  floating: false,
  pinned: true,
  flexibleSpace: LayoutBuilder(
    builder: (context, constraints) {
      // Calculer les valeurs d'animation basées sur le défilement
      double scrollFactor = (constraints.maxHeight - 80.0) / (150.0 - 80.0);
      scrollFactor = scrollFactor.clamp(0.0, 1.0); // Valeur entre 0 et 1
      
      return Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
        decoration: BoxDecoration(
          color:Color.fromARGB(255, 234, 246, 245),
        /*  gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFa5d6a7), // Vert clair (menthe)
              Color(0xFF81c784), // Vert pastel (douceur)
              Color(0xFF66bb6a), // Vert tendre
            ],
          ),*/
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min, // Pour éviter le débordement
          children: [
            // Premier texte - disparaît progressivement
            if (scrollFactor > 0.3)
              Opacity(
                opacity: scrollFactor,
                child: Text(
                  'Restez informé',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[700],
                    //color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            
            // Espacement entre le premier et le deuxième texte
            if (scrollFactor > 0.3)
              SizedBox(height: 8), // Ajout d'un espacement de 8 pixels
            
            // Deuxième texte - disparaît progressivement
            if (scrollFactor > 0.3)
              Opacity(
                opacity: scrollFactor,
                child: Text(
                  'Découvrez nos événements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                    //color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
                
            // Espace entre le deuxième texte et le champ de recherche
            SizedBox(height: scrollFactor > 0.3 ? 12 : 0), // Augmenté à 12 pixels
              
            // Champ de recherche - toujours visible
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un événement...',
                    hintStyle: TextStyle(color: Colors.teal[700]),
                    prefixIcon: Icon(Icons.search, color: Colors.teal),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  ),
),
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Événements à venir',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
            TextButton(
              onPressed: () {
                // Action pour voir tous les événements
              },
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: Colors.teal[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    
    StreamBuilder<List<Map<String, dynamic>>>(
      stream: _actualitesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Text(
                    'Une erreur est survenue',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.teal[700]),
                  SizedBox(height: 16),
                  Text(
                    'Aucun événement disponible',
                    style: TextStyle(fontSize: 16, color: Colors.teal[700]),
                  ),
                ],
              ),
            ),
          );
        } else {
          final actualites = snapshot.data!;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final actualite = actualites[index];
                DateTime datePublication = DateTime.parse(actualite['date_publication']);
                String formattedDate = _formatDate(datePublication);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActualiteDetailPage(actualite: actualite),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (actualite['image_url'] != null)
                              Stack(
                                children: [
                                  Image.network(
                                    actualite['image_url'],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 180,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: Colors.teal[700],
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            formattedDate.split(',')[0],
                                            style: TextStyle(
                                              color: Colors.teal[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    actualite['titre'] ?? 'Titre inconnu',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.teal[700],
                                      height: 1.3,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  if (actualite['description'] != null) ...[
                                    Text(
                                      actualite['description'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.teal[700],
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 16,
                                            color: Colors.teal[700],
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            formattedDate.split(',')[1].trim(),
                                            style: TextStyle(
                                              color: Colors.teal[700],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Voir plus',
                                              style: TextStyle(
                                                color: Colors.teal[700],
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 12,
                                              color: Colors.teal[700],
                                            ),
                                          ],
                                        ),
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
                  ),
                );
              },
              childCount: actualites.length,
            ),
          );
        }
      },
    ),
  ],
),

      floatingActionButton: Container(
        margin: EdgeInsets.all(16),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateEventPage()),
            );
          },
          backgroundColor: Colors.teal[500 ],
          
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            'Créer un événement',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          elevation: 4,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// Je garde la classe ActualiteDetailPage inchangée pour me concentrer sur l'amélioration de la page principale
class ActualiteDetailPage extends StatelessWidget {
  final Map<String, dynamic> actualite;
  
  ActualiteDetailPage({required this.actualite});
  
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar avec image en arrière-plan
          SliverAppBar(
            expandedHeight: h * 0.4,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.teal,
            flexibleSpace: FlexibleSpaceBar(
              background: actualite['image_url'] != null
                ? Hero(
                    tag: 'actualite-${actualite['id'] ?? 'image'}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image avec gestion d'erreur
                        Image.network(
                          actualite['image_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.teal.shade50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 80,
                                    color: Colors.teal.shade300,
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Image non disponible",
                                      style: TextStyle(
                                        color: Colors.teal.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.teal.shade50,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.teal,
                                ),
                              ),
                            );
                          },
                        ),
                        // Gradient pour améliorer la lisibilité du titre
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    color: Colors.teal.shade50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_rounded,
                          size: 80,
                          color: Colors.teal.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Aucune image fournie",
                          style: TextStyle(
                            color: Colors.teal.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              title: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  actualite['titre'] ?? 'Détails de l\'actualité',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              titlePadding: EdgeInsets.only(left: 16, bottom: 16),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, color: Colors.teal[800]),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          // Contenu principal
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date et catégorie
                  if (actualite['date'] != null || actualite['categorie'] != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          if (actualite['date'] != null)
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Text(
                                  actualite['date'],
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          if (actualite['date'] != null && actualite['categorie'] != null)
                            SizedBox(width: 16),
                          if (actualite['categorie'] != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.teal[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                actualite['categorie'],
                                style: TextStyle(
                                  color: Colors.teal[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  // Résumé avec style distinctif
                  if (actualite['resume'] != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 24),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.format_quote, color: Colors.teal),
                                SizedBox(width: 4),
                                Text(
                                  'Résumé',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[800],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            actualite['resume'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal[900],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  
                  // Contenu principal avec animation FadeIn
                  if (actualite['contenu'] != null)
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: Duration(milliseconds: 800),
                      child: Text(
                        actualite['contenu'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  
                  // Footer ou séparateur
                  SizedBox(height: 40),
                  if (actualite['source'] != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Text(
                            'Source : ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            actualite['source'],
                            style: TextStyle(
                              color: Colors.teal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bouton flottant pour partager l'actualité
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        elevation: 4,
        child: Icon(Icons.share, color: Colors.white),
        onPressed: () {
          // Implémenter la fonctionnalité de partage
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Fonctionnalité de partage à implémenter'),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.teal.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}