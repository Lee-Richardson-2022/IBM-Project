import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// Add a callback function to handle the data scanned from QR code
class BuildQRScanner extends StatefulWidget {
  final Function(String) onDataScanned; // Callback to pass scanned data

  const BuildQRScanner({super.key, required this.onDataScanned});

  @override
  State<BuildQRScanner> createState() => _BuildQRScannerState();
}

class _BuildQRScannerState extends State<BuildQRScanner> {
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
      // Start scanning for QR code
      final String scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Red line color
        'Cancel', // Cancel button text
        true, // Whether to show flash icon
        ScanMode.QR, // QR scanning mode
      );

      // Proceed only if a valid QR code is scanned and the widget is still mounted
      if (!mounted || scanResult == '-1') return;

      // Use the callback to pass the scanned data back
      widget.onDataScanned(scanResult);
    } catch (e) {
      if (!mounted) return;
      // Show error if something goes wrong
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
                  Navigator.of(context).pop(); // Close the dialog
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
    // Simple scaffold to show when the scanner is not actively scanning
    return Scaffold(
      body: Center(
        child: Text(''), // Placeholder text
      ),
    );
  }
}
