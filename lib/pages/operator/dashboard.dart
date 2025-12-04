import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartparking/pages/historyPage.dart';
import 'package:smartparking/pages/nearByParking.dart';
import 'package:smartparking/pages/operator/qrcode.dart';
import 'package:smartparking/pages/scannerPage.dart';
import 'package:smartparking/pages/subscription.dart';
import 'package:smartparking/widgets/quickAction.dart';

void main() {
  runApp(const ParkingDashboardApp());
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
      ),
      home: const ParkingDashboard(),
    );
  }
}

class ParkingDashboard extends StatelessWidget {
  const ParkingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Header Section ---
          const SizedBox(height: 24.0),

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
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16.0),

          const SizedBox(height: 16.0),

          // --- Main Cards Section ---
          const _MainCardsGrid(),
          const SizedBox(height: 32.0),

          // --- Operator Tips Section ---
          const _OperatorTipsBox(),
        ],
      ),
    );
  }
}

// --- Header Widget ---
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Welcome back, Operator! 👋',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        // Placeholder for a menu/notification icon if needed
      ],
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
      childAspectRatio: 1.7,

      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,

      children: const [
        _RevenueCard(title: "Today's Revenue", value: "₹2450"),

        _StatusCard(
          title: 'Total Slots',
          value: '100',
          valueColor: Color(0xFF333333),
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
      height: 50,
      width: 100,
      padding: const EdgeInsets.all(17.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightGreenAccent, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        // Aligned to start to match the dashboard image hierarchy
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.alexandria(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 24, // Adjusted font size slightly
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
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: valueColor.withOpacity(0.5), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Quick Action Row (Smart Parking) ---

// --- Main Action Card Widget (Reusable) ---
class _MainActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _MainActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width:
            MediaQuery.of(context).size.width / 3 - 32, // Three cards per row
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Grid of Main Action Cards ---
class _MainCardsGrid extends StatelessWidget {
  const _MainCardsGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QrCodeScreen()),
            ),
          ),
          quickActiontitle(
            Icons.auto_graph,
            "Predictability",
            "Update predictions & manual entry",
            const Color(0xfff95500),
            () => {},
          ),
          quickActiontitle(
            Icons.credit_card,
            "Revenue",
            "Track daily earnings",
            const Color(0xffa230fc),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubscriptionPage()),
            ),
          ),
          quickActiontitle(
            Icons.history,
            "Booking History",
            "View your past bookings",
            Colors.blue.shade900,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingHistoryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- Operator Tips Section ---
class _OperatorTipsBox extends StatelessWidget {
  const _OperatorTipsBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.green]),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.yellow, size: 24),
              SizedBox(width: 8.0),
              Text(
                'Operator Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          _TipItem(text: 'Keep your QR code visible at the parking entrance'),
          _TipItem(
            text:
                'Update predictions during peak hours for better user experience',
          ),
          _TipItem(text: 'Use manual entry for customers without the app'),
          _TipItem(text: 'Check the users list regularly for security'),
          _TipItem(text: 'Monitor capacity to prevent overbooking'),
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
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
