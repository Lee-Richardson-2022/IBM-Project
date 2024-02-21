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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
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
      final material = ArCoreMaterial(color: Colors.blue, reflectance: 1.0);
      final avatar = ArCoreCylinder(materials: [material], radius: 0.15, height: 0.03);

      final node = ArCoreNode(
          shape: avatar,
          position: hits.first.pose.translation
      );
      arCoreController.addArCoreNode(node);
    }
  }

  // final material = ArCoreMaterial(color: Colors.blue, reflectance: 1.0);
  // final sphere = ArCoreSphere(materials: [material], radius: 0.1);
  // final node = ArCoreNode(
  //     shape: sphere,
  //     position: hits.first.pose.translation,

  void onTapHandler(String name) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(content: Text('Node Tapped')),
    );
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
