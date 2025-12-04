import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// --- Time Formatting Helper Function (FIXED for ISO 8601 Timestamp) ---
String _formatTime(String rawTime) {
  try {
    if (rawTime.toUpperCase() == 'N/A' || rawTime.isEmpty) {
      return 'N/A';
    }

    // ⭐️ FIX: Use DateTime.parse() for the complex ISO 8601 string.
    final dateTime = DateTime.parse(rawTime);

    // Convert to local time zone for display purposes
    final localTime = dateTime.toLocal();

    // Define the output format (e.g., 9:38 AM)
    return DateFormat('h:mm a').format(localTime);
  } catch (e) {
    debugPrint('Time formatting error: Could not parse $rawTime. Error: $e');
    return rawTime;
  }
}

// --- Data Type Conversion Helper for Robustness ---
String _safeString(dynamic value, [String defaultValue = 'N/A']) {
  if (value == null) return defaultValue;
  if (value is String) return value;
  return value.toString();
}

// --- 1. Data Model ---
class ActiveUser {
  final String name;
  final String vehicleNumber;
  final String entryTime;
  final String endTime;
  final String duration;
  final String isActive;

  ActiveUser({
    required this.name,
    required this.vehicleNumber,
    required this.entryTime,
    required this.endTime,
    required this.duration,
    required this.isActive,
  });

  factory ActiveUser.fromJson(Map<String, dynamic> json) {
    return ActiveUser(
      name: _safeString(json['user_name']),
      vehicleNumber: _safeString(json['number_plate']),
      entryTime: _safeString(json['start_time']),
      endTime: _safeString(json['end_time']),
      duration: _safeString(json['duration_hours']),
      isActive: _safeString(json['status']),
    );
  }
}

// --- 2. Main Widget Setup (The Active Users Screen) ---
class Activeuser extends StatefulWidget {
  const Activeuser({super.key});

  @override
  State<Activeuser> createState() => _ActiveuserState();
}

class _ActiveuserState extends State<Activeuser> {
  late Future<List<ActiveUser>> _activeUsersFuture;

  @override
  void initState() {
    super.initState();
    _activeUsersFuture = getActiveUser();
  }

  // --- 3. Supabase Fetch Function (No change needed) ---
  Future<List<ActiveUser>> getActiveUser() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('bookings')
          .select(
            'user_name, number_plate, start_time, end_time, duration_hours, status',
          );

      final parkingList = List<ActiveUser>.from(
        response.map((map) => ActiveUser.fromJson(map)),
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
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Custom Header ---
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.group, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 20),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Active Users",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Currently Booked Vehicles",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 4. FutureBuilder for Dynamic Content ---
          Expanded(
            child: FutureBuilder<List<ActiveUser>>(
              future: _activeUsersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading data: ${snapshot.error}'),
                  );
                }

                final List<ActiveUser> activeUsers = snapshot.data ?? [];

                if (activeUsers.isEmpty) {
                  return const Center(
                    child: Text('No active users currently.'),
                  );
                }

                return ListView.builder(
                  itemCount: activeUsers.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  itemBuilder: (context, index) {
                    final user = activeUsers[index];

                    // ⭐️ Applying time formatting using the helper function
                    final formattedEntryTime = _formatTime(user.entryTime);
                    final formattedEndTime = _formatTime(user.endTime);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: ActiveUserTile(
                        user.name,
                        user.vehicleNumber,
                        formattedEntryTime,
                        formattedEndTime,
                        user.duration,
                        user.isActive,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- Custom Tile Widgets (No change needed) ---
// -----------------------------------------------------------------------------

Widget ActiveUserTile(
  String name,
  String plate,
  String entrytime,
  String endTime,
  String duration,
  String status,
) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Status Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Active'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Active'
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Vehicle Plate Number
          Row(
            children: [
              const Icon(
                Icons.directions_car_filled,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                plate,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Time Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: TimeTile("Entry Time", entrytime)),
              Expanded(child: TimeTile("End Time", endTime)),
              Expanded(
                child: TimeTile(
                  "Duration",
                  "$duration hours",
                  isDuration: true,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget TimeTile(String title, String descripp, {bool isDuration = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      const SizedBox(height: 4),
      Text(
        descripp,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDuration ? Colors.blue.shade700 : Colors.black,
        ),
      ),
    ],
  );
}
