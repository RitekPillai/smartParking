import 'package:flutter/material.dart';

// --- Custom Colors for Themed Sections ---
const Color _primaryBlue = Color(0xFF2196F3); // Standard Material Blue
const Color _secondaryBlue = Color(0xFF00bcd4); // Cyan/Teal
const Color _lightGreen = Color(
  0xFFE8F5E9,
); // Very light green for tips background
const Color _darkGreen = Color(0xFF4CAF50); // Darker green for checkmarks

class SmartParkingApp extends StatelessWidget {
  const SmartParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Parking Guide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Use a more modern text style for better readability
        fontFamily: 'Roboto',
      ),
      home: const GuideScreen(),
    );
  }
}

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The screen uses a SingleChildScrollView for the content and a distinct bottom section.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Scrollable Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: 24.0,
              ), // Padding before the bottom section
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'How to Use Smart Parking',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Your complete guide to hassle-free parking',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Guide Steps
                  _buildStepItem(
                    stepNumber: 1,
                    title: 'Create Your Account',
                    description:
                        'Sign up with your name, email, phone number, and vehicle details. It only takes 2 minutes!',
                    iconData: Icons.person_outline,
                  ),
                  _buildStepItem(
                    stepNumber: 2,
                    title: 'Find Parking Spots',
                    description:
                        'Search by location name or use "Nearby Parking" to find parking areas around you with real-time availability.',
                    iconData: Icons.search,
                  ),
                  _buildStepItem(
                    stepNumber: 3,
                    title: 'Scan QR Code (Optional)',
                    description:
                        'At the parking entrance, scan the QR code for instant booking without manual search.',
                    iconData: Icons.qr_code_scanner,
                  ),
                  _buildStepItem(
                    stepNumber: 4,
                    title: 'Select Duration & Pay',
                    description:
                        'Choose how many hours you need, see the total amount, and pay securely using UPI, cards, or wallets.',
                    iconData: Icons.account_balance_wallet_outlined,
                  ),
                  _buildStepItem(
                    stepNumber: 5,
                    title: 'Track Your Time',
                    description:
                        'Monitor remaining parking time on the timer page. Get notifications when time is running out.',
                    iconData: Icons.access_time,
                  ),
                  _buildStepItem(
                    stepNumber: 6,
                    title: 'Rate & Exit',
                    description:
                        'When leaving, click "End Parking" and share your experience by rating the parking area.',
                    iconData: Icons.star_outline,
                    isLast: true, // No bottom margin for the last item
                  ),

                  // Tips Section
                  const SizedBox(height: 32),
                  const _TipSection(),
                ],
              ),
            ),
          ),

          // 2. CTA Footer Section
          const _CtaSection(),

          // 3. Bottom Bar (Mock) - Matches the image's overlay
          const _BottomActionBar(),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Column(
        children: [
          // Back to Home Row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () {
                  // Handle back action
                },
              ),
              const Text(
                'Back to Home',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const Spacer(),
              // Centered Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primaryBlue.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.smartphone,
                  color: _primaryBlue,
                  size: 28,
                ),
              ),
              const Spacer(flex: 2), // Adjust spacer to center the icon better
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required String description,
    required IconData iconData,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Icon/Number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Center: Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: Secondary Icon (from image, used as a visual guide next to step number container)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: _primaryBlue, size: 20),
          ),
        ],
      ),
    );
  }
}

// --- Tip Section Widget ---
class _TipSection extends StatelessWidget {
  const _TipSection();

  @override
  Widget build(BuildContext context) {
    const List<String> tips = [
      'Book in advance during peak hours to ensure availability',
      'Use subscription plans if you park daily at the same location',
      'Enable location services for better nearby parking suggestions',
      'Keep notifications on to get alerts before parking time expires',
      'Check reviews and ratings before booking',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(16),
        // Add a slight shadow similar to the image
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
        children: tips.map((tip) => _buildTipRow(tip)).toList(),
      ),
    );
  }

  Widget _buildTipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: _darkGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Call to Action Section Widget ---
class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        // Gradient from blue to teal/green
        gradient: LinearGradient(
          colors: [_primaryBlue, _secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Rounded top corners to match the image
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Still Have Questions?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our support team is here to help you 24/7',
            style: TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Contact Support Button (Outlined/Faded)
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Contact Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Call Now Button (Filled)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.call, color: _secondaryBlue, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Call Now',
                      style: TextStyle(
                        color: _secondaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Bottom Action Bar (Mocking the app's persistent bar) ---
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.directions_car_filled,
            color: _primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Smart Parking',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          const Text(
            'Hello, muhsinjhm!',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.menu, color: Colors.black54),
        ],
      ),
    );
  }
}
