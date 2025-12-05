import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartparking/pages/helpPage.dart';
import 'package:smartparking/pages/historyPage.dart';
import 'package:smartparking/pages/housetoUser.dart';
import 'package:smartparking/pages/nearByParking.dart';
import 'package:smartparking/pages/profilepage.dart';
import 'package:smartparking/pages/scannerPage.dart';
import 'package:smartparking/pages/subscription.dart';
import 'package:smartparking/pages/userFeedBack.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:text_gradiate/text_gradiate.dart';
import 'dart:async';
import 'package:intl/intl.dart';

// --- APPLICATION BOILERPLATE (Added for runnable code) ---

// Re-using the essential Booking model for consistency
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

  factory Booking.fromJson(Map<String, dynamic> json) {
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
}

class quickActiontitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  const quickActiontitle(
    this.icon,
    this.title,
    this.description,
    this.color,
    this.onTap, {
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: color.withAlpha(150), blurRadius: 10)],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(150),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              // Increased font size slightly
              style: GoogleFonts.alexandria(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: GoogleFonts.alexandria(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MAIN WIDGET ---
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Use Supabase.instance.client for the client instance
  final supabase = Supabase.instance.client;

  Booking? _activeBooking;
  Timer? _timer;
  Duration _remainingTime = const Duration(minutes: 15);
  bool _isCancellationWindowActive = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchActiveBooking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  // --- Data Fetching ---

  Future<void> _fetchUserData() async {
    final String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      final data = await supabase
          .from('users')
          .select("username")
          .eq('id', userId)
          .maybeSingle();

      if (data != null && data.containsKey('username')) {
        setState(() {
          _username = data['username'] as String;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> _fetchActiveBooking() async {
    final String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      // Fetch the most recent booking that is 'confirmed' or 'active'
      final List<dynamic> response = await supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          // Using the reliable .filter() method with the 'in' operator
          .filter('status', 'in', ['confirmed', 'active'])
          .order(
            'start_time',
            ascending: true,
          ) // Oldest confirmed/active booking
          .limit(1);

      if (response.isNotEmpty) {
        final booking = Booking.fromJson(
          response.first as Map<String, dynamic>,
        );
        if (mounted) {
          setState(() {
            _activeBooking = booking;
          });
          _startTimer(booking.startTime);
        }
      }
    } catch (e) {
      debugPrint('Error fetching active booking: $e');
    }
  }

  // --- Timer Logic ---

  void _startTimer(DateTime startTime) {
    _timer?.cancel();

    const gracePeriod = Duration(minutes: 15);
    final graceEndTime = startTime.add(gracePeriod);
    final now = DateTime.now();

    if (now.isAfter(graceEndTime)) {
      // Cancellation window has already expired
      setState(() {
        _remainingTime = Duration.zero;
        _isCancellationWindowActive = false;
      });
      return;
    }

    _remainingTime = graceEndTime.difference(now);
    _isCancellationWindowActive = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          } else {
            _timer?.cancel();
            _isCancellationWindowActive = false;
          }
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // --- Cancellation Logic ---

  Future<void> _cancelBooking(Booking booking) async {
    if (_activeBooking == null) return;

    final creditPoints = _isCancellationWindowActive ? 50 : 0; // Example points
    final refundStatus = _isCancellationWindowActive
        ? "Partial Refund (Credits)"
        : "No Refund";

    // Show confirmation dialog
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Cancellation'),
            content: Text(
              'Are you sure you want to cancel this booking for Parking ID ${booking.parkingId}? \n\nCancellation Status: $refundStatus. You will receive $creditPoints credit points.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      // 1. Update Booking Status to 'cancelled'
      await supabase
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', booking.id);

      // 2. Grant Credit Points (simple implementation, requires 'credits' column in 'users' table)
      if (_isCancellationWindowActive) {
        // NOTE: This assumes you have a Postgres function named 'increment_user_credits'
        // defined in your Supabase project.
        await supabase.rpc(
          'increment_user_credits',
          params: {
            'user_id_input': getCurrentUserId(),
            'credits_to_add': creditPoints,
          },
        );
      }

      // 3. Clear the active booking state and timer
      if (mounted) {
        setState(() {
          _activeBooking = null;
          _timer?.cancel();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking cancelled successfully. $refundStatus applied.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during cancellation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel booking. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- UI Components ---

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Hello, ${_username ?? 'User'}',
            style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildActiveBookingCard() {
    if (_activeBooking == null) {
      // State when no active booking is found
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Ready to Park?",
                style: GoogleFonts.alexandria(
                  fontSize: 24, // Slightly increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Your perfect spot is waiting!",
              style: GoogleFonts.alexandria(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),

            // Replaced search bar with a clear call-to-action button
          ],
        ),
      );
    }

    // State when an active booking exists
    final booking = _activeBooking!;
    final timerText = _formatDuration(_remainingTime);
    final statusColor = _isCancellationWindowActive
        ? Colors.red.shade700
        : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha(200),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Booking: P-ID ${booking.parkingId}',
                  // Slightly increased font size
                  style: GoogleFonts.alexandria(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                Icon(
                  Icons.local_parking_rounded,
                  color: Colors.blue.shade700,
                  size: 30,
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1, color: Colors.grey),

            // Timer and Cancellation Status
            Row(
              children: [
                Icon(Icons.timer, color: statusColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  _isCancellationWindowActive
                      ? 'Cancel in: '
                      : 'Cancellation Window Closed',
                  style: GoogleFonts.alexandria(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                if (_isCancellationWindowActive)
                  Text(
                    timerText,
                    style: GoogleFonts.alexandria(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Booking Details
            _buildDetailRow(
              Icons.access_time,
              'Start Time:',
              DateFormat('hh:mm a').format(booking.startTime),
            ),
            _buildDetailRow(
              Icons.directions_car,
              'Vehicle:',
              booking.numberPlate,
            ),
            _buildDetailRow(
              Icons.money,
              'Cost:',
              '₹${booking.totalAmount?.toStringAsFixed(2) ?? 'N/A'}',
            ),

            const SizedBox(height: 20),

            // Cancel Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _cancelBooking(booking),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.alexandria(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.alexandria(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        actions: [_buildCustomAppBar()],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Area
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Find Your Perfect ",
                          // Increased font size
                          style: GoogleFonts.alexandria(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Center(
                          child: TextGradiate(
                            text: Text(
                              textAlign: TextAlign.center,
                              "Parking Spot",
                              // Increased font size
                              style: GoogleFonts.alexandria(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            colors: [Colors.blue, Colors.green],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Search, book, and park with ease",
                      style: GoogleFonts.alexandria(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Active Booking / Search Placeholder Area
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildActiveBookingCard(),
              ),

              const SizedBox(height: 25),
              Text(
                "Quick Actions",
                style: GoogleFonts.alexandria(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),
              // Quick Actions Grid
              Padding(
                padding: const EdgeInsets.all(8),
                child: GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15.0,
                    crossAxisSpacing: 15.0,
                    childAspectRatio: 0.8,
                  ),
                  children: [
                    quickActiontitle(
                      Icons.qr_code,
                      "Scan Qr Code",
                      "Quick entry by scanning parking QR",
                      Colors.blue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QRCode()),
                        );
                      },
                    ),
                    quickActiontitle(
                      Icons.location_pin,
                      "NearBy Parking",
                      "Find parking areas near you",
                      const Color(0xff00b546),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NearbyParkingScreen(),
                          ),
                        );
                      },
                    ),
                    quickActiontitle(
                      Icons.credit_card,
                      "Subscription Plans",
                      "Save more with monthly plans",
                      const Color(0xffa230fc),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionPage(),
                          ),
                        );
                      },
                    ),
                    quickActiontitle(
                      Icons.history,
                      "Booking History",
                      "View your past bookings",
                      const Color(0xfff95500),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // How It Works Section
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Container(
                  width: double.infinity,
                  // Increased height for better spacing
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          "How it Works",
                          style: GoogleFonts.alexandria(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      howItworksTile(
                        "1",
                        "Search",
                        "Find Parking near your destination",
                        Colors.blue.shade100,
                        Colors.blue,
                      ),
                      howItworksTile(
                        "2",
                        "Select",
                        "Choose duration and pay",
                        Colors.green.shade100,
                        Colors.green,
                      ),
                      howItworksTile(
                        "3",
                        "Park",
                        "Show confirmation",
                        Colors.purple.shade100,
                        Colors.purple,
                      ),
                      howItworksTile(
                        "4",
                        "Enjoy",
                        "Hassle-free parking experience",
                        Colors.orange.shade100,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      // Improved Drawer Menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Themed Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xff00b546),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _username ?? 'Smart Parking User',
                    style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                
                ],
              ),
            ),
            // Updated ListTile styles
            _buildDrawerTile('Home', Icons.home_rounded, () {
              Navigator.pop(context); // Close drawer
            }),
            _buildDrawerTile('Profile', Icons.person_outline_rounded, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            }),
            _buildDrawerTile(
              'Booking History',
              Icons.history_toggle_off_rounded,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingHistoryScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: Colors.grey),
            _buildDrawerTile('How to Use', Icons.menu_book_rounded, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HowToUsePage()),
              );
            }),
            _buildDrawerTile('Help & Support', Icons.support_agent_rounded, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Help()),
              );
            }),
            _buildDrawerTile(
              'Send Feedback',
              Icons.messenger_outline_sharp,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackPage()),
                );
              },
            ),
            const Divider(height: 1, color: Colors.grey),
            // Sign Out action
            _buildDrawerTile('Sign Out', Icons.logout_rounded, () {
              Navigator.pop(context);
              supabase.auth.signOut();
            }, isLogout: true),
          ],
        ),
      ),
    );
  }

  // Helper function for themed Drawer tiles
  Widget _buildDrawerTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icon,
        color: isLogout ? Colors.red.shade600 : Colors.blue.shade700,
      ),
      title: Text(
        title,
        style: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red.shade600 : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

Widget howItworksTile(
  String no,
  String title,
  String description,
  Color background,
  Color text,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(shape: BoxShape.circle, color: background),
          child: Center(
            child: Text(
              no,
              style: TextStyle(
                color: text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.alexandria(
              color: Colors.black,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(description, style: GoogleFonts.alexandria(fontSize: 15)),
        ],
      ),
    ],
  );
}
