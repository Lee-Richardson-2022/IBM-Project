 import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'automation_widget.dart';


class BuildARView extends StatefulWidget {
  const BuildARView({super.key});

  @override
  State<BuildARView> createState() => _BuildARViewState();
}

class _BuildARViewState extends State<BuildARView> {

  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  ARNode? node;
  ARAnchor? anchor;

  bool _nodePlaced = false;

  @override
  Widget build(BuildContext context) {
    return
        Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            if (_nodePlaced)
              BuildAutomationWidget(),
            if (_nodePlaced)
              Positioned(
                bottom: 16.0,
                left: 16.0,
                child: FloatingActionButton(
                  onPressed: () {
                    removeNodeAndAnchor();
                  },
                  child: Icon(Icons.replay),
                ),
              ),
          ],
        );
  }

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  void onARViewCreated(ARSessionManager arSessionManager, ARObjectManager arObjectManager, ARAnchorManager arAnchorManager, ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handlePans: true,
      handleRotation: true,
    );

    this.arObjectManager!.onInitialize();
    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;

  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    if (node == null && anchor == null) {
      var singleHitTestResult = hitTestResults.firstWhere((
          hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
      var newAnchor = ARPlaneAnchor(
          transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
      if (didAddAnchor!) {
        anchor = (newAnchor);

        // Add node to the anchor
        var newNode = ARNode(
            type: NodeType.localGLTF2,
            uri: "Models/Chicken_01.gltf",
            scale: vector.Vector3(0.2, 0.2, 0.2),
            position: vector.Vector3(0.0, 0.0, 0.0),
            rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));
        bool? didAddNodeToAnchor = await arObjectManager!
            .addNode(newNode, planeAnchor: newAnchor);
        if (didAddNodeToAnchor!) {
          node = (newNode);
          setState(() {
            _nodePlaced = true;
          });
        } else {
          arSessionManager!.onError("Adding Node to Anchor failed");
        }
      } else {
        arSessionManager!.onError("Adding Anchor failed");
      }
    }
  }

  Future<void> removeNodeAndAnchor()async {
    if (node != null && anchor != null){
      arObjectManager!.removeNode(node!);
      node = null;
      arAnchorManager!.removeAnchor(anchor!);
      anchor = null;
    }
    setState(() {
      _nodePlaced = false;
    });
  }

}
