import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;


class ARViewPage extends StatefulWidget {
  const ARViewPage({super.key});

  @override
  _ARViewPageState createState() => _ARViewPageState();
}

class _ARViewPageState extends State<ARViewPage> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  ARLocationManager? arLocationManager;

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR View"),
      ),
      body: ARView(
        onARViewCreated: _onARViewCreated,
        planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addARObject,
        tooltip: 'Add AR Object',
        child: const Icon(Icons.add),
      ), // This trailing comment was missing a closing bracket in your original snippet
    );
  }

  void _onARViewCreated(ARSessionManager arSessionManager, ARObjectManager arObjectManager, ARAnchorManager arAnchorManager, ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;
    this.arLocationManager = arLocationManager;

    arSessionManager.onPlaneOrPointTap = _onPlaneTapped;
  }

  void _onPlaneTapped(List<ARHitTestResult> hitTestResults) {
    for (var hitTestResult in hitTestResults) {
      if (hitTestResult.type == ARHitTestResultType.plane) {
        _addARObjectAtHit(hitTestResult);
        return;
      }
    }
  }

  void _addARObject() async {
    const modelFilePath = 'assets/models/Monkey.glb';

    final node = ARNode(
      type: NodeType.webGLB,
      uri: modelFilePath,
      position: vector.Vector3(0, 0, -1),
      scale: vector.Vector3.all(0.5),
    );
    arObjectManager?.addNode(node);
  }

  void _addARObjectAtHit(ARHitTestResult hitTestResult) {
    final node = ARNode(
      type: NodeType.webGLB,
      uri: "assets/models/Monkey.glb",
      position: vector.Vector3(0, 0, -1),
      scale: vector.Vector3.all(0.5),
    );
    arObjectManager?.addNode(node);
  }
}
