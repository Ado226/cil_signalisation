import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/message_model.dart';
import 'dart:io';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadFile(String path, File file) async {
    try {
      // Effectuer le téléversement du fichier
      final uploadResponse =
          await _client.storage.from('uploads').upload(path, file);

      // Supposons que uploadResponse retourne une URL ou un String, et non un objet avec un champ `error`
      if (uploadResponse.isEmpty) {
        // Gérer l'erreur de téléversement
        print('Erreur lors du téléversement du fichier : Réponse vide ou null');
        return null;
      }

      // Récupérer l'URL publique du fichier
      final publicUrl = _client.storage.from('uploads').getPublicUrl(path);

      if (publicUrl.isEmpty) {
        // Gérer l'erreur lors de la récupération de l'URL publique
        print(
            'Erreur lors de la récupération de l\'URL publique : Réponse vide ou null');
        return null;
      }

      return publicUrl;
    } catch (e) {
      // Gérer les erreurs inattendues
      print('Erreur inattendue : $e');
      return null;
    }
  }

  Future<void> insertMessage(MessageModel message) async {
    try {
      final response =
          await _client.from('messages').insert([message.toJson()]);

      if (response.error != null) {
        print('Error saving message: ${response.error!.message}');
        throw Exception('Error saving message');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> fetchMessages() async {
    try {
      final List<dynamic> response = await _client.from('messages').select();

      return response
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching messages: $e');
      rethrow;
    }
  }

  Stream<List<MessageModel>> messageStream() {
    final stream = _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .execute();

    return stream.map((data) {
      return data
          .map<MessageModel>((json) => MessageModel.fromJson(json))
          .toList();
    });
  }
}
