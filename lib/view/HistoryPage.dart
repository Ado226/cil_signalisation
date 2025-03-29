import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../model/message_model.dart';
import '../view_model/message_viewmodel.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Map<String, String> _typeImages = {
    'Déchets non collectés': 'assets/icone/jeter-des-dechets.png',
    'Pannes d\'éclairage public': 'assets/icone/eclairage-public.png',
    'Infrastructure dégradée': 'assets/icone/batiment.png',
    'Problèmes d\'eau ': 'assets/icone/ONEA.png',
    'Problèmes  d\'électricité': 'assets/icone/SONABEL.jpg',
    'Incidents de sécurité': 'assets/icone/accident-de-voiture.png',
    'Bruits excessifs': 'assets/icone/distraits.png',
    'Animaux errants': 'assets/icone/chevre.png',
    'Espaces verts mal entretenus': 'assets/icone/vert.png',
    'Type3': 'assets/images/type3.png',
  };

  @override
  void initState() {
    super.initState();
    // Initialiser la base de données en appelant la méthode `initialize()` du `MessageViewModel`
    Provider.of<MessageViewModel>(context, listen: false).initialize();
  }

  @override
  Widget build(BuildContext context) {
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
          'Historique',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.teal[900],
          ),
        ),
      ),
      body: FutureBuilder<List<MessageModel>>(
        future: Provider.of<MessageViewModel>(context).getFilteredMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune information disponible'));
          } else {
            final messages = snapshot.data!;

            // Séparer les messages en trois groupes : En attente, En cours, Traités
            final pendingMessages =
                messages.where((msg) => msg.status == 'non').toList();
            final ongoingMessages =
                messages.where((msg) => msg.status == 'en cours').toList();
            final processedMessages =
                messages.where((msg) => msg.status == 'traité').toList();

            return ListView(
              children: [
                ...pendingMessages.map((message) => _buildMessageTile(message)),
                ...ongoingMessages.map((message) => _buildMessageTile(message)),
                ...processedMessages
                    .map((message) => _buildMessageTile(message)),
              ],
            );
          }
        },
      ),
    );
  }

  // Fonction pour construire chaque message dans la liste
  Widget _buildMessageTile(MessageModel message) {
    String statusText;
    Color statusColor;

    switch (message.status) {
      case 'non':
        statusText = 'En attente';
        statusColor = Colors.orange;
        break;
      case 'en cours':
        statusText = 'En cours';
        statusColor = Colors.red;
        break;
      case 'traité':
        statusText = 'Traité';
        statusColor = Colors.green;
        break;
      default:
        statusText = 'Statut inconnu';
        statusColor = Colors.grey;
        break;
    }

    return GestureDetector(
      onTap: () {
        _showMessageDetails(context, message);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ListTile(
          leading: Image.asset(
            _typeImages[message.type] ?? 'assets/icone/jeter-des-dechets.png',
            width: 40,
            height: 40,
          ),
          title: Text(
            message.type ?? 'Type inconnu',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                statusText,
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageDetails(BuildContext context, MessageModel message) async {
    String statusText;
    Color statusColor;

    switch (message.status) {
      case 'non':
        statusText = 'En attente';
        statusColor = Colors.orange;
        break;
      case 'en cours':
        statusText = 'En cours';
        statusColor = Colors.red;
        break;
      case 'traité':
        statusText = 'Traité';
        statusColor = Colors.green;
        break;
      default:
        statusText = 'Statut inconnu';
        statusColor = Colors.grey;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              message.type ?? 'Type inconnu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Texte: ${message.text?.isNotEmpty == true ? message.text : 'Aucune description disponible'}',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 10),
                Text(
                  'Statut: $statusText',
                  style: TextStyle(
                      fontSize: 16,
                      color: statusColor,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (message.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CachedNetworkImage(
                      imageUrl: message.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                if (message.audioUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: const [
                        Icon(Icons.audiotrack, size: 24),
                        SizedBox(width: 8),
                        Text('Audio disponible',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.teal[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
