import 'package:flutter/material.dart';
//AR packages
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
//API packages
import 'package:flutter/material.dart'; // Core Flutter framework
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'package:audioplayers/audioplayers.dart'; // For playing audio
import 'package:path_provider/path_provider.dart'; // For accessing device file storage
import 'dart:io'; // For file operations

class ARCorePage extends StatefulWidget {
  const ARCorePage({Key? key}) : super(key: key);

  @override
  _ARCorePageState createState() => _ARCorePageState();
}

class _ARCorePageState extends State<ARCorePage> {

  late ArCoreController arCoreController;
  ArCoreNode? currentNode;
  double avatarScale = 1.0;

  final TextEditingController _textController = TextEditingController();
  bool _isProcessing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String apiKey = 'x4C5CSg-nWhx8gCMgNz7EFKIR4R92yyZpZb6hqbrbm2m';
  String ibmURL = 'https://api.eu-gb.text-to-speech.watson.cloud.ibm.com/instances/15f3dd95-0b14-4c74-9fb9-d1d0e92295d8/v1/synthesize';


  void _onBottonNavTap(int index) {
    if (index == 2) {
      _showSettingsDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
              enableTapRecognizer: true,
              enableUpdateListener: true,
            ),
          ),
          BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.credit_card),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Camera',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            onTap: _onBottonNavTap,
          ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onNodeTap = (name) => onTapHandler(name);
    arCoreController.onPlaneTap = _onPlaneTapHandler;
  }

  void _onPlaneTapHandler(List<ArCoreHitTestResult> hits) {
    if (hits.isNotEmpty) {
      createAvatar(hits.first.pose.translation, Colors.grey, false);
    }
  }

  List<ArCoreNode> createButtons() {
    final redMaterial = ArCoreMaterial(color: Colors.red, reflectance: 1.0);
    final redCylinder = ArCoreCylinder(materials: [redMaterial], radius: 0.01, height: 0.05);

    final blueMaterial = ArCoreMaterial(color: Colors.blue, reflectance: 1.0);
    final blueCylinder = ArCoreCylinder(materials: [blueMaterial], radius: 0.01, height: 0.05);

    final greenMaterial = ArCoreMaterial(color: Colors.green, reflectance: 1.0);
    final greenCylinder = ArCoreCylinder(materials: [greenMaterial], radius: 0.01, height: 0.05);

    final redButton = ArCoreNode(
      name: 'redButton',
      shape: redCylinder,
      position: vector.Vector3(-0.1, 0, 0),
      rotation: vector.Vector4(1, 0, 0, 1),
    );

    final blueButton = ArCoreNode(
      name: 'blueButton',
      shape: blueCylinder,
      position: vector.Vector3(0.1, 0, 0),
      rotation: vector.Vector4(1, 0, 0, 1),
    );

    final greenButton = ArCoreNode(
      name: 'greenButton',
      shape: greenCylinder,
      position: vector.Vector3(0, 0.1, 0),
      rotation: vector.Vector4(1, 0, 0, 1),
    );
    return [redButton, blueButton, greenButton];
  }

  void createAvatar(vector.Vector3 position, Color color, bool withButtons) {
    final material = ArCoreMaterial(color: color, reflectance: 1.0);
    final cylinder = ArCoreCylinder(materials: [material], radius: 0.15, height: 0.03);
    final ArCoreNode newNode;
    if (withButtons) {
      newNode = ArCoreNode(
        name: 'avatar',
        children: createButtons(),
        shape: cylinder,
        position: position,
        scale: vector.Vector3(avatarScale, avatarScale, avatarScale),
      );
    } else {
      newNode = ArCoreNode(
        name: 'avatar',
        shape: cylinder,
        position: position,
        scale: vector.Vector3(avatarScale, avatarScale, avatarScale),
      );
    }

    if (currentNode != null) {
      arCoreController.removeNode(nodeName: currentNode!.name);
    }

    arCoreController.addArCoreNode(newNode);
    currentNode = newNode;
  }

  void changeColor(Color color) {
    arCoreController.removeNode(nodeName: currentNode!.name);
    createAvatar(currentNode!.position!.value, color, true);
  }

  void onTapHandler(String name) {
    switch (name) {
      case "avatar":
        _convertTextToSpeech("Hello this is IBM welcome to my business card. What else would you like to hear");
        createAvatar(currentNode!.position!.value, Colors.grey, true);
        break;
      case "redButton":
        _convertTextToSpeech("You have selected to hear about my hobbies");
        changeColor(Colors.red);
        break;
      case "blueButton":
        _convertTextToSpeech("You have selected to hear about my work history");
        changeColor(Colors.blue);
        break;
      case "greenButton":
        _convertTextToSpeech("Thank you for taking the time to hear about my business");
        changeColor(Colors.green);
        break;
    }
  }

  void _updateAvatarScale() {
    if (currentNode != null) {
      arCoreController.removeNode(nodeName: currentNode!.name);
      createAvatar(currentNode!.position!.value, Colors.grey, true);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool subtitlesEnabled = false; // Variable to track subtitles option
        double avatarSize = avatarScale; // Variable to track avatar size

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white60, // Set background color to transparent
              elevation: 0, // Set elevation to 0 to remove shadow
              title: const Text("Settings"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    // Subtitles option
                    CheckboxListTile(
                      title: const Text('Subtitles'),
                      value: subtitlesEnabled,
                      onChanged: (bool? value) {
                        setState(() {
                          subtitlesEnabled = value ?? true;
                          // Implement subtitle display logic based on the value
                          // For example: if (subtitlesEnabled) { /* Show subtitles */ }
                        });
                      },
                    ),
                    // Avatar size label and slider

                    Text(
                      'Avatar Size: ${avatarSize.toStringAsFixed(2)}', // Display current avatar size
                      style: TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: avatarSize,
                      min: 0.5,
                      max: 2.0,
                      onChanged: (value) {
                        setState(() {
                          avatarSize = value;
                          avatarScale = value; // Update the global avatarScale variable
                          _updateAvatarScale(); // Update avatar scale in AR view
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

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
}