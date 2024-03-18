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
// import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:vector_math/vector_math_64.dart';


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

    // List<ARNode> nodes = [];
    // List<ARAnchor> anchors = [];
  }

  void _onPlaneTapped(List<ARHitTestResult> hitTestResults) {

    // var singleHitTestResult = hitTestResults.firstWhere((hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    //
    // if (singleHitTestResult != null) {
    //   var newAnchor = ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    //
    //   bool? didAddAnchor = await this.arAnchorManager!.addAnchor(newAnchor);
    //
    //   if (didAddAnchor!) {
    //     this.anchors.add(newAnchor);
    //     // Add note to anchor
    //     var newNode = ARNode(
    //         type: NodeType.webGLB,
    //         uri:
    //         "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
    //         scale: Vector3(0.2, 0.2, 0.2),
    //         position: Vector3(0.0, 0.0, 0.0),
    //         rotation: Vector4(1.0, 0.0, 0.0, 0.0));
    //     bool? didAddNodeToAnchor =
    //         await this.arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
    //     if (didAddNodeToAnchor!) {
    //       this.nodes.add(newNode);
    //     } else {
    //       this.arSessionManager!.onError("Adding Node to Anchor failed");
    //     }
    //   } else {
    //     this.arSessionManager!.onError("Adding Anchor failed");
    //   }
    }




    // for (var hitTestResult in hitTestResults) {
    //   if (hitTestResult.type == ARHitTestResultType.plane) {
    //     final position = hitTestResult.worldTransform.getColumn(3);
    //     _addARObjectAtHit(hitTestResult, position);
    //     return;
    //   }
    // }
  }

  void _addARObjectAtHit(ARHitTestResult hitTestResult, Vector4 position) {
    final vector3Position = Vector3(position.x, position.y, position.z);
    final node = ARNode(
      type: NodeType.fileSystemAppFolderGLB,
      uri: "assets/models/rigged.glb",
      position: vector3Position,
      scale: Vector3.all(0.5),
    );
    // arObjectManager?.addNode(node);
  }

  void _addARObject() async {
    final modelFilePath = '${(await getTemporaryDirectory()).path}/rigged.glb';
    final modelBytes = await rootBundle.load('assets/models/rigged.glb');
    await File(modelFilePath).writeAsBytes(modelBytes.buffer.asUint8List(modelBytes.offsetInBytes, modelBytes.lengthInBytes));

    final node = ARNode(
      type: NodeType.webGLB,
      uri: modelFilePath,
      position: Vector3(0, 0, -1),
      scale: Vector3.all(0.5),
    );
    // arObjectManager?.addNode(node);
  }
