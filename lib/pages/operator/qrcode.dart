import 'dart:ui'; // Contains ImageByteFormat
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:universal_html/html.dart' as html;

// Initialize the UUID generator once
const uuid = Uuid();

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  // GlobalKey to capture the widget's image data
  final GlobalKey qrKey = GlobalKey();

  // State variable for the random, unique QR code data
  late String qrCodeData;

  // --- FIX 1: Add missing initState method to initialize qrCodeData ---
  @override
  void initState() {
    super.initState();
    // Generate a new, random UUID when the screen is first built
    qrCodeData = 'parking:${uuid.v4()}';
  }

  Future<void> _downloadQrCode(BuildContext context) async {
    try {
      // 1. Capture the widget's boundary
      RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Scale factor for high resolution
      var image = await boundary.toImage(pixelRatio: 3.0);

      // Use the qualified constant name 'ImageByteFormat.png'
      ByteData? byteData = await image.toByteData(
        format: ImageByteFormat.png,
      ); // Corrected access

      if (byteData == null) {
        if (context.mounted)
          _showSnackbar(context, 'Failed to capture QR code data.', Colors.red);
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();
      String fileName =
          'parking_qr_${DateTime.now().millisecondsSinceEpoch}.png';

      if (kIsWeb) {
        // --- Web Implementation: Trigger Browser Download ---
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);

        if (context.mounted) {
          _showSnackbar(
            context,
            'QR Code download started in browser.',
            Colors.green,
          );
        }
      } else {
        // --- Mobile Implementation: Save to Gallery ---
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 100,
          name: fileName,
        );

        if (result['isSuccess'] == true && context.mounted) {
          _showSnackbar(
            context,
            'QR Code downloaded successfully!',
            Colors.green,
          );
        } else if (context.mounted) {
          _showSnackbar(context, 'Error saving file to gallery.', Colors.red);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(
          context,
          'An error occurred during download: $e',
          Colors.red,
        );
      }
    }
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if qrCodeData has been initialized (should be true after initState)
    if (!mounted) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Back Button ---
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: Color(0xFF666666)),
                    SizedBox(width: 8),
                    Text(
                      'Back to Dashboard',
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Main Card Container ---
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // --- Header and Icon ---
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.blue, Colors.green],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.qr_code,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Your Parking QR Code',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Display this at your parking entrance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- QR Code Image (DYNAMIC AND CAPTURABLE) ---
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: RepaintBoundary(
                          key: qrKey,
                          child: QrImageView(
                            data: qrCodeData,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- QR Code Value Box (DYNAMIC) ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007BFF).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QR Code Value:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              qrCodeData,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007BFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Download Button ---
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.blue, Colors.green],
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _downloadQrCode(context),
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Download QR Code',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Tip Box ---
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFFFFC107),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tip: Print this QR code and display it prominently at your parking entrance. Users can scan it to book parking instantly!',
                                style: TextStyle(color: Color(0xFF333333)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
