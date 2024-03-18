import 'package:flutter/material.dart'; // Core Flutter framework
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'package:audioplayers/audioplayers.dart'; // For playing audio
import 'package:path_provider/path_provider.dart'; // For accessing device file storage
import 'dart:io'; // For file operations

Future<void> _convertTextToSpeech(String message) async {
  setState(() {
    _isProcessing = true; // Indicate processing has begun
  });

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

  setState(() {
    _isProcessing = false; // Processing completed
  });
}

@override
void dispose() {
  arCoreController.dispose();
  super.dispose();
}
