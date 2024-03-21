import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'ar_view.dart'; // Ensure you have this import if 'BuildARView' is in a separate file

class BuildQRScanner extends StatefulWidget {
  const BuildQRScanner({Key? key}) : super(key: key);

  @override
  State<BuildQRScanner> createState() => _BuildQRScannerState();
}

class _BuildQRScannerState extends State<BuildQRScanner> {
  Barcode? result;
  QRViewController? controller;
  late bool complete;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1, // You can adjust the flex if needed to give more space to the QR view
            child: QRView(
              key: GlobalKey(debugLabel: 'QR'),
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          // Removed the Expanded widget that contained the text
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      // Check if the QR code is valid
      if (result!.code == 'https://youtu.be/dQw4w9WgXcQ') {
        setState(() {
          complete = true;
        });
        // controller.pauseCamera(); // Optional: Pause the camera
        // Instead of navigating to a new page, pop back to home page and pass the scanned data
        Navigator.of(context).pop(result!.code);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}