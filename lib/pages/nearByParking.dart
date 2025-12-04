import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartparking/models/users/nearByParking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart'; // <--- NEW IMPORT

class NearbyParkingScreen extends StatelessWidget {
  const NearbyParkingScreen({super.key});

  Future<List<NearByParking>> _fetchNearByParking() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('nearByParking').select('*');
      debugPrint(response.first.toString());

      if (response == null || response.isEmpty) {
        return [];
      }

      final parkingList = List<NearByParking>.from(
        response.map(
          (map) => NearByParking.fromJson(map as Map<String, dynamic>),
        ),
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
        // Use SafeArea for padding from notch/status bar
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                        colors: [Colors.blue, Colors.green],
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

              // 3. FutureBuilder for Data Handling
              Expanded(
                // FIX 1: Wrap the FutureBuilder in Expanded
                child: FutureBuilder<List<NearByParking>>(
                  future: _fetchNearByParking(), // Use the new private method
                  builder: (context, snapshot) {
                    // --- Loading State ---
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // --- Error State (or Empty Data, which is treated similarly here) ---
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return _buildEmptyState(
                        context,
                      ); // FIX 2: Check for error/no data first
                    }

                    // --- Data Loaded State (Parking List) ---
                    final parkingData = snapshot.data!;
                    return ListView.builder(
                      itemCount: parkingData.length,
                      itemBuilder: (context, index) {
                        final parking = parkingData[index];
                        return _ParkingCard(parking: parking);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Extracted Empty/Error State Builder
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Parking Areas Nearby",
            style: GoogleFonts.alexandria(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching manually or explore other areas",
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ... (NearbyParkingScreen remains the same, except it now uses the updated _ParkingCard)

// --- UPDATED WIDGET: Custom Parking List Card ---
class _ParkingCard extends StatelessWidget {
  final NearByParking parking;

  const _ParkingCard({required this.parking});

  // Function to build and launch the map URL
  // Function to build and launch the map URL
  Future<void> _launchMap(double lat, double lng, String name) async {
    // Use a common query format that works on most devices

    // URL to pin the location with a label
    final mapUrl = 'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(name)})';

    final uri = Uri.parse(mapUrl);

    // Use launchUrl with LaunchMode.externalApplication to open the default app
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: If the geo scheme fails, try the generic Google Maps URL
      final googleMapsFallbackUrl =
          'http://maps.google.com/?q=${Uri.encodeComponent(name)}@$lat,$lng';
      final fallbackUri = Uri.parse(googleMapsFallbackUrl);

      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else {
        // Final failure state
        debugPrint('Could not launch map for coordinates: $lat, $lng');
        // In a real app, show a SnackBar or AlertDialog here:
        // ScaffoldMessenger.of(context).showSnackBar(...);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  parking.name,
                  style: GoogleFonts.alexandria(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '₹${parking.pricePerHour.toStringAsFixed(0)}/hr',
                  style: GoogleFonts.alexandria(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.pin_drop, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '${parking.area} | ',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const Icon(Icons.directions_walk, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  '${parking.distance.toStringAsFixed(1)} km',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Available Spots: ${parking.availableSpots}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            // --- NEW: Action Buttons Row ---
            Row(
              children: [
                // Button 1: Open Map (NEW FEATURE)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _launchMap(parking.lat, parking.lang, parking.name),
                    icon: const Icon(Icons.map_outlined, size: 20),
                    label: const Text('View on Map'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade600,
                      side: BorderSide(color: Colors.blue.shade600),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Button 2: Book Now
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to booking screen, passing the parking ID
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
