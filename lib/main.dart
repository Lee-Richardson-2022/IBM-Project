import 'package:flutter/material.dart';
import 'ar_view.dart'; // Ensure this file contains the ARViewPage class
import 'qr_scanner.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasData = false; // Initially, no QR code is scanned
  String modelIdentifier = ''; // Initially, no model is selected

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: hasData
                  ? BuildARView(modelIdentifier: modelIdentifier)
                  : BuildQRScanner(
                onDataScanned: (String data) async {
                  await Future.delayed(const Duration(seconds: 1)); // Delay for better user experience
                  if (mounted) {
                    setState(() {
                      // Check the scanned data and set the model identifier accordingly
                      if (data == "https://youtu.be/dQw4w9WgXcQ") {
                        modelIdentifier = 'model1'; // Set to your specific model identifier for the link
                      } else {
                        modelIdentifier = 'defaultModel'; // Fallback or default model identifier
                      }
                      hasData = true;
                    });
                  }
                },
              ),
            ),
            BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code),
                  label: 'Scan QR',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              onTap: navigationBarFunction,
            ),
          ],
        ),
      ),
    );
  }

  void navigationBarFunction(int index) {
    if (index == 1) {
      setState(() {
        hasData = false; // Prepare to scan a new QR code
        modelIdentifier = ''; // Reset the model identifier
      });
    }
  }
}
