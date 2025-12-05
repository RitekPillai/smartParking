import 'package:flutter/material.dart';

// --- Global Data Structure for Steps ---
final List<Map<String, dynamic>> _stepsData = [
  {
    'title': 'Book a Parking Spot',
    'description':
        'Search for parking areas, select duration, make payment, and show confirmation at the entrance.',
    'icon': Icons.search,
    'color': Colors.blue,
  },
  {
    'title': 'Extend Your Parking Time',
    'description':
        'Use the "Extend Time" button on the timer page and make additional payment.',
    'icon': Icons.timer,
    'color': Colors.green,
  },
  {
    'title': 'Exit Early (End Parking)',
    'description':
        'Click "End Parking" on the timer page. Note: No refunds for unused time.',
    'icon': Icons.exit_to_app,
    'color': Colors.orange,
  },
  {
    'title': 'Use the QR Scanner',
    'description':
        'Click "Scan QR" on the home page, scan the code at the parking entrance to book instantly.',
    'icon': Icons.qr_code_scanner,
    'color': const Color(0xFF9C27B0), // Purple
  },
];

// --- Main Page (Stateful for Animation Management) ---
class HowToUsePage extends StatefulWidget {
  const HowToUsePage({super.key});

  @override
  State<HowToUsePage> createState() => _HowToUsePageState();
}

class _HowToUsePageState extends State<HowToUsePage>
    with TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Light grey background
      appBar: AppBar(
        title: const Text(
          'ParkMate Guide',
          style: TextStyle(
            color: Color(0xFF1F2937), // Dark grey text
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1, // Subtle shadow
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 24,
          bottom: 24,
          left: 16,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0, left: 4.0, right: 4.0),
              child: Text(
                'Getting started is easy! Follow these simple, animated steps for a seamless parking experience.',
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
            ),

            // Generate the animated steps
            ...List.generate(_stepsData.length, (index) {
              final stepData = _stepsData[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                // Apply the slide and fade transitions using the respective animations
                child: SlideTransition(
                  position: _slideAnimations[index],
                  child: FadeTransition(
                    opacity: _fadeAnimations[index],
                    child: GuideStep(
                      stepNumber: index + 1,
                      title: stepData['title']!,
                      description: stepData['description']!,
                      icon: stepData['icon']!,
                      color: stepData['color']!,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// --- Reusable Widget for Each Step (Enhanced UI) ---
class GuideStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const GuideStep({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        // A subtle shadow effect to lift the card
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number & Icon Column
          Column(
            children: [
              // Step Number Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                    12.0,
                  ), // Rounded step number box
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Icon below the step number
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(width: 16),

          // Title and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
