import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartparking/models/users/bookingService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// NOTE: Ensure this import path is correct for your project structure!

// --- SCAN QR CODE SCREEN ---

class QRCode extends StatefulWidget {
  const QRCode({super.key});

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> with SingleTickerProviderStateMixin {
  final TextEditingController _manualCodeController = TextEditingController();

  bool _isScanning = false;

  // State variables for local management (Fix for mobile_scanner API issue)
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  // Controller for the MobileScanner widget
  MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  // Animation controllers for UI effects
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Setup pulse animation for the scanning button area
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  // --- 🔑 CORE LOGIC: Fetch Data and Show Booking Sheet ---
  Future<void> _processParkingCode(String rawCode) async {
    int? parkingId;

    // Logic to reliably extract the ID remains the same
    if (rawCode.contains(':')) {
      final parts = rawCode.split(':');
      if (parts.length >= 2) {
        final idPart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
        parkingId = int.tryParse(idPart);
      }
    } else if (rawCode.startsWith('PARK_ID_')) {
      parkingId = int.tryParse(rawCode.substring('PARK_ID_'.length));
    } else {
      parkingId = int.tryParse(rawCode.trim());
    }

    if (parkingId == null) {
      _showErrorSnackBar('Invalid parking code format. Please check the code.');
      return;
    }

    try {
      debugPrint('Fetching parking details for ID: $parkingId');
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('nearByParking')
          .select('name, price_per_hour')
          .eq('id', parkingId)
          .single();

      final String parkingName = response['name'] as String;

      // FIX: Safely convert fetched number (int or double) to double
      final num priceNum = response['price_per_hour'] as num;
      final double rate = priceNum.toDouble();

      if (mounted) {
        // Close the scanner sheet/view
        Navigator.of(context).pop();

        _showSuccessSnackBar('Parking details loaded!');

        // 2. Call the booking sheet function (assuming it's defined elsewhere)
        // Ensure you have the global function showBookingSheet defined and imported.
        showBookingSheet(
          context: context,
          parkingName: parkingName,
          parkingId: parkingId,
          rate: rate,
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch parking details: $e');
      _showErrorSnackBar(
        'Parking ID $parkingId not found or connection failed.',
      );
    }
  }

  // --- 🔑 UI Actions ---

  Future<void> _startQrScan() async {
    // 1. Request Camera Permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _showErrorSnackBar(
        'Camera permission denied. Please enable it in settings.',
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildScannerSheet(context),
      ).whenComplete(() {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      });
    }
  }

  void _submitManualCode() {
    final code = _manualCodeController.text.trim();
    if (code.isNotEmpty) {
      // Process the manually entered code
      _processParkingCode(code);
    } else {
      _showErrorSnackBar('Please enter a code.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $message'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $message'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  @override
  void dispose() {
    _manualCodeController.dispose();
    scannerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --- UI BUILDING BLOCKS ---

  Widget _buildScannerSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Sheet Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan Parking QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Scanner View
          Expanded(
            child: MobileScanner(
              controller: scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? rawValue = barcodes.first.rawValue;
                  if (rawValue != null) {
                    scannerController.stop();
                    _processParkingCode(rawValue);
                  }
                }
              },
            ),
          ),
          // Controls (Flash and Camera Switch)
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Torch/Flash Button (Uses local state)
                IconButton(
                  color: Colors.white,
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: _isFlashOn ? Colors.yellow : Colors.white,
                  ),
                  onPressed: () async {
                    await scannerController.toggleTorch();
                    setState(() {
                      _isFlashOn = !_isFlashOn;
                    });
                  },
                ),
                // 2. Camera Switch Button (Uses local state)
                IconButton(
                  color: Colors.white,
                  icon: Icon(
                    _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await scannerController.switchCamera();
                    setState(() {
                      _isFrontCamera = !_isFrontCamera;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFF0F8FF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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

  // ... (buildMainCard and other UI helpers follow below) ...

  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo & Title
          _buildHeader(),
          const SizedBox(height: 30),

          // --- SCANNING AREA BLOCK with Animation ---
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildScanningArea(context),
              );
            },
          ),

          const SizedBox(height: 30),
          _buildDivider(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 20),
        // Title & Subtitle
        Text(
          'Instant Parking Booking',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF37474F),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Scan the QR code at the entrance to reserve your spot and start the clock.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildScanningArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Icon(
              Icons.camera_alt_outlined,
              color: Colors.blue,
              size: 70,
            ),
          ),
          Text(
            'Tap the button below to activate the scanner.',
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 20),
          GradientButton(
            gradientColors: const [
              Color(0xFF1E88E5),
              Color(0xFF43A047),
            ], // Blue to Green
            onPressed: _isScanning ? null : _startQrScan,
            text: _isScanning
                ? 'Launching Scanner...'
                : 'Open Camera / Scan QR',
            icon: _isScanning ? Icons.cached : Icons.qr_code_scanner,
            isLoading: _isScanning,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider(color: Colors.grey, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'OR',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey, height: 1)),
      ],
    );
  }

  Widget _buildManualEntryArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Parking Code Manually',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF37474F),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _manualCodeController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'e.g., parking:12345 or 12345',
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            border: OutlineInputBorder(
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
        GradientButton(
          onPressed: _submitManualCode,
          text: 'Submit Code',
          isDense: true,
          gradientColors: const [
            Color(0xFF0D47A1),
            Color(0xFF1B5E20),
          ], // Darker Blue/Green
        ),
      ],
    );
  }

  Widget _buildTipSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7), // Light yellow tint
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Helpful Tip: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  TextSpan(
                    text:
                        'The code is unique to the physical parking spot or entrance. If scanning fails, ensure the code is clearly visible or use the manual entry option.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
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

// --- REUSABLE WIDGET: GRADIENT BUTTON (Unchanged but included for completeness) ---

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
    this.gradientColors = const [Color(0xFF4FC3F7), Color(0xFF1E88E5)],
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
