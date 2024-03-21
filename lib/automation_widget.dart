import 'package:flutter/material.dart';
import 'text_to_speech.dart';
import 'chatbot.dart';
import 'firebase.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class BuildAutomationWidget extends StatefulWidget {
  const BuildAutomationWidget({super.key});

   @override
  State<BuildAutomationWidget> createState() => _AutomationWidgetState();
}

class _AutomationWidgetState extends State<BuildAutomationWidget> {
  late String prompt;
  late bool doneIntro = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: () async {
          // String? chatGptPersona = await returnFirebaseInfo("Description");
          String chatGptPersona = "You are a elon musk";
          if (!doneIntro){
            String? chatbotResponse = await CallChatGPT(chatGptPersona!, "Introduce yourself");
            await ConvertTextToSpeech(chatbotResponse);
            setState(() {
              doneIntro = true;
            });
          } else {
            await listenForInput();
            String? chatbotResponse = await CallChatGPT(chatGptPersona!, prompt);
            await ConvertTextToSpeech(chatbotResponse);
            setState(() {
              prompt = "";
            });
          }
        },
        child: Icon(doneIntro?Icons.mic:Icons.play_arrow),
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
          });;
        },
      );
    } else {
      // Handle the case when the plugin is not available
      print('Speech recognition not available');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
  }
}
