import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- SCAN QR CODE SCREEN ---

class QRCode extends StatefulWidget {
  const QRCode({super.key});

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  final TextEditingController _manualCodeController = TextEditingController();
  String _scanResult = 'No scan yet';
  bool _isScanning = false;

  Future<void> _startQrScan() async {
    setState(() {
      _isScanning = true;
    });

    // Placeholder simulation:
    await Future.delayed(const Duration(seconds: 2));
    const mockResult = 'parking:12345booked';

    if (mounted) {
      setState(() {
        _isScanning = false;
        _scanResult = mockResult;
      });
      _showSuccessDialog(mockResult);
    }
  }

  void _submitManualCode() {
    final code = _manualCodeController.text.trim();
    if (code.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submitting code: $code')));
      // Logic to process the manually entered code
      _showSuccessDialog(code);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a code.')));
    }
  }

  void _showSuccessDialog(String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Code Processed'),
          content: Text('Successfully processed code: $code'),
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

  @override
  Widget build(BuildContext context) {
    // The screen is wrapped in a container with a subtle gradient background
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F5E9), // Light green tint
            Color(0xFFF0F8FF), // Light blue tint
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Important for showing gradient
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                  ), // Max width for tablet/desktop views
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCustomAppBar(),
                      const SizedBox(height: 30),
                      _buildMainCard(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back to Home
          TextButton.icon(
            onPressed: () {
              // Handle navigation back (e.g., Navigator.pop(context))
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
            label: const Text(
              'Back to Home',
              style: TextStyle(color: Colors.blueGrey, fontSize: 16),
            ),
          ),
          // Hello, user! and menu
          Row(
            children: [
              const Text(
                'Hello, muhsinjham!',
                style: TextStyle(color: Colors.blueGrey, fontSize: 16),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.blueGrey),
                onPressed: () {
                  // Open side menu
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // The main white card containing all the scanning content
  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Logo (Placeholder for the Smart Parking icon)
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.green],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.qr_code_scanner,
                color: Colors.white, // A strong blue for the logo
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title & Subtitle
          Text(
            'Scan QR Code',
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF37474F), // Dark grey for text
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Scan the parking area's QR code to book instantly",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // --- SCANNING AREA BLOCK ---
          _buildScanningArea(context),

          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 100, child: Divider()),
              const SizedBox(width: 10),
              const Center(
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 100, child: Divider()),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 30),

          // --- MANUAL ENTRY BLOCK ---
          _buildManualEntryArea(),

          const SizedBox(height: 20),

          // Tip Section
          _buildTipSection(),
        ],
      ),
    );
  }

  Widget _buildScanningArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.green.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 2),
      ),
      child: Column(
        children: [
          // Placeholder for camera viewfinder icon/animation
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Icon(
              Icons.camera_alt_outlined,
              color: Colors.blue,
              size: 70,
            ),
          ),
          Text(
            'Point your camera at the QR code displayed at the parking entrance',
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 20),
          GradientButton(
            gradientColors: [Colors.blue, Colors.green],
            onPressed: _isScanning ? null : _startQrScan,
            text: _isScanning ? 'Opening Camera...' : 'Open Camera / Upload QR',
            icon: _isScanning ? Icons.cached : Icons.photo_camera,
            isLoading: _isScanning,
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntryArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter QR Code Manually',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF37474F),
          ),
        ),
        const SizedBox(height: 10),
        // Input Field
        TextFormField(
          controller: _manualCodeController,
          decoration: InputDecoration(
            hintText: 'e.g., parking:12345abcde',
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Submit Code Button
        GradientButton(
          onPressed: _submitManualCode,
          text: 'Submit Code',
          isDense: true,
          gradientColors: const [
            Colors.blue,
            Colors.green,
          ], // Darker blue gradient
        ),
      ],
    );
  }

  Widget _buildTipSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Lightest blue background
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFF1E88E5), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Tip: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  TextSpan(
                    text:
                        'The QR code is usually displayed at the parking entrance or with the parking operator. You can also ask the operator for the parking code.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1E88E5)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE WIDGET: GRADIENT BUTTON ---

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isDense;
  final List<Color> gradientColors;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isDense = false,
    this.isLoading = false,
    this.gradientColors = const [
      Color(0xFF4FC3F7), // Light Blue
      Color(0xFF1E88E5), // Primary Blue
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: isDense ? 45 : 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: onPressed == null
            ? null
            : LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: onPressed == null ? Colors.grey[300] : null,
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: isDense ? 0 : 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
