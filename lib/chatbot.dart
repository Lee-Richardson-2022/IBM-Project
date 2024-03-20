import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> CallChatGPT(String prompt) async {
  const apiKey = "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";
  const apiUrl = "https://api.openai.com/v1/chat/completions";

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey'
  };

  final body = jsonEncode(
    {
      "model": "gpt-3.5-turbo",
      "messages": [
      {
        "role": "system",
        "content": "You are a developer that works for the company IBM. You are presenting a pitch to potential clients, to start off please introduce yourself and what your role is at IBM. You will be then be asked questions about IBM and it will be your job to answer them."
      },
      {
        "role": "user",
        "content": "Hello! I am wanting to know about who you work for and how long you have been working with them"
      }
      ],
      'max_tokens': 100, // Adjust as needed
    },
  );
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final result = jsonResponse['choices'][0]['message']['content'];
      return result;
    } else {
      print(
        'Failed to call ChatGPT API: ${response.statusCode} ${response.body}',
      );
      return null;
    }
  } catch (e) {
    print("Error calling ChatGPT API: $e");
    return null;
  }
}