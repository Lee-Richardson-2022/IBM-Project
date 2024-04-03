import 'package:flutter/material.dart';
import 'text_to_speech.dart';
import 'chatbot.dart';
import 'firebase.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class BuildAutomationWidget extends StatefulWidget {
  final String modelIdentifier;
  const BuildAutomationWidget({Key? key, required this.modelIdentifier}) : super(key: key);

  @override
  State<BuildAutomationWidget> createState() => _AutomationWidgetState();
}

class _AutomationWidgetState extends State<BuildAutomationWidget> {
  late String prompt = 'Introduce yourself'; // Initialize prompt with an empty string
  late bool listening = false;
  String? chatGptPersona;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: () async {
          if (prompt != "") {
            String? chatbotResponse = await CallChatGPT(chatGptPersona!, prompt);
            await ConvertTextToSpeech(chatbotResponse);
            setState(() {
              prompt = ''; // Clear the prompt after sending it to the chatbot
            });
          } else {
              await listenForInput();
            }
        },
        child: Icon(prompt != "" ? Icons.play_arrow : Icons.mic),
      ),
    );
  }

  Future<void> listenForInput() async {
    // Initialize the speech to text plugin
    stt.SpeechToText speech = stt.SpeechToText();

    // Check if the plugin is available
    bool available = await speech.initialize(
      onStatus: (status) {
        print('status: $status');
      },
      onError: (errorNotification) {
        print('error: $errorNotification');
      },
    );

    if (available) {
      // Start listening for speech
      await speech.listen(
        onResult: (result) {
          // Return the recognized text
          setState(() {
            prompt = result.recognizedWords;
          });
        },
      );
    } else {
      // Handle the case when the plugin is not available
      print('Speech recognition not available');
    }
  }

  @override
  void initState() {
    initChatPersona();
    super.initState();
  }

  Future<void> initChatPersona() async {
    chatGptPersona = await returnFirebaseInfo(widget.modelIdentifier);
  }
}
