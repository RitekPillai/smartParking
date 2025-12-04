import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:smartparking/pages/operator/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// --- NEW IMPORTS FOR PERMISSION HANDLING ---
import 'package:permission_handler/permission_handler.dart';
// ---------------------------------------------
// Add this line to your imports at the top of the file:
import 'package:device_info_plus/device_info_plus.dart';

// --- Color Constants (Kept the same) ---
const Color _primaryGreen = Color(0xFF00C853);
const Color _darkText = Color(0xFF212121);
const Color _noteText = Color(0xFF1E88E5);
const Color _inputBorderColor = Color(0xFFE0E0E0);

class RegistrationStep2Screen extends StatefulWidget {
  const RegistrationStep2Screen({super.key});

  @override
  State<RegistrationStep2Screen> createState() =>
      _RegistrationStep2ScreenState();
}

class _RegistrationStep2ScreenState extends State<RegistrationStep2Screen> {
  // --- Controllers (Kept the same) ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController spotsController = TextEditingController();
  final TextEditingController opentimeController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();
  final TextEditingController descripController = TextEditingController();
  final TextEditingController closetimeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // --- Image & State Variables (Kept the same) ---
  XFile? _pickedImage;
  String? _parkingImageUrl;
  bool _isUploading = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    spotsController.dispose();
    opentimeController.dispose();
    latController.dispose();
    longController.dispose();
    descripController.dispose();
    closetimeController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // Helper for showing snackbars (Kept the same)
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // -------------------------------------------------------------------
  // --- 0. DYNAMIC PERMISSION HANDLING (NEW) ---
  // -------------------------------------------------------------------

  /// Requests the appropriate storage/media permission based on the platform and Android SDK version.
  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) return true; // Permissions not applicable to web

    if (Platform.isIOS) {
      // On iOS, request the photos permission
      final status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        _showSnackBar('Photo access denied. Please enable in Settings.');
        await openAppSettings();
      }
      return status.isGranted;
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Use granular media permissions for Android 13 (API 33) and above
      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        if (status.isPermanentlyDenied) {
          _showSnackBar('Media access denied. Please enable in Settings.');
          await openAppSettings();
        }
        return status.isGranted;
      } else {
        // Use the storage permission for Android 12 (API 32) and lower
        final status = await Permission.storage.request();
        if (status.isPermanentlyDenied) {
          _showSnackBar('Storage access denied. Please enable in Settings.');
          await openAppSettings();
        }
        return status.isGranted;
      }
    }

    return true; // Default to true for unknown platforms
  }

  // -------------------------------------------------------------------
  // --- 1. LOCATION FETCHING (Integration) ---
  // -------------------------------------------------------------------
  Future<void> _getCurrentLocation() async {
    // Location permission check is already handled by Geolocator,
    // but we ensure service is enabled first.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions denied.');
        return;
      }
    }

    try {
      _showSnackBar('Fetching location...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      latController.text = position.latitude.toString();
      longController.text = position.longitude.toString();

      _showSnackBar('Location fetched successfully!');
    } catch (e) {
      debugPrint('Error getting location: $e');
      _showSnackBar('Failed to get location. Please enter manually.');
    }
  }

  // -------------------------------------------------------------------
  // --- 2. IMAGE PICKING (Integration) ---
  // -------------------------------------------------------------------
  Future<void> _pickImage() async {
    // 🔑 NEW: Check for Storage/Media Permission first
    if (!await _requestStoragePermission()) {
      _showSnackBar('Permission to access photos denied.');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      _showSnackBar('Image selected: ${image.name}');
    } else {
      _showSnackBar('No image selected.');
    }
  }

  // -------------------------------------------------------------------
  // --- 3. IMAGE UPLOAD (Kept the same) ---
  // -------------------------------------------------------------------
  Future<String?> _uploadImageToSupabase(XFile imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final fileExtension = imageFile.name.split('.').last;
      final fileName =
          'parking_${DateTime.now().microsecondsSinceEpoch}.$fileExtension';
      final imagePath = 'public/$fileName';

      final String mimeType = 'image/$fileExtension';

      if (kIsWeb) {
        // 1. Read bytes for Web upload
        final Uint8List data = await imageFile.readAsBytes();

        await supabase.storage
            .from('parking-images')
            .uploadBinary(
              imagePath,
              data,
              fileOptions: FileOptions(
                contentType: mimeType,
                cacheControl: '3600',
              ),
            );
      } else {
        // 2. Use File object for Mobile upload
        final File file = File(imageFile.path);

        await supabase.storage
            .from('parking-images')
            .upload(
              imagePath,
              file,
              fileOptions: FileOptions(
                contentType: mimeType,
                cacheControl: '3600',
              ),
            );
      }

      final publicUrl = supabase.storage
          .from('parking-images')
          .getPublicUrl(imagePath);

      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error: ${e.message}');
      _showSnackBar('Image Upload Failed: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Upload Failed: $e');
      _showSnackBar('Image Upload Failed: An unexpected error occurred.');
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // -------------------------------------------------------------------
  // --- 4. SIGNUP / DATA INSERT (Kept the same) ---
  // -------------------------------------------------------------------
  void _signUp() async {
    // ... (Validation checks remain the same) ...
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        latController.text.isEmpty ||
        longController.text.isEmpty ||
        addressController.text.isEmpty) {
      _showSnackBar('Please fill in all required fields.');
      return;
    }

    // --- Step A: Upload Image (if one was picked) ---
    if (_pickedImage != null) {
      final url = await _uploadImageToSupabase(_pickedImage!);
      if (url == null) {
        _showSnackBar('Image upload failed. Registration aborted.');
        return;
      }
      _parkingImageUrl = url;
    } else {
      _showSnackBar('Skipping image upload (no image selected).');
    }

    // --- Step B: Insert Data into Database ---
    try {
      final double? pricePerHour = double.tryParse(priceController.text);
      final int? totalSpots = int.tryParse(spotsController.text);
      final double? latitude = double.tryParse(latController.text);
      final double? longitude = double.tryParse(longController.text);

      if (pricePerHour == null ||
          totalSpots == null ||
          latitude == null ||
          longitude == null) {
        _showSnackBar(
          'Invalid number format for Price, Spots, Latitude, or Longitude.',
        );
        return;
      }

      await supabase.from('nearByParking').insert({
        'name': nameController.text,
        'price_per_hour': pricePerHour,
        'spots': totalSpots,
        'lat': latitude,
        'lang': longitude,
        'openTime': opentimeController.text,
        'closeTime': closetimeController.text,
        'descrip': descripController.text,
        'adress': addressController.text,
        'image': _parkingImageUrl,
        'checkout': false,
      });

      // Navigate to the dashboard after successful registration
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParkingDashboard()),
        );
      }
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException: ${e.message}');
      _showSnackBar('Database Error: ${e.message}');
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      _showSnackBar('An unexpected error occurred. Please try again.');
    }
  }

  // -------------------------------------------------------------------
  // --- 5. BUILD METHOD (UI) (Kept the same) ---
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 400.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth > maxContentWidth ? maxContentWidth : screenWidth,
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: <Widget>[
              // ... (Header and Progress Bar) ...
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Center(
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade600,
                          Colors.blueAccent.shade700,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ),
              ),
              const Text(
                'Register as Operator',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step 2 of 2: Parking Area Details',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => Container(
                    width: 150,
                    height: 5.0,
                    margin: EdgeInsets.only(right: index == 0 ? 10 : 0),
                    decoration: BoxDecoration(
                      color: _primaryGreen,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- Image Upload Section ---
              const Text(
                'Parking Area Image (Required)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _pickedImage != null
                          ? _primaryGreen
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _pickedImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to select image',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : Image.file(
                            // Note: This only works on mobile/desktop, not web
                            File(_pickedImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.error_outline,
                                  size: 40,
                                  color: Colors.red,
                                ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- Parking Details Fields ---
              _buildInputField(
                controller: nameController,
                label: "Parking Area Name",
                hint: "eg Central Mall Parking",
                keyboardType: TextInputType.name,
              ),

              _buildInputField(
                controller: addressController,
                label: "Parking Area Address",
                hint: "Full Address",
                keyboardType: TextInputType.streetAddress,
              ),

              // Button to fetch location
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('Get Current Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _noteText,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Latitude and Longitude fields
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: latController,
                      label: "Latitude",
                      hint: "e.g., 34.0522",
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: longController,
                      label: "Longitude",
                      hint: "e.g., -118.2437",
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),

              // Price and Spots Row
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: priceController,
                      label: "Price per Hour (\$)",
                      hint: "e.g., 5.00",
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: spotsController,
                      label: "Total Spots",
                      hint: "e.g., 150",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              // Open and Close Time Row
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: opentimeController,
                      label: "Open Time",
                      hint: "e.g., 08:00",
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: closetimeController,
                      label: "Close Time",
                      hint: "e.g., 22:00",
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                ],
              ),

              // Description Field
              _buildInputField(
                controller: descripController,
                label: "Description (Optional)",
                hint: "Enter any special instructions or features.",
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),

              // 5. Complete Registration Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.green, Colors.blueAccent.shade700],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Complete Registration',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable Input Field Widget (Kept the same) ---

Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required TextInputType keyboardType,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: _darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14.0,
              horizontal: 10.0,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: _inputBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: _inputBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: _primaryGreen, width: 2.0),
            ),
          ),
        ),
      ],
    ),
  );
}
