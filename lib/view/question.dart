import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import 'HomePage.dart';

class questionPage extends StatefulWidget {
  const questionPage({super.key});

  @override
  State<questionPage> createState() => _questionPageState();
}

class _questionPageState extends State<questionPage> {
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
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
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
        title: const Text(
          'Poser une question',
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
              const SizedBox(height: 14),




              Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 20),

              _buildDescriptionSection(),
              const SizedBox(height: 30),
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



                      setState(() {
                        _isLoading = false;
                      });

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => HomePage()),
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
                          'Envoyer une question',
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

  Widget _buildDescriptionSection() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    if (!_audioRecorded) {
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
        height: h*0.25,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Durée de l\'audio: ${getFormattedDuration(_recordingDuration)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.teal.shade700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _playAudio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Écouter l\'audio'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future<void> _playAudio() async {
    if (_audioFile != null && !_isPlaying) {
      setState(() {
        _isPlaying = true;
      });

      await _flutterSoundPlayer!.startPlayer(
        fromURI: _audioFile!.path,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
    }
  }
}
