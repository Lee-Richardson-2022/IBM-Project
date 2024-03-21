import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> CallChatGPT(String persona,String prompt) async {
  const apiKey = "";
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
        "content": "${persona}"
      },
      {
        "role": "user",
        "content": "${prompt}"
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