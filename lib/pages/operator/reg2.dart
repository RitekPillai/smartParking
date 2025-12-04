import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:smartparking/pages/operator/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart'; // NEW: Image Picker
import 'dart:io'; // NEW: File operations
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for kIsWeb
import 'dart:io'; // Needed for File, but only used on Mobile
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ... other imports

// --- Color Constants ---
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
  // --- Controllers ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController spotsController = TextEditingController();
  final TextEditingController opentimeController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();
  final TextEditingController descripController = TextEditingController();
  final TextEditingController closetimeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // --- Image & State Variables ---
  XFile? _pickedImage;
  String? _parkingImageUrl;
  bool _isUploading = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    // ... dispose all controllers ...
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

  // Helper for showing snackbars
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // -------------------------------------------------------------------
  // --- 1. LOCATION FETCHING ---
  // -------------------------------------------------------------------
  Future<void> _getCurrentLocation() async {
    // ... (Location fetching logic remains the same) ...
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
  // --- 2. IMAGE PICKING ---
  // -------------------------------------------------------------------
  Future<void> _pickImage() async {
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
  // --- 3. IMAGE UPLOAD ---
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

      // --- 🔑 FIX: Use conditional logic for type safety ---

      if (kIsWeb) {
        // 1. Read bytes for Web upload
        final Uint8List data = await imageFile.readAsBytes();

        await supabase.storage
            .from('parking-images')
            .uploadBinary(
              // Use uploadBinary for Uint8List on Web
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
              // Use upload for File on Mobile
              imagePath,
              file,
              fileOptions: FileOptions(
                contentType: mimeType,
                cacheControl: '3600',
              ),
            );
      }

      // -----------------------------------------------------

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
  // --- 4. SIGNUP / DATA INSERT ---
  // -------------------------------------------------------------------
  void _signUp() async {
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
        // Stop the sign up if upload failed
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
        'image': _parkingImageUrl, // NEW: Insert the image URL
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
  // --- 5. BUILD METHOD (UI) ---
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
              // ... (Header and Progress Bar remain the same) ...
              const SizedBox(height: 50),
              // Icon and Header
              // ... (Code for icon, Register as Operator, Step 2 of 2) ...
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
              // Progress bars
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

              // --- Image Upload Section (NEW) ---
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
                    onPressed: _isUploading
                        ? null
                        : _signUp, // Disable button while uploading
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
