import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show Platform;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _transcription = '';
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _listenForCommand() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (error) => print('onError: $error'),
      );
      if (available) {
        _speech.listen(
          onResult: (result) async {
            if (result.finalResult) {
              try {
                await _speech.stop();
                String recognizedWords = result.recognizedWords;
                String transcript = await transcribeText(recognizedWords);
                setState(() {
                  _transcription = transcript;
                });
              } catch (e) {
                print('Error transcribing text: $e');
                setState(() {
                  _transcription = 'Error transcribing text: $e';
                });
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }


  Future<String> transcribeText(String text) async {
    const String apiKey = '1H4-lq4KgcckeYEU4smtN8Z2Dkbp7s6HvihgNHWEteOb';
    const String url = 'https://api.eu-gb.speech-to-text.watson.cloud.ibm.com/instances/9485a0d7-792b-42d0-89dd-6be858e72782';
    var uri = Uri.parse('$url/v1/recognize');

    var response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic ${base64Encode(utf8.encode('apikey:$apiKey'))}",
      },
      body: jsonEncode({
        "text": text,
      }),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['results'][0]['alternatives'][0]['transcript'];
    } else {
      throw Exception('Failed to transcribe text. Status code: ${response.statusCode}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watson Speech to Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Transcription: $_transcription',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            ElevatedButton(
              onPressed: _listenForCommand,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }}