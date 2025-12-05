import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartparking/pages/operator/guidStep.dart';
import 'package:smartparking/pages/operator/activeUser.dart';
import 'package:smartparking/pages/operator/qrcode.dart';
import 'package:smartparking/pages/profilePage.dart';
import 'package:smartparking/widgets/quickAction.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// Assuming you have initialized your Supabase client
final supabase = Supabase.instance.client;

Future<void> updateParkingLotAvailability({
  required int parkingLotId,
  required bool isFull,
}) async {
  try {
    final updateData = {
      // 'checkout': true means the spot is being used by the owner/unavailable
      'checkout': isFull,
    };

    await supabase
        .from('nearByParking')
        .update(updateData)
        .eq('authid', supabase.auth.currentUser!.id);

    print(
      '✅ nearbyParking ID $parkingLotId availability updated to ${isFull ? "OWNER USING" : "AVAILABLE"}.',
    );
  } on PostgrestException catch (error) {
    print('❌ Supabase Error: ${error.message}');
  } catch (e) {
    print('❌ General Error during nearbyParking update: $e');
  }
}

class ParkingDashboardApp extends StatelessWidget {
  const ParkingDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Operator Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC), // Light background
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const ParkingDashboard(),
    );
  }
}

class ParkingDashboard extends StatefulWidget {
  const ParkingDashboard({super.key});

  @override
  State<ParkingDashboard> createState() => _ParkingDashboardState();
}

class _ParkingDashboardState extends State<ParkingDashboard> {
  // State reflects whether the parking lot (ID 1 for this example) is marked as unavailable
  // because the owner is currently using it.
  bool isOwnerUsing = false;

  void _toggleOwnerStatus() {
    setState(() {
      isOwnerUsing = !isOwnerUsing;
    });

    // Update Supabase with the new status
    updateParkingLotAvailability(
      isFull:
          isOwnerUsing, // true = unavailable (Owner Using), false = available
      parkingLotId: 1, // Assuming this dashboard controls spot 1
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180.0,
            backgroundColor: const Color(0xFF2196F3),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Operator Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: const _DashboardHeader(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Owner Status Toggle Button ---
                    const Text(
                      'Owner Parking Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    _OwnerStatusToggle(
                      isOwnerUsing: isOwnerUsing,
                      onToggle: _toggleOwnerStatus,
                    ),
                    const SizedBox(height: 32.0),

                    // --- Status Cards Section ---
                    const Text(
                      'Quick Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const _StatusCardsRow(),
                    const SizedBox(height: 32.0),

                    // --- Quick Actions Section ---
                    const Text(
                      'Main Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const _MainCardsGrid(),
                    const SizedBox(height: 32.0),

                    // --- Operator Tips Section ---
                    const _OperatorTipsBox(),
                    const SizedBox(height: 20),

                    // Sign Out Button
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// --- Owner Status Toggle Button Widget ---
class _OwnerStatusToggle extends StatelessWidget {
  final bool isOwnerUsing;
  final VoidCallback onToggle;

  const _OwnerStatusToggle({
    required this.isOwnerUsing,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Define properties based on the current state
    final Color buttonColor = isOwnerUsing
        ? const Color(0xFFDC3545) // Red/Unavailable
        : const Color(0xFF28A745); // Green/Available
    final String statusText = isOwnerUsing
        ? "OWNER USING - Tap to Check Out"
        : "AVAILABLE - Tap to Check In";
    final IconData icon = isOwnerUsing
        ? Icons.directions_car_filled
        : Icons.directions_car;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                statusText,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Header Widget ---
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Operator! 👋',
            style: GoogleFonts.inter(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Monitor real-time parking activity and control availability.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// --- Row of Status Cards ---
class _StatusCardsRow extends StatelessWidget {
  const _StatusCardsRow();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: const [
        // 1. Revenue Card
        _RevenueCard(title: "Today's Revenue", value: "₹2450"),

        // 2. Total Slots Card
        _StatusCard(
          title: 'Total Slots',
          value: '100',
          valueColor: Color(0xFF2196F3),
          isRevenue: false,
        ),

        // 3. Occupied Card
        _StatusCard(
          title: 'Occupied',
          value: '67',
          valueColor: Color(0xFFDC3545), // Red
          isRevenue: false,
        ),

        // 4. Available Card
        _StatusCard(
          title: 'Available',
          value: '33',
          valueColor: Color(0xFF28A745), // Green
          isRevenue: false,
        ),
      ],
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final String value;

  const _RevenueCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF28A745),
            Colors.lightGreen.shade700,
          ], // Green gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28A745).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Reusable Status Card Widget (Non-Revenue) ---
class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final bool isRevenue;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.valueColor,
    this.isRevenue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: valueColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: valueColor.withOpacity(0.3), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Grid of Main Action Cards ---
class _MainCardsGrid extends StatelessWidget {
  const _MainCardsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15.0,
        crossAxisSpacing: 15.0,
        childAspectRatio: 1.0, // Square cards look cleaner for actions
      ),
      children: [
        quickActiontitle(
          Icons.qr_code_scanner,
          "Scan QR Code",
          "Quick entry by scanning parking QR",
          const Color(0xFF2196F3),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrCodeScreen()),
          ),
        ),
        quickActiontitle(
          Icons.auto_graph_outlined,
          "Operator Guide",
          "how to manage\nparking areas ",
          const Color(0xffff9800),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OperatorGuideScreen(),
            ),
          ),
        ),
        quickActiontitle(
          Icons.person,
          "Profile",
          "Manage Profile",
          const Color(0xffa230fc),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OperatorProfileScreen()),
          ),
        ),
        quickActiontitle(
          Icons.group,
          "Active Users",
          "View booked users and check-out status",
          const Color(0xFF4C51C6),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Activeuser()),
            );
          },
        ),
      ],
    );
  }
}

// --- Operator Tips Section ---
class _OperatorTipsBox extends StatelessWidget {
  const _OperatorTipsBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4C51C6).withOpacity(0.9),
            const Color(0xFF2196F3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C51C6).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.yellow,
                size: 28,
              ),
              const SizedBox(width: 10.0),
              Text(
                'Operator Tips',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const _TipItem(
            text: 'Always confirm user details before processing check-in/out.',
          ),
          const _TipItem(
            text:
                'Monitor capacity closely to prevent overbooking during peak times.',
          ),
          const _TipItem(
            text: 'Use the QR scanner for fast, accurate entry logging.',
          ),
          const _TipItem(
            text:
                'Regularly check the Active Users list for security and reconciliation.',
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
