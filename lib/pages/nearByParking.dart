import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartparking/models/users/bookingService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // Required for File on Mobile

// Placeholder for your actual model structure
// You MUST ensure your NearByParking model handles nulls safely!
class NearByParking {
  final int? id;
  final String name;
  final double? distance; // Used for walk time/distance
  final double? pricePerHour;
  final int? spots; // Used for available slots
  final double? lat;
  final double? lng;
  final String? address;
  final String? openTime;
  final String? closeTime;
  final String? descrip;
  final String? image;

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

  // ⚠️ CRITICAL: Ensure this handles nulls (e.g., spots, distance) safely.
  factory NearByParking.fromJson(Map<String, dynamic> json) {
    return NearByParking(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Untitled Parking',
      // Safe conversion from num (int/double) to double, defaulting to 0.0
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,
      spots: json['spots'] as int? ?? 0,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lang'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      descrip: json['descrip'] as String?,
      image: json['image_url'] as String?,
    );
  }
}

// // --- UTILITY FUNCTION: LAUNCH MAPS ---
// Future<void> _launchMap(
//   BuildContext context,
//   double lat,
//   double lng,
//   String name,
// ) async {
//   final String encodedName = Uri.encodeComponent(name);
//   final geoUrl = 'geo:$lat,$lng?q=$lat,$lng($encodedName)';
//   final geoUri = Uri.parse(geoUrl);
//   final googleMapsUrl = 'https://maps.google.com/?q=$encodedName@$lat,$lng';
//   final googleMapsUri = Uri.parse(googleMapsUrl);

//   try {
//     if (await launchUrl(geoUri, mode: LaunchMode.externalApplication)) {
//       return;
//     } else if (await launchUrl(
//       googleMapsUri,
//       mode: LaunchMode.externalApplication,
//     )) {
//       return;
//     } else {
//       throw Exception('Could not launch any map application.');
//     }
//   } catch (e) {
//     debugPrint('Map launch failed: $e');
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Could not open maps. Please check device settings."),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }

// --- MAIN SCREEN WIDGET ---
class NearbyParkingScreen extends StatelessWidget {
  const NearbyParkingScreen({super.key});

  Future<List<NearByParking>> _fetchNearByParking() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.from('nearByParking').select('*');
      if (response.isEmpty) {
        return [];
      }
      final parkingList = List<NearByParking>.from(
        response.map((map) => NearByParking.fromJson(map)),
      );
      return parkingList;
    } catch (e) {
      debugPrint('Error fetching parking data: $e');
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

                  // 2. Page Header (Green Icon + Title)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00C853),
                              Color(0xFF0D47A1),
                            ], // Adjusted gradient
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

                  // Location Summary (e.g., "Showing 4 parking areas near you")
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 3. FutureBuilder for Horizontal List
            SizedBox(
              height: 579, // Give the horizontal list a fixed height
              child: FutureBuilder<List<NearByParking>>(
                future: _fetchNearByParking(),
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

                  // --- Data Loaded State (Horizontal Parking List) ---
                  final parkingData = snapshot.data!;
                  return ListView.builder(
                    itemCount: parkingData.length,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemBuilder: (context, index) {
                      final parking = parkingData[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == parkingData.length - 1 ? 0 : 16.0,
                        ),
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

  // Extracted Empty/Error State Builder (adjusted for horizontal center)
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

Future<void> _launchMap(
  BuildContext context,
  double lat,
  double lng,
  String name,
) async {
  // Use a standard Google Maps query URL
  // The 'daddr' parameter is used for the destination coordinates and name.
  final String encodedName = Uri.encodeComponent(name);
  final mapsUrl = 'http://maps.google.com/?daddr=$lat,$lng($encodedName)';
  final mapsUri = Uri.parse(mapsUrl);

  try {
    // Launch using externalApplication mode to open the native Maps app
    if (await launchUrl(mapsUri, mode: LaunchMode.externalApplication)) {
      return;
    } else {
      throw Exception('Could not launch Google Maps.');
    }
  } catch (e) {
    debugPrint('Map launch failed: $e');
    // Provide user feedback on failure
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open Google Maps."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// --- WIDGET: Parking List Card (FINAL VERSION) ---
// --- WIDGET: Parking List Card (FINAL VERSION) ---
class _ParkingCard extends StatelessWidget {
  final NearByParking parking;

  const _ParkingCard({required this.parking});

  @override
  Widget build(BuildContext context) {
    // Safely retrieve data using null-aware operators (??)
    final String parkingName = parking.name;
    final String priceText =
        '₹${(parking.pricePerHour ?? 0.0).toStringAsFixed(0)}';
    final String openTime = parking.openTime ?? 'N/A';
    final String closeTime = parking.closeTime ?? 'N/A';

    final String slotsText = '${parking.spots ?? 0} slots';

    // Coordinates for the map button
    final double safeLat = parking.lat ?? 0.0;
    final double safeLng = parking.lng ?? 0.0;

    // Data needed for booking
    final int parkingId = parking.id ?? 0;
    final double currentRate =
        parking.pricePerHour ?? 0.0; // Correctly pull rate

    return Container(
      width: 250, // Fixed width for horizontal card
      // Height is no longer fixed, allowing it to adapt to the two buttons
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
          // Top Image/Placeholder Area
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.local_parking,
                size: 60,
                color: Colors.blueAccent,
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

                // Row 1: Price and Slots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailIcon(
                      icon: Icons.location_on_outlined,
                      label: priceText,
                      subLabel: 'Per Hour',
                    ),
                    _buildDetailIcon(
                      icon: Icons.person_pin_circle_outlined,
                      label: slotsText,
                      subLabel: 'Available',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailIcon(
                      icon: Icons.alarm,
                      label: openTime,
                      subLabel: "Open Time",
                    ),
                    _buildDetailIcon(
                      icon: Icons.alarm,
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

                const SizedBox(height: 10), // Separator for buttons
                // 🌟 NEW BUTTON: Book Now
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // Use a primary color for the book button
                    color: Colors.green.shade600,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // ➡️ CORRECTED CALL: Using the private function name
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

// Helper widget for displaying price/slots details (UNMODIFIED)
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

// --- NEW/UPDATED UTILITY FUNCTIONS (Place these in the main screen file) ---

// This function launches the BookingForm as a modal bottom sheet.
// NOTE: It is still private (starts with _) but is now calling the widget/service
// functions which were moved to the bookingService.dart file.
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
