import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Assuming BookingForm is defined in bookingService.dart
import 'package:smartparking/models/users/bookingService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// --- DATA MODEL ---
class NearByParking {
  final int? id;
  final String name;
  final double? distance;
  final double? pricePerHour; // Fetched from 'price_per_hour'
  final int? spots;
  final double? lat;
  final double? lng;
  final String? address;
  final String? openTime;
  final String? closeTime;
  final String? descrip;
  final String? image; // Mapped from 'image_url'

  NearByParking({
    this.id,
    required this.name,
    this.distance,
    this.pricePerHour,
    this.spots,
    this.lat,
    this.lng,
    this.address,
    this.openTime,
    this.closeTime,
    this.descrip,
    this.image,
  });

  factory NearByParking.fromJson(Map<String, dynamic> json) {
    return NearByParking(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Untitled Parking',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,
      spots: json['spots'] as int? ?? 0,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lang'] as num?)?.toDouble() ?? 0.0,
      address: json['adress'] as String?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      descrip: json['descrip'] as String?,
      image: json['image_url'] as String?, // Must match column name in Supabase
    );
  }
}

// You need to have 'package:url_launcher/url_launcher.dart' imported!

Future<void> _launchMap(
  BuildContext context,
  double lat,
  double lng,
  String name,
) async {
  final String encodedName = Uri.encodeComponent(name);

  // 1. Google Maps Native App Scheme (Most reliable for direction/search)
  // Use the 'comgooglemaps://' scheme. If the app is installed, this is usually preferred.
  // The 'daddr' parameter is for the destination address/coordinates.
  final String googleMapScheme =
      'comgooglemaps://?q=$lat,$lng&label=$encodedName&directionsmode=driving';

  final Uri googleMapUri = Uri.parse(googleMapScheme);

  // 2. Universal HTTPS Fallback (Works on web and forces app/browser if native scheme fails)
  final String universalHttpsUrl =
      'http://maps.google.com/maps?q=$lat,$lng&label=$encodedName';

  final Uri universalHttpsUri = Uri.parse(universalHttpsUrl);

  try {
    // Attempt 1: Launch the native Google Maps app using its scheme
    if (await canLaunchUrl(googleMapUri)) {
      await launchUrl(googleMapUri, mode: LaunchMode.externalApplication);
      return;
    }
    // Attempt 2: Fallback to the universal HTTPS URL (opens browser or prompts app choice)
    else if (await canLaunchUrl(universalHttpsUri)) {
      await launchUrl(universalHttpsUri, mode: LaunchMode.externalApplication);
      return;
    }
    // Final failure
    else {
      throw Exception('No URL handler found for map links.');
    }
  } catch (e) {
    debugPrint('Map launch failed: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Could not open maps. Check your app configuration (Info.plist/AndroidManifest).",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// --- MAIN SCREEN WIDGET ---
class NearbyParkingScreen extends StatelessWidget {
  const NearbyParkingScreen({super.key});

  Future<List<NearByParking>> _fetchAvailableNearByParking() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('nearByParking')
          .select('*, image_url') // Select all columns including the new one
          .eq('checkout', false);

      if (response.isEmpty) {
        return [];
      }

      final parkingList = List<NearByParking>.from(
        response.map((map) => NearByParking.fromJson(map)),
      );

      return parkingList;
    } catch (e) {
      debugPrint('Error fetching available parking data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. "Back to Home" Link
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back, size: 18, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "Back to Home",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 2. Page Header (Icon + Title)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF0D47A1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C853).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.near_me,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nearby Parking",
                            style: GoogleFonts.alexandria(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Parking areas closest to your location",
                            style: GoogleFonts.alexandria(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 3. FutureBuilder for Vertical List
            Expanded(
              child: FutureBuilder<List<NearByParking>>(
                future: _fetchAvailableNearByParking(),
                builder: (context, snapshot) {
                  // --- Loading State ---
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // --- Error/Empty State ---
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  // --- Data Loaded State (Vertical Parking List) ---
                  final parkingData = snapshot.data!;
                  return ListView.builder(
                    itemCount: parkingData.length,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemBuilder: (context, index) {
                      final parking = parkingData[index];
                      return Padding(
                        // Vertical padding for card separation
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: _ParkingCard(parking: parking),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Extracted Empty/Error State Builder
  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 40, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No Parking Areas Nearby",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET: Parking List Card (Interactive with Hero Animation) ---
class _ParkingCard extends StatelessWidget {
  final NearByParking parking;

  const _ParkingCard({required this.parking});

  // Function to show details in a modal
  void _showParkingDetails(BuildContext context, NearByParking parking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // Uses the new detail modal widget
        return _ParkingDetailModal(parking: parking);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String parkingName = parking.name;
    final String priceText =
        '₹${(parking.pricePerHour ?? 0.0).toStringAsFixed(0)}';
    final String openTime = parking.openTime ?? 'N/A';
    final String closeTime = parking.closeTime ?? 'N/A';
    final String slotsText = '${parking.spots ?? 0} slots';
    final String? imageUrl = parking.image;

    final String address = parking.address ?? 'No address provided';

    final double safeLat = parking.lat ?? 0.0;
    final double safeLng = parking.lng ?? 0.0;

    final int parkingId = parking.id ?? 0;
    final double currentRate = parking.pricePerHour ?? 0.0; // Fetched Price

    // Unique tag for Hero animation
    final String heroTag = 'parking-image-${parking.id}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image wrapped in GestureDetector and Hero
          GestureDetector(
            onTap: () => _showParkingDetails(context, parking),
            child: Hero(
              tag: heroTag, // Hero tag added here
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.local_parking,
                            size: 60,
                            color: Colors.blueAccent,
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parkingName,
                  style: GoogleFonts.alexandria(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Price and Slots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailIcon(
                      icon: Icons.attach_money,
                      label: priceText,
                      subLabel: 'Per Hour',
                    ),
                    _buildDetailIcon(
                      icon: Icons.directions_car,
                      label: slotsText,
                      subLabel: 'Available',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Open and Close Times
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailIcon(
                      icon: Icons.schedule,
                      label: openTime,
                      subLabel: "Open Time",
                    ),
                    _buildDetailIcon(
                      icon: Icons.schedule,
                      label: closeTime,
                      subLabel: "Close Time",
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Button 1: Open in Google Maps
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                    ),
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.map_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Open in Google Maps',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      _launchMap(context, safeLat, safeLng, parkingName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // Button 2: Book Now
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.shade600,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Pass the fetched rate to the booking sheet
                      _showBookingSheet(
                        context: context,
                        parkingName: parkingName,
                        parkingId: parkingId,
                        rate: currentRate,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// Helper widget for displaying price/slots details
Widget _buildDetailIcon({
  required IconData icon,
  required String label,
  required String subLabel,
  Color color = Colors.black87,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Icon(icon, size: 24, color: color),
      const SizedBox(width: 4),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.alexandria(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subLabel,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    ],
  );
}

// --- UTILITY FUNCTION: Show Booking Sheet ---
void _showBookingSheet({
  required BuildContext context,
  required String parkingName,
  required int parkingId,
  required double rate,
}) {
  // BookingForm is now assumed to be imported from 'bookingService.dart'
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        BookingForm(parkingName: parkingName, parkingId: parkingId, rate: rate),
  );
}

// --- NEW WIDGET: Parking Detail Modal (Enhanced UI with Animation) ---
class _ParkingDetailModal extends StatelessWidget {
  final NearByParking parking;

  const _ParkingDetailModal({required this.parking});

  // Helper widget for a styled detail row
  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    Color color = Colors.black,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.alexandria(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.alexandria(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to introduce staggered animation for details
  Widget _buildAnimatedDetailSection(Widget child, int delayMilliseconds) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delayMilliseconds),
      curve: Curves.easeOut,
      builder: (context, opacity, c) {
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: EdgeInsets.only(
              top: (1 - opacity) * 20,
            ), // Slide in effect
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = parking.image;
    final String heroTag = 'parking-image-${parking.id}';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 1.0,
      minChildSize: 0.5,
      expand: true,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FE), // Light background
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              // 1. Hero Animated and Zoomable Image Area
              Hero(
                tag: heroTag, // Link the image back to the main list card
                child: Container(
                  height: 350,
                  decoration: const BoxDecoration(
                    color: Colors.black, // Dark background for zoom
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? InteractiveViewer(
                            // Enables pinch-to-zoom and pan
                            panEnabled: true,
                            boundaryMargin: const EdgeInsets.all(20),
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.white70,
                                    ),
                                  ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.local_parking,
                              size: 80,
                              color: Colors.white70,
                            ),
                          ),
                  ),
                ),
              ),

              // 2. Details Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _buildAnimatedDetailSection(
                      Text(
                        parking.name,
                        style: GoogleFonts.alexandria(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      0,
                    ),
                    const SizedBox(height: 8),

                    // Price Tag
                    _buildAnimatedDetailSection(
                      Chip(
                        label: Text(
                          '₹${(parking.pricePerHour ?? 0.0).toStringAsFixed(2)} / Hour',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      50,
                    ),
                    const SizedBox(height: 20),

                    // Detail Cards with Fade/Slide Animation
                    _buildAnimatedDetailSection(
                      _buildDetailCard(
                        icon: Icons.pin_drop_outlined,
                        label: 'Address',
                        value: parking.address ?? 'No address provided',
                        color: Colors.red.shade400,
                      ),
                      100,
                    ),
                    _buildAnimatedDetailSection(
                      _buildDetailCard(
                        icon: Icons.directions_car_filled,
                        label: 'Available Slots',
                        value: '${parking.spots ?? 0} slots remaining',
                        color: Colors.blue.shade400,
                      ),
                      150,
                    ),
                    _buildAnimatedDetailSection(
                      _buildDetailCard(
                        icon: Icons.access_time,
                        label: 'Operating Hours',
                        value:
                            '${parking.openTime ?? 'N/A'} - ${parking.closeTime ?? 'N/A'}',
                        color: Colors.orange.shade400,
                      ),
                      200,
                    ),

                    const SizedBox(height: 30),

                    // Description Section
                    _buildAnimatedDetailSection(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parking Description',
                            style: GoogleFonts.alexandria(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            parking.descrip ??
                                'No detailed description available.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      250,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
