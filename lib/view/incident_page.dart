import 'dart:async';
import 'dart:io';
import 'package:cil_signalisation/view/HomePage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


import 'package:path/path.dart';

import 'HistoryPage.dart';

class IncidentPage extends StatefulWidget {
  final String type;
  const IncidentPage({super.key, required this.type});

  @override
  State<IncidentPage> createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage> {
  late Database database;
  final _phoneNumberController = TextEditingController();
  final _textController = TextEditingController();
  FlutterSoundPlayer? _flutterSoundPlayer;
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  File? _imageFile;
  File? _audioFile;
  Position? _currentPosition;
  Duration _recordingDuration = Duration.zero;
  bool _audioRecorded = false;
  bool _isPlaying = false;
  Timer? _playbackTimer;
  bool _isLoading = false;
  bool _isPhoneNumberValid = true;
  bool _isDescriptionValid = true;
  bool _isAudioValid = true;

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _flutterSoundPlayer = FlutterSoundPlayer();
    _initializeAudioRecorder();
    _initializeDatabase();
  }

  Future<void> _initializeAudioRecorder() async {
    await _audioRecorder!.openRecorder();
    await _flutterSoundPlayer!.openPlayer();
    if (await Permission.microphone.request().isGranted) {
      await _audioRecorder!
          .setSubscriptionDuration(const Duration(milliseconds: 10));
    } else {
      print('Microphone permission denied');
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _textController.dispose();
    _audioRecorder!.closeRecorder();
    _flutterSoundPlayer!.closePlayer();
    _playbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.isGranted) {
      Directory tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/audio.aac';
      await _audioRecorder!.startRecorder(toFile: path, codec: Codec.aacADTS);
      setState(() {
        _isRecording = true;
        _audioFile = File(path);
        _audioRecorded = false;
        _recordingDuration = Duration.zero;
      });

      Timer.periodic(Duration(seconds: 1), (timer) {
        if (_isRecording) {
          setState(() {
            _recordingDuration += Duration(seconds: 1);
          });
        } else {
          timer.cancel();
        }
      });
    } else {
      print('Microphone permission denied');
    }
  }

  Future<void> _stopRecording() async {
    await _audioRecorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _audioRecorded = true;
    });
  }

  void _deleteAudio() {
    setState(() {
      _audioFile = null;
      _audioRecorded = false;
      _recordingDuration = Duration.zero;
    });
  }

  String getFormattedDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitsMinutes:$twoDigitsSeconds";
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    if (await Permission.location.isGranted) {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Les services de localisation sont désactivés.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Les permissions de localisation sont refusées.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Les permissions de localisation sont refusées de façon permanente.');
      }

      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      print('Location permission denied');
    }
  }

  Future<void> _saveMessage(BuildContext context) async {
    final phoneNumber = _phoneNumberController.text;
    final text = _textController.text;
    final type = widget.type;
    const status = 'non';

    print('Phone Number: $phoneNumber');
    print('Text: $text');
    print('Image File: ${_imageFile?.path}');
    print('Audio File: ${_audioFile?.path}');
    print('Location: $_currentPosition');
    print('status: $status');



    try {
      if (_imageFile == null) {
        throw 'Image file cannot be null';
      }


      print('Message saved successfully in Supabase');

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  Future<void> _initializeDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'messages.db');

    database = await openDatabase(
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
    print('Database initialized at $path');
  }

  Future<void> _savePhoneNumberInSQLite(String phoneNumber) async {
    try {
      final existingNumbers = await _getPhoneNumbersFromSQLite();
      if (!existingNumbers.contains(phoneNumber)) {
        await database.insert(
          'messages',
          {
            'phone_number': phoneNumber,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Phone number saved in SQLite');
      } else {
        print('Phone number already exists in SQLite');
      }
    } catch (e) {
      print('Error saving phone number in SQLite: $e');
    }
  }

  Future<List<String>> _getPhoneNumbersFromSQLite() async {
    try {
      final List<Map<String, dynamic>> result =
          await database.query('messages');
      return result.map((row) => row['phone_number'] as String).toList();
    } catch (e) {
      print('Error fetching phone numbers from SQLite: $e');
      return [];
    }
  }

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
        title: Text(
          'Détails de la violation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bannière avec type d'incident sélectionné
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type de violation:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.type,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/haut.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // Indicateur de progression
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Étape 2/2',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Détails de la violation',
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
                  value: 1.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(Colors.teal.shade500),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 30),

              // Formulaire
              _buildFormSection(
                title: "Numéro de téléphone",
                hint: "Entrez votre numéro de téléphone",
                isValid: _isPhoneNumberValid,
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                icon: Icons.phone_rounded,
              ),
              
              const SizedBox(height: 24),
              
              // Section Description
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade900,
                ),
              ),
              const SizedBox(height: 8),
              _buildDescriptionSection(),
              
              const SizedBox(height: 24),
              
              // Section Photo
              Text(
                "Photo de l'incident",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade900,
                ),
              ),
              const SizedBox(height: 8),
              _buildPhotoSection(context),
              
              const SizedBox(height: 30),

              // Bouton de validation
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isPhoneNumberValid =
                                  _phoneNumberController.text.isNotEmpty;
                              _isAudioValid =
                                  !_audioRecorded || _audioFile != null;
                              _isDescriptionValid =
                                  _textController.text.isNotEmpty ||
                                      _audioRecorded;
                            });

                            if (!_isPhoneNumberValid ||
                                !_isAudioValid ||
                                !_isDescriptionValid) {
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            await _getCurrentLocation();
                            await _saveMessage(context);
                            final phoneNumber = _phoneNumberController.text;
                            await _savePhoneNumberInSQLite(phoneNumber);

                            await Future.delayed(Duration(seconds: 2));

                            setState(() {
                              _isLoading = false;
                            });



                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => HistoryPage()),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Signaler la violation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.send_rounded,color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required String hint,
    required bool isValid,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
            border: !isValid
                ? Border.all(color: Colors.red.shade400, width: 1.5)
                : null,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(icon, color: Colors.teal.shade600),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (!isValid)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              "Ce champ est obligatoire",
              style: TextStyle(color: Colors.red.shade400, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    if (!_audioRecorded) {
      // Mode standard - entrée texte avec bouton d'enregistrement
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
          border: !_isDescriptionValid
              ? Border.all(color: Colors.red.shade400, width: 1.5)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: 4,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: _isRecording
                      ? 'Enregistrement audio en cours...'
                      : 'Décrivez l\'incident en détail...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: Text(
                  getFormattedDuration(_recordingDuration),
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : Colors.teal.shade600,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                icon: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: _isRecording ? 'Arrêter' : 'Enregistrer audio',
              ),
            ),
          ],
        ),
      );
    } else {
      // Mode audio enregistré
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Player audio
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _isPlaying ? Colors.red.shade400 : Colors.teal.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        if (_audioFile != null) {
                          try {
                            if (_isPlaying) {
                              await _flutterSoundPlayer!.stopPlayer();
                              _playbackTimer?.cancel();
                            } else {
                              await _flutterSoundPlayer!.startPlayer(
                                fromURI: _audioFile!.path,
                                codec: Codec.aacADTS,
                              );

                              _recordingDuration = Duration.zero;

                              _playbackTimer = Timer.periodic(
                                  Duration(seconds: 1), (timer) {
                                setState(() {
                                  if (_flutterSoundPlayer!.isPlaying) {
                                    _recordingDuration += Duration(seconds: 1);
                                  } else {
                                    timer.cancel();
                                    _isPlaying = false;
                                  }
                                });
                              });
                            }
                            setState(() {
                              _isPlaying = !_isPlaying;
                            });
                          } catch (e) {
                            print("Erreur lors de la lecture : $e");
                          }
                        }
                      },
                      icon: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      tooltip: _isPlaying ? 'Pause' : 'Lecture',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Audio enregistré",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Durée: ${getFormattedDuration(_recordingDuration)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _deleteAudio,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade400,
                      size: 22,
                    ),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Texte additionnel
            TextField(
              controller: _textController,
              maxLines: 2,
              keyboardType: TextInputType.multiline,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Texte additionnel (facultatif)',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.teal.shade400),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPhotoSection(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: _getImage,
      child: Container(
        height: deviceWidth * 0.6,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _imageFile == null ? Colors.grey.shade300 : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 42,
                      color: Colors.teal.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Prendre une photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Touchez pour utiliser la caméra',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Photo capturée',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _getImage,
                              icon: Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                              label: Text(
                                'Changer',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}