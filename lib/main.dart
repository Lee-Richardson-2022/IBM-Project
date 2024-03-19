import 'package:flutter/material.dart';
import 'ar_view.dart';
import 'qr_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasData = false; // Variable to track whether data is available

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          hasData ? const BuildARView() : const BuildQRScanner(),

           BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt),
                  label: 'Camera',
                ),
                BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
                ),
              ],
            )
          ],
      ),
    );
  }

  // Method to handle data scanned by QR scanner
  void onDataScanned(String data) {
    setState(() {
      hasData = true; // Set hasData to true when data is scanned
    });
  }
}


