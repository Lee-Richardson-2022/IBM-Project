import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'package:audioplayers/audioplayers.dart'; // For playing audio
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart';


Future<void> ConvertTextToSpeech(String? text) async {
  const String apiKey = 'i6dMF2ABNtgoeKxJKW3F88a_DBwtxMf3rOwS7Bde_SI3';
  const String ibmURL = 'https://api.eu-gb.text-to-speech.watson.cloud.ibm.com/instances/c7604c72-6d16-4e92-87b0-1fa408703bdc/v1/synthesize';
  final AudioPlayer audioPlayer = AudioPlayer();

  // Prepare HTTP request headers for IBM API authentication
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Basic ${base64Encode(utf8.encode('apikey:$apiKey'))}',
  };

  // Create HTTP request object
  var request = http.Request('POST', Uri.parse(ibmURL));
  request.body = json.encode({"text": text, "accept": "audio/wav"});
  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // Process successful response
      var bytes = await response.stream.toBytes();
      var dir = await getTemporaryDirectory();
      var file = File("${dir.path}/speech.wav");

      await file.writeAsBytes(bytes); // Store the audio file
      await audioPlayer.play(DeviceFileSource(file.path)); // Play audio
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
}

