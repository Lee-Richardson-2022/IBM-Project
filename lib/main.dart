import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Core Example',
      home: ARCorePage(),
    );
  }
}

class ARCorePage extends StatefulWidget {
  @override
  _ARCorePageState createState() => _ARCorePageState();
}

class _ARCorePageState extends State<ARCorePage> {
  late ArCoreController arCoreController;
  ArCoreNode? currentNode;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              )
            ],
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
      createAvatar(hits.first.pose.translation, Colors.grey);
    }
  }

  void createAvatar(vector.Vector3 position, Color color) {
    final redMaterial = ArCoreMaterial(color: Colors.red, reflectance: 1.0);
    final redCylinder = ArCoreCylinder(materials: [redMaterial], radius: 0.01, height: 0.05);

    final blueMaterial = ArCoreMaterial(color: Colors.blue, reflectance: 1.0);
    final blueCylinder = ArCoreCylinder(materials: [blueMaterial], radius: 0.01, height: 0.05);

    final greenMaterial = ArCoreMaterial(color: Colors.green, reflectance: 1.0);
    final greenCylinder = ArCoreCylinder(materials: [greenMaterial], radius: 0.01, height: 0.05);

    final redButton = ArCoreNode (
      name: 'redButton',
      shape: redCylinder,
      position: vector.Vector3(-0.1, 0, 0),
      rotation: vector.Vector4(1, 0, 0, 1),
    );

    final blueButton = ArCoreNode (
      name: 'blueButton',
      shape: blueCylinder,
      position: vector.Vector3(0.1, 0, 0),
      rotation: vector.Vector4(1, 0, 0, 1),
    );

    final greenButton = ArCoreNode (
      name: 'greenButton',
      shape: greenCylinder,
      position: vector.Vector3(0, 0.1, 0),
      rotation: vector.Vector4(1, 0, 0, 1),
    );

    final material = ArCoreMaterial(color: color, reflectance: 1.0);
    final cylinder = ArCoreCylinder(materials: [material], radius: 0.15, height: 0.03);
    final newNode = ArCoreNode(
        name: 'avatar',
        children: [redButton, blueButton, greenButton],
        shape: cylinder,
        position: position
    );

    if (currentNode != null) {
      arCoreController.removeNode(nodeName: currentNode!.name);
    }

    arCoreController.addArCoreNode(newNode);
    currentNode = newNode;
  }

  void changeColor(Color color) {
    arCoreController.removeNode(nodeName: currentNode!.name);

    createAvatar(currentNode!.position!.value, color);
  }

  void onTapHandler(String name) {
    // Determine which cylinder was tapped
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


  // void _addSphere(ArCoreController controller) {
  //   final material = ArCoreMaterial(color: Colors.grey, metallic: 1.0);
  //   final sphere = ArCoreCylinder(materials: [material], height: 0.05 , radius: 0.1 );
  //   final node = ArCoreNode(shape: sphere, position: vector.Vector3(0, 0, -1));
  //   controller.addArCoreNode(node);
  // }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
