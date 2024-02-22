import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARCorePage extends StatefulWidget {
  const ARCorePage({Key? key}) : super(key: key);

  @override
  _ARCorePageState createState() => _ARCorePageState();
}

class _ARCorePageState extends State<ARCorePage> {
  late ArCoreController arCoreController;
  ArCoreNode? currentNode;
  double avatarScale = 1.0;

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
        createAvatar(currentNode!.position!.value, Colors.grey, true);
        break;
      case "redButton":
        changeColor(Colors.red);
        break;
      case "blueButton":
        changeColor(Colors.blue);
        break;
      case "greenButton":
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

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}