import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARViewPage extends StatefulWidget {
  const ARViewPage({Key? key}) : super(key: key);

  @override
  _ARViewPageState createState() => _ARViewPageState();
}

class _ARViewPageState extends State<ARViewPage> {
  late ArCoreController arCoreController;
  ArCoreNode? currentNode;
  double avatarScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
              enableTapRecognizer: true,
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
            onTap: _onBottomNavTap,
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 2) {
      _showSettingsDialog();
    }
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
        scale: vector.Vector3.all(avatarScale),
      );
    } else {
      newNode = ArCoreNode(
        name: 'avatar',
        shape: cylinder,
        position: position,
        scale: vector.Vector3.all(avatarScale),
      );
    }

    if (currentNode != null) {
      arCoreController.removeNode(nodeName: currentNode!.name);
    }

    arCoreController.addArCoreNode(newNode);
    currentNode = newNode;
  }

  List<ArCoreNode> createButtons() {
    // Define materials
    final redMaterial = ArCoreMaterial(color: Colors.red, reflectance: 1.0);
    final blueMaterial = ArCoreMaterial(color: Colors.blue, reflectance: 1.0);
    final greenMaterial = ArCoreMaterial(color: Colors.green, reflectance: 1.0);

    // Create cylinders with defined materials
    final redCylinder = ArCoreCylinder(materials: [redMaterial], radius: 0.01, height: 0.05);
    final blueCylinder = ArCoreCylinder(materials: [blueMaterial], radius: 0.01, height: 0.05);
    final greenCylinder = ArCoreCylinder(materials: [greenMaterial], radius: 0.01, height: 0.05);

    // Assign nodes for each color
    final redButton = ArCoreNode(shape: redCylinder, position: vector.Vector3(-0.1, 0, 0));
    final blueButton = ArCoreNode(shape: blueCylinder, position: vector.Vector3(0.1, 0, 0));
    final greenButton = ArCoreNode(shape: greenCylinder, position: vector.Vector3(0, 0.1, 0));

    return [redButton, blueButton, greenButton];
  }

  void onTapHandler(String name) {
    switch (name) {
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

  void changeColor(Color color) {
    if (currentNode != null) {
      createAvatar(currentNode!.position!.value, color, true);
    }
  }

  void _updateAvatarScale() {
    if (currentNode != null) {
      createAvatar(currentNode!.position!.value, Colors.grey, true);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Settings"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Avatar Size: ${avatarScale.toStringAsFixed(2)}'),
                    Slider(
                      value: avatarScale,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: avatarScale.toStringAsFixed(2),
                      onChanged: (double value) {
                        setState(() {
                          avatarScale = value;
                          _updateAvatarScale();
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
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
