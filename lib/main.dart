import 'package:cil_signalisation/view/HistoryPage.dart';
import 'package:cil_signalisation/view/declaration.dart';
import 'package:cil_signalisation/view/splashScreem.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

void main() async {
  initializeDateFormatting('fr_FR', null);
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: 'https://pepofhyzmxntxnupncxz.supabase.co',
      anonKey:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlcG9maHl6bXhudHhudXBuY3h6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEzMTI0NTMsImV4cCI6MjAzNjg4ODQ1M30.Wu_yIPmxeSR3KQD4uHBSFPQ4ylhi8YKmBBF9J01YmN0');
  // Demande de toutes les permissions nécessaires

  // Demande de toutes les permissions nécessaires
  await _requestPermissions();
  runApp(MyApp());
}

Future<void> _requestPermissions() async {
  // Demande de toutes les permissions nécessaires
  await [
    Permission.microphone,
    Permission.storage,
    Permission.location,
  ].request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) =>  SplashScreen(),
        '/Declaration': (context) =>  DeclarationPage(),
        '/history': (context) =>  HistoryPage(),
      },
    );
  }
}