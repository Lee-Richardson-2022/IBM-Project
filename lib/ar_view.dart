import 'dart:io';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
      ),
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
        final position = hitTestResult.worldTransform.getColumn(3);
        _addARObjectAtHit(hitTestResult, position);
        return;
      }
    }
  }

  void _addARObjectAtHit(ARHitTestResult hitTestResult, vector.Vector4 position) {
    final vector3Position = vector.Vector3(position.x, position.y, position.z);
    final node = ARNode(
      type: NodeType.fileSystemAppFolderGLB,
      uri: "assets/models/rigged.glb",
      position: vector3Position,
      scale: vector.Vector3.all(0.5),
    );
    arObjectManager?.addNode(node);
  }

  void _addARObject() async {
    final modelFilePath = '${(await getTemporaryDirectory()).path}/rigged.glb';
    final modelBytes = await rootBundle.load('assets/models/rigged.glb');
    await File(modelFilePath).writeAsBytes(modelBytes.buffer.asUint8List(modelBytes.offsetInBytes, modelBytes.lengthInBytes));

    final node = ARNode(
      type: NodeType.webGLB,
      uri: modelFilePath,
      position: vector.Vector3(0, 0, -1),
      scale: vector.Vector3.all(0.5),
    );
    arObjectManager?.addNode(node);
  }
}