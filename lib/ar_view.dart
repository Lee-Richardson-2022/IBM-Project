import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'api_functions.dart';
import 'package:flutter/material.dart'; // Core Flutter framework
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'package:audioplayers/audioplayers.dart'; // For playing audio
import 'package:path_provider/path_provider.dart'; // For accessing device file storage
import 'dart:io'; // For file operations


class ObjectGesturesWidget extends StatefulWidget {
  ObjectGesturesWidget({Key? key}) : super(key: key);
  @override
  _ObjectGesturesWidgetState createState() => _ObjectGesturesWidgetState();
}

class _ObjectGesturesWidgetState extends State<ObjectGesturesWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  NodeTapResultHandler? onNodeTap;
  NodePanStartHandler? onPanStart;
  NodePanChangeHandler? onPanChange;
  NodePanEndHandler? onPanEnd;
  NodeRotationStartHandler? onRotationStart;
  NodeRotationChangeHandler? onRotationChange;
  NodeRotationEndHandler? onRotationEnd;

  final String apiKey = 'YMVJWGmKng-VU9EmjKMw0aEncMrZdc-CHZyCaHmR04qP';
  final String ibmURL =
      'https://api.au-syd.text-to-speech.watson.cloud.ibm.com/instances/94dbd1e6-3df9-4900-b1ce-c88e76596c4c/v1/synthesize';
  bool _isProcessing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  ARNode? node;
  ARAnchor? anchor;

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Object Transformation Gestures'),
        ),
        body: Container(
            child: Stack(children: [
              ARView(
                onARViewCreated: onARViewCreated,
                planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
                // onTap: onARViewTapped,
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: onRemoveEverything,
                          child: Text("Remove Everything")),
                    ]),
              )
            ])));
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
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

    this.arObjectManager!.onNodeTap = onNodeTapped;
    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;
  }

  Future<void> onRemoveEverything() async {
    anchor = null;
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults.firstWhere(
            (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      var newAnchor =
      ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor =
      await this.arAnchorManager!.addAnchor(newAnchor);
      if (didAddAnchor!) {
        this.anchor = (newAnchor);

        final modelFilePath =
            '${(await getTemporaryDirectory()).path}/rigged.glb';

        // Add node to the anchor
        var newNode = ARNode(
            type: NodeType.webGLB,
            uri: modelFilePath,
            scale: vector.Vector3(0.2, 0.2, 0.2),
            position: vector.Vector3(0.0, 0.0, 0.0),
            rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0));
        bool? didAddNodeToAnchor = await this.arObjectManager!
            .addNode(newNode, planeAnchor: newAnchor);
        if (didAddNodeToAnchor!) {
          this.node = (newNode);
        } else {
          this.arSessionManager!.onError("Adding Node to Anchor failed");
        }
      } else {
        this.arSessionManager!.onError("Adding Anchor failed");
      }
    }
  }

  Future<void> onNodeTapped(List<String> nodeNames) async {
    print("Node has been tapped" + nodeNames[0]);
    convertTextToSpeech("Hello this is john's business card");
  }

  onPanStarted(String nodeName) {
    print("Started panning node " + nodeName);
  }

  onPanChanged(String nodeName) {
    print("Continued panning node " + nodeName);
  }

  onPanEnded(String nodeName, Matrix4 newTransform) {
    print("Ended panning node " + nodeName);
    final pannedNode = this.node;
  }

  onRotationStarted(String nodeName) {
    print("Started rotating node " + nodeName);
  }

  onRotationChanged(String nodeName) {
    print("Continued rotating node " + nodeName);
  }

  onRotationEnded(String nodeName, Matrix4 newTransform) {
    print("Ended rotating node " + nodeName);
    final rotatedNode = this.node;
  }

    Future<void> convertTextToSpeech(String message) async {
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
  }
