import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'package:audioplayers/audioplayers.dart'; // For playing audio
import 'dart:io'; // For file operations
import 'package:flutter/material.dart';


class TextToSpeechWidget extends StatefulWidget {
  TextToSpeechWidget({super.key});

  final String apiKey = 'i6dMF2ABNtgoeKxJKW3F88a_DBwtxMf3rOwS7Bde_SI3';
  final String ibmURL = 'https://api.eu-gb.text-to-speech.watson.cloud.ibm.com/instances/c7604c72-6d16-4e92-87b0-1fa408703bdc/v1/synthesize';
  bool _isProcessing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  State<TextToSpeechWidget> createState() => _TextToSpeechWidgetState();
}

class _TextToSpeechWidgetState extends State<TextToSpeechWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
