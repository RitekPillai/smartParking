import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
// NOTE: We no longer need uuid, but keeping it imported for now.
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import for dart:ui to convert widget to image
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

// Initialize the UUID generator
// Keeping this import as it was in the user's initial code
const uuid = Uuid();

// Data model to hold parking spot info from Supabase
class ParkingSpot {
  final int id;
  final String name;

  ParkingSpot({required this.id, required this.name});
}

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen>
    with SingleTickerProviderStateMixin {
  // State variables for dynamic data and selection
  List<ParkingSpot> _parkingSpots = [];
  // Holds the ID selected by the admin, starts as null
  int? _selectedParkingId;

  // State variable for the QR code data
  // Initial placeholder is now more explicit about waiting for selection
  String qrCodeData = 'PARK_ID_A:SELECT_SPOT';

  // GlobalKey to capture the widget for image rendering
  final GlobalKey _qrKey = GlobalKey();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  // New state for download button loading
  bool _isDownloading = false;
  bool _isLoadingSpots = true; // State for loading parking data

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for the card/content
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Setup animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _colorAnimation = ColorTween(
      begin: Colors.blue.shade100,
      end: Colors.blue.shade400,
    ).animate(_animationController);

    // Start initial load animation
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Start the repeating pulse animation after the initial load
        _animationController.duration = const Duration(milliseconds: 1500);
        _animationController.repeat(reverse: true);
      }
    });

    // Fetch live data from Supabase immediately on load
    _fetchParkingSpots();
  }

  // --- Supabase Integration: Fetch existing spots (Filtering by Auth ID) ---
  Future<void> _fetchParkingSpots() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      debugPrint('Error: User ID is null. Administrator must be logged in.');
      if (mounted) {
        setState(() {
          _isLoadingSpots = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Authentication required to fetch parking spots.',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return; // Stop execution if no user ID is available
    }

    try {
      // Fetch only the ID and Name fields, filtered by the current user's 'authid'
      final response = await supabase
          .from('nearByParking')
          .select('id, name')
          .eq(
            'authid',
            userId,
          ) // Filter by 'authid' matching current user's UID
          .order('id', ascending: true);

      final List<ParkingSpot> fetchedSpots = (response as List).map((map) {
        return ParkingSpot(id: map['id'] as int, name: map['name'] as String);
      }).toList();

      if (mounted) {
        setState(() {
          _parkingSpots = fetchedSpots;
          _isLoadingSpots = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching parking spots: $e');
      if (mounted) {
        setState(() {
          _isLoadingSpots = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load parking spots: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  // Function to update QR code data when a new ID is selected
  void _updateQrCodeData(int newId) {
    setState(() {
      _selectedParkingId = newId;
      // Use the live selected ID to generate the QR data
      qrCodeData = 'PARK_ID_A:$newId';
    });
  }

  // --- Download Logic (Unchanged) ---
  Future<void> _downloadQrCode() async {
    if (_selectedParkingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a parking spot first.'),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (mounted) {
        // Placeholder for the actual download logic:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'QR code image buffer generated. Saving logic needs platform implementation.',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate image: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.lightBlue.shade50, Colors.grey.shade100],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(context),
                const SizedBox(height: 24),

                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: _buildMainCard(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blue.shade700,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              'Admin Dashboard',
              style: GoogleFonts.poppins(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Card(
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            // Simplified Header
            _buildHeader(),
            const SizedBox(height: 30),

            // Spot Selection Dropdown (Required for data filtering)
            _buildSpotSelection(),
            const SizedBox(height: 40),

            // Animated QR Code Image
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _colorAnimation.value ?? Colors.blue.shade100,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: QrImageView(
                      data: qrCodeData,
                      version: QrVersions.auto,
                      size: 250.0,
                      foregroundColor: const Color(0xFF1A237E),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Combined Info Box (Code Value + Tip)
            _buildCombinedInfoBox(),
            const SizedBox(height: 30),

            // Download Button
            _buildDownloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.green.shade400],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade300.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_2_sharp,
            color: Colors.white,
            size: 45,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Generate Parking Spot QR Code',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a registered spot to generate its unique, scannable QR code linked to your account.',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 15,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildSpotSelection() {
    if (_isLoadingSpots) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_parkingSpots.isEmpty) {
      // User-specific database check - only spots linked by 'authid'
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No registered parking spots found under your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please ensure spots are created and linked to your account via the "authid" column.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(color: Colors.red.shade700),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Select Parking Spot:',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedParkingId,
              hint: const Text('Choose a spot ID to generate QR code'),
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
              icon: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.blue.shade600,
              ),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  _updateQrCodeData(newValue);
                }
              },
              items: _parkingSpots.map<DropdownMenuItem<int>>((spot) {
                return DropdownMenuItem<int>(
                  value: spot.id,
                  child: Text('ID: ${spot.id} - ${spot.name}'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    // Disable download if no spot is selected or currently processing
    final bool isDisabled = _isDownloading || _selectedParkingId == null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isDisabled ? null : _downloadQrCode,
        icon: _isDownloading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_alt, size: 20),
        label: Text(
          _isDownloading ? 'Processing...' : '2. Download QR Image (PNG)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.indigo.shade600,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          shadowColor: Colors.indigo.shade300,
          disabledBackgroundColor: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildCombinedInfoBox() {
    final isSelected = _selectedParkingId != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Colors.green.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QR Code Value:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            qrCodeData,
            style: GoogleFonts.sourceCodePro(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 20, thickness: 1),
          Text.rich(
            TextSpan(
              style: GoogleFonts.roboto(color: Colors.black87, fontSize: 14),
              children: [
                TextSpan(
                  text: 'Status: ',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: isSelected
                      ? 'Ready to Download (Spot ID $_selectedParkingId)'
                      : 'Please select a parking spot above to generate the final code.',
                  style: GoogleFonts.roboto(
                    color: isSelected ? Colors.green.shade800 : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
