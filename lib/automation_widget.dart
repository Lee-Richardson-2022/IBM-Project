import 'package:flutter/material.dart';
import 'text_to_speech.dart';
import 'chatbot.dart';

class BuildAutomationWidget extends StatefulWidget {
  const BuildAutomationWidget({super.key});

   @override
  State<BuildAutomationWidget> createState() => _AutomationWidgetState();
}

class _AutomationWidgetState extends State<BuildAutomationWidget> {
  @override
  Widget build(BuildContext context) {

    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: () async {
          String? chatbotResponse = await CallChatGPT("Introduce yourself");
          ConvertTextToSpeech(chatbotResponse);
          // then listen for speech
          // then pass text to chatbot
          //then pass reply to speech and continue
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
