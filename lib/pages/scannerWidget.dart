import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: MobileScanner(
        // The onDetect callback is where you handle the scanned result
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;

          // Assuming you're only interested in the first detected barcode
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              // Handle the scanned QR code data (e.g., navigate to a new screen,
              // show a dialog, or update state).
              print('Barcode found! Data: $code');

              // IMPORTANT: Often you'll want to stop the scanner after a successful scan
              // This is usually done by managing a MobileScannerController.
              // For simplicity, this example just prints the data.

              // Example of a minimal action: show a SnackBar
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Scanned: $code')));
            }
          }
        },
      ),
    );
  }
}
