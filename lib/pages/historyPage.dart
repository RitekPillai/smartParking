import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- 1. User's Data Model (Updated for Supabase JSON parsing) ---
class Booking {
  final int id;
  final int parkingId;
  final String userId;
  final String? userName;
  final String numberPlate;
  final DateTime startTime;
  final DateTime endTime;
  final double? durationHours;
  final double? pricePerHour;
  final double? totalAmount;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.parkingId,
    required this.userId,
    this.userName,
    required this.numberPlate,
    required this.startTime,
    required this.endTime,
    this.durationHours,
    this.pricePerHour,
    this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  // Factory method to create a Booking instance from Supabase response (JSON Map)
  factory Booking.fromJson(Map<String, dynamic> json) {
    // Use .toInt() or .toDouble() on 'num' to safely handle database numbers
    return Booking(
      id: (json['id'] as num).toInt(),
      parkingId: (json['parking_id'] as num).toInt(),
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      numberPlate: json['number_plate'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      durationHours: (json['duration_hours'] as num?)?.toDouble(),
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // The toJson method you provided (kept for completeness, though not strictly used here)
  Map<String, dynamic> toJson() {
    return {
      'parking_id': parkingId,
      'user_id': userId,
      'user_name': userName,
      'number_plate': numberPlate,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'duration_hours': durationHours,
      'price_per_hour': pricePerHour,
      'total_amount': totalAmount,
      'status': status,
    };
  }
}

// --- 2. Main Screen Widget ---
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  // Use the user's Booking model
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookingHistory();
  }

  // --- Supabase Fetching Logic ---
  Future<void> _fetchBookingHistory() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        _errorMessage = "You must be logged in to view history.";
        _isLoading = false;
      });
      return;
    }

    try {
      // Query Fix: Filtering methods (.eq, .gt) must be chained BEFORE
      // transforming methods (.order) to avoid 'The method 'gt' isn't defined' error.
      final List<dynamic> response = await supabase
          .from('bookings') // Using the user's 'bookings' table
          .select()
          .eq('user_id', user.id) // Filter 1: Match User ID
          .gt(
            // Filter 2: Match created_at greater than 30 days ago
            'created_at',
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          )
          .order('start_time', ascending: false); // Finally, order the results

      if (mounted) {
        setState(() {
          // Map response using the updated Booking.fromJson factory
          _bookings = response.map((json) => Booking.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } on PostgrestException catch (e) {
      debugPrint('Postgres Error fetching history: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              'Database Error: ${e.message}. Check your RLS policies.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('General Error fetching history: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: $e';
          _isLoading = false;
        });
      }
    }
  }

  // --- 3. UI Construction ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 24),
                Text(
                  "Booking History",
                  style: GoogleFonts.alexandria(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Your parking records from the last 30 days",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Content Area (Loading, Error, Empty, or List)
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_bookings.isEmpty) {
      // Show the beautiful empty state card
      return _buildEmptyStateCard();
    }

    // Display the list of bookings
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        return _AnimatedHistoryCard(booking: _bookings[index], index: index);
      },
    );
  }

  // Uses the design from the original placeholder
  Widget _buildEmptyStateCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 60, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 24),
            Text(
              "No Booking History Yet",
              style: GoogleFonts.alexandria(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your parking bookings will appear here once you make your first reservation",
              textAlign: TextAlign.center,
              style: GoogleFonts.alexandria(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildPrimaryButton(
              text: "Find Parking Now",
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable button style matching the app's gradient theme
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF0D47A1), // Darker Blue
            Colors.green.shade400,
          ], // Blue to Green gradient
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SizedBox(
        height: 45,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            text,
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// --- 4. Animated History Card Widget ---
class _AnimatedHistoryCard extends StatelessWidget {
  final Booking booking; // Using the user's Booking model
  final int index;

  const _AnimatedHistoryCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context) {
    // Staggered animation: delay is proportional to the index
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 100),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              bottom: 8.0,
              left: (1 - opacity) * 50, // Slide from left
            ),
            child: child,
          ),
        );
      },
      child: _BookingHistoryCard(booking: booking),
    );
  }
}

// --- 5. Individual Booking Card UI ---
class _BookingHistoryCard extends StatelessWidget {
  final Booking booking; // Using the user's Booking model

  const _BookingHistoryCard({required this.booking});

  // Helper to determine icon and color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade500;
      case 'active':
        return Colors.amber.shade700;
      case 'cancelled':
        return Colors.red.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'active':
        return Icons.access_time_filled;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(booking.status);

    // Format duration and cost strings
    final durationText = booking.durationHours != null
        ? '${booking.durationHours!.toStringAsFixed(1)} hrs'
        : 'N/A';
    final costText = booking.totalAmount != null
        ? '₹${booking.totalAmount!.toStringAsFixed(2)}'
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Parking ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Parking ID (used as main identifier since spotName is missing)
              Flexible(
                child: Text(
                  'Parking ID: ${booking.parkingId}',
                  style: GoogleFonts.alexandria(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(booking.status),
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.status.toUpperCase(),
                      style: GoogleFonts.alexandria(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 20, thickness: 1, color: Color(0xFFF8F9FE)),

          // Row 2: Details Grid (Time, Vehicle, Cost)
          IntrinsicHeight(
            child: Row(
              children: [
                _buildDetailItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Booked Date',
                  value: DateFormat('MMM dd, yyyy').format(booking.startTime),
                ),
                const VerticalDivider(thickness: 1, color: Color(0xFFF8F9FE)),
                _buildDetailItem(
                  icon: Icons.access_time,
                  label: 'Duration',
                  value: durationText,
                ),
                const VerticalDivider(thickness: 1, color: Color(0xFFF8F9FE)),
                _buildDetailItem(
                  icon: Icons.payments_outlined,
                  label: 'Total Paid',
                  value: costText,
                  valueColor: Colors.green.shade700,
                ),
              ],
            ),
          ),

          const Divider(height: 20, thickness: 1, color: Color(0xFFF8F9FE)),

          // Row 3: Vehicle Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_car_filled_outlined,
                      size: 20,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Vehicle: ",
                      style: GoogleFonts.alexandria(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  booking.numberPlate,
                  style: GoogleFonts.alexandria(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.alexandria(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.alexandria(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
