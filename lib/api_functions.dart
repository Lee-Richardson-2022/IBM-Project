import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:vector_math/vector_math_64.dart' as vector;

class TextToSpeechWidget extends StatefulWidget {
  final String message;
  final Function(bool) onProcessingStateChanged;

  const TextToSpeechWidget({
    Key? key,
    required this.message,
    required this.onProcessingStateChanged,
  }) : super(key: key);

  @override
  _TextToSpeechWidgetState createState() => _TextToSpeechWidgetState();
}

class _TextToSpeechWidgetState extends State<TextToSpeechWidget> {
  final String apiKey = 'YMVJWGmKng-VU9EmjKMw0aEncMrZdc-CHZyCaHmR04qP';
  final String ibmURL =
      'https://api.au-syd.text-to-speech.watson.cloud.ibm.com/instances/94dbd1e6-3df9-4900-b1ce-c88e76596c4c/v1/synthesize';
  bool _isProcessing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }

  Future<void> convertTextToSpeech(String message) async {
    widget.onProcessingStateChanged(true); // Indicate processing has begun

    // Prepare HTTP request headers for IBM API authentication
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ' + base64Encode(utf8.encode('apikey:$apiKey')),
    };

    // Create HTTP request object
    var request = http.Request('POST', Uri.parse(ibmURL));
    request.body = json.encode({"text": message, "accept": "audio/wav"});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Process successful response
        var bytes = await response.stream.toBytes();
        var dir = await getTemporaryDirectory();
        var file = File("${dir.path}/speech.wav");

        await file.writeAsBytes(bytes); // Store the audio file
        await _audioPlayer.play(DeviceFileSource(file.path)); // Play audio
      } else {
        // Handle failed request
        print('Request failed with status code: ${response.statusCode}');
        print(response.reasonPhrase);
      }
    } catch (e) {
      // Handle errors
      print('Error occurred: $e');
      print('Request details: $request');
    }

    widget.onProcessingStateChanged(false); // Processing completed
  }
}
