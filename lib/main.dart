import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// Import the ARViewPage from ar_view.dart
import 'ar_view.dart'; // Make sure this path matches the location of your ar_view.dart file

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool hasNavigatedToARView = false; // Add this line


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: cameraController,
        onDetect: (barcodeCapture) {
          final List<Barcode> barcodes = barcodeCapture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            debugPrint('Barcode found! $code');
            if (!hasNavigatedToARView && code != null && code == "https://youtu.be/dQw4w9WgXcQ") {
              setState(() {
                hasNavigatedToARView = true; // Set to true to prevent multiple navigations
                cameraController.stop();
              });
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ARViewPage()),
              ).then((_) => setState(() { hasNavigatedToARView = false; })); // Reset on return
            }
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.flash_on),
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
      ),
    );
  }
}
