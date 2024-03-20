import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibm_test/chatbot.dart';
import 'ar_view.dart';
import 'qr_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  bool hasData = true; // Variable to track whether data is available


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            hasData ? const Expanded(child: BuildARView()) : const Expanded(
                child: BuildQRScanner()),
            BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code),
                  label: 'Scan qr',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ], onTap: NavigationBarFunction,
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle data scanned by QR scanner
  void onDataScanned(String data) {
    setState(() {
      hasData = true; // Set hasData to true when data is scanned
    });
  }

  NavigationBarFunction(int index) {
    if (index == 1) {
      setState(() {
        hasData = false; // Set hasData to true when data is scanned
      });
    }
  }
}