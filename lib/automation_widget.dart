import 'package:flutter/material.dart';
import 'text_to_speech.dart';
import 'chatbot.dart';

class BuildAutomationWidget extends StatefulWidget {
  BuildAutomationWidget({super.key});

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
          ///Function
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
