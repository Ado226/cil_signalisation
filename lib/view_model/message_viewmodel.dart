import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../model/message_model.dart';
import '../service/supabase_service.dart';

class MessageViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  late Database _database;
  bool _isDatabaseInitialized =
      false; // Indicateur pour vérifier si la DB est initialisée

  // Initialisation de la base de données SQLite
  Future<void> _initializeDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, 'messages.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS messages(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              phone_number TEXT
            )
          ''');
        },
      );
      _isDatabaseInitialized = true; // L'initialisation est terminée
      print('Database initialized at $path');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow; // Relancer l'exception pour la gérer ailleurs si nécessaire
    }
  }

  // Méthode pour initialiser la base de données
  Future<void> initialize() async {
    if (!_isDatabaseInitialized) {
      await _initializeDatabase();
    }
  }

  // Méthode pour récupérer les numéros de téléphone depuis SQLite
  Future<List<String>> _getPhoneNumbersFromSQLite() async {
    if (!_isDatabaseInitialized) {
      throw Exception('Database not initialized');
    }

    try {
      final db = _database;
      final List<Map<String, dynamic>> result = await db.query('messages');
      print('Phone numbers fetched from SQLite: $result');
      return result.map((row) => row['phone_number'] as String).toList();
    } catch (e) {
      print('Error fetching phone numbers from SQLite: $e');
      rethrow;
    }
  }

  // Récupération des messages filtrés en fonction des numéros de téléphone
  Future<List<MessageModel>> getFilteredMessages() async {
    await initialize(); // S'assurer que la base de données est initialisée

    try {
      final phoneNumbers = await _getPhoneNumbersFromSQLite();
      print('Phone numbers for filtering: $phoneNumbers');

      final supabaseMessages = await _supabaseService.fetchMessages();
      print('Messages fetched from Supabase: $supabaseMessages');

      final filteredMessages = supabaseMessages
          .where((message) => phoneNumbers.contains(message.phoneNumber))
          .toList();

      print('Filtered messages: $filteredMessages');
      return filteredMessages;
    } catch (e) {
      print('Error fetching or filtering messages: $e');
      rethrow;
    }
  }

  // Sauvegarder un message
  Future<void> saveMessage(
    String phoneNumber,
    String? text,
    String type,
    String? status,
    File? imageFile,
    File? audioFile,
    double latitude,
    double longitude,
  ) async {
    try {
      // Upload des fichiers et obtenir les URLs
      final imageUrl = imageFile != null
          ? await _supabaseService.uploadFile(
              'images/${DateTime.now().millisecondsSinceEpoch}.jpg', imageFile)
          : null;
      final audioUrl = audioFile != null
          ? await _supabaseService.uploadFile(
              'audios/${DateTime.now().millisecondsSinceEpoch}.aac', audioFile)
          : null;

      final message = MessageModel(
        phoneNumber: phoneNumber,
        text: text,
        type: type,
        status: status,
        audioUrl: audioUrl,
        imageUrl: imageUrl,
        latitude: latitude,
        longitude: longitude,
      );

      await _supabaseService.insertMessage(message);
      notifyListeners();
    } catch (e) {
      print('Error saving message: $e');
      rethrow;
    }
  }

  // Méthode pour récupérer tous les messages
  Future<List<MessageModel>> getMessages() async {
    await initialize();
    try {
      return await _supabaseService.fetchMessages();
    } catch (e) {
      print('Error fetching all messages: $e');
      rethrow;
    }
  }

  // Flux de messages
  Stream<List<MessageModel>> messageStream() {
    return _supabaseService.messageStream();
  }
}
