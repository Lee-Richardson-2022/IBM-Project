import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'ar_view.dart'; // Ensure this file exists and contains a properly implemented ARViewPage widget.

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        scanQR();
      }
    });
  }

  Future<void> scanQR() async {
    try {
      final String scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;

      if (scanResult != '-1' && scanResult == "https://youtu.be/dQw4w9WgXcQ") {
        await Future.delayed(const Duration(milliseconds: 500)); // Allow time for the camera to be released.
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ARViewPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred while scanning: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scan to AR')),
      body: const Center(
        child: Text('Scanning...'), // This text is displayed initially.
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.black),
              onPressed: () {
                // Placeholder for flashlight functionality or other feature
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.black),
              onPressed: () {
                // Placeholder for camera switch functionality or other feature
              },
            ),
          ],
        ),
      ),
    );
  }
}
