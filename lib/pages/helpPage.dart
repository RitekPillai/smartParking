import 'package:flutter/material.dart';

// --- Custom Colors for Themed Sections ---
const Color _primaryBlue = Color(0xFF2196F3); // Standard Material Blue
const Color _secondaryBlue = Color(0xFF00bcd4); // Cyan/Teal
const Color _lightGreen = Color(
  0xFFE8F5E9,
); // Very light green for tips background
const Color _darkGreen = Color(0xFF4CAF50); // Darker green for checkmarks

// --- Global Data Structure for Steps (Adapted from the new UI structure) ---
final List<Map<String, dynamic>> _stepsData = [
  {
    'title': 'Create Your Account',
    'description':
        'Sign up with your name, email, phone number, and vehicle details. It only takes 2 minutes!',
    'iconData': Icons.person_outline,
  },
  {
    'title': 'Find Parking Spots',
    'description':
        'Search by location name or use "Nearby Parking" to find parking areas around you with real-time availability.',
    'iconData': Icons.search,
  },
  {
    'title': 'Scan QR Code (Optional)',
    'description':
        'At the parking entrance, scan the QR code for instant booking without manual search.',
    'iconData': Icons.qr_code_scanner,
  },
  {
    'title': 'Select Duration & Pay',
    'description':
        'Choose how many hours you need, see the total amount, and pay securely using UPI, cards, or wallets.',
    'iconData': Icons.account_balance_wallet_outlined,
  },
  {
    'title': 'Track Your Time',
    'description':
        'Monitor remaining parking time on the timer page. Get notifications when time is running out.',
    'iconData': Icons.access_time,
  },
  {
    'title': 'Rate & Exit',
    'description':
        'When leaving, click "End Parking" and share your experience by rating the parking area.',
    'iconData': Icons.star_outline,
  },
];

// --- Main Page (Stateful for Animation Management) ---
class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> with TickerProviderStateMixin {
  // Animation Controllers and Animations for staggered effect
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    // Initialize one controller for each step
    _controllers = List.generate(
      _stepsData.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    // Define the slide animation (start slightly below, end at original position)
    _slideAnimations = _controllers
        .map(
          (controller) =>
              Tween<Offset>(
                begin: const Offset(0.0, 0.4), // Start slightly below
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
              ),
        )
        .toList();

    // Define the fade animation (start transparent, end fully opaque)
    _fadeAnimations = _controllers
        .map(
          (controller) => Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn)),
        )
        .toList();

    // Start the animations in sequence
    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      // Delay before starting the next step's animation
      await Future.delayed(const Duration(milliseconds: 150));
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- Widget Builders for Steps (Integrated into the State class) ---

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
          // Right: Secondary Icon
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 5,
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
                  Navigator.pop(context);
                },
              ),
              const Text(
                'Back to Home',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const Spacer(),

              // Centered Icon
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'How to Use ParkMate',
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

                  // Guide Steps (Animated via List.generate)
                  ...List.generate(_stepsData.length, (index) {
                    final stepData = _stepsData[index];
                    return SlideTransition(
                      position: _slideAnimations[index],
                      child: FadeTransition(
                        opacity: _fadeAnimations[index],
                        child: _buildStepItem(
                          stepNumber: index + 1,
                          title: stepData['title']!,
                          description: stepData['description']!,
                          iconData: stepData['iconData']!,
                          isLast: index == _stepsData.length - 1,
                        ),
                      ),
                    );
                  }),

                  // Tips Section
                  const SizedBox(height: 32),
                  const _TipSection(),
                ],
              ),
            ),
          ),

          // 2. CTA Footer Section
          const _CtaSection(),
          // Removed: _BottomActionBar, as requested by the user.
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
