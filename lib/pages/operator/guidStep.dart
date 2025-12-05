import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Data model for the guide steps
class GuideStep {
  final int number;
  final String title;

  GuideStep(this.number, this.title);
}

// Data source for the operator guide steps
final List<GuideStep> guideSteps = [
  GuideStep(1, "Register with parking area details"),
  GuideStep(2, "Display QR code at entrance"),
  GuideStep(3, "Monitor capacity real-time"),
  GuideStep(4, "Add manual entries for walk-ins"),
  GuideStep(5, "Update predictions during peak hours"),
  GuideStep(6, "Track revenue and history"),
];

// --- MAIN SCREEN WIDGET ---
class OperatorGuideScreen extends StatefulWidget {
  const OperatorGuideScreen({super.key});

  @override
  State<OperatorGuideScreen> createState() => _OperatorGuideScreenState();
}

class _OperatorGuideScreenState extends State<OperatorGuideScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for the overall content
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Total animation time
    );

    // Start the animation once the screen is built
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Light gray background
      body: SafeArea(
        child: Column(
          children: [
            // Simplified App Bar/Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.black54, size: 20),
                        SizedBox(width: 4),
                        Text('Back', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Card
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Icon (Car/Parking)
                      const _AnimatedHeaderIcon(),
                      const SizedBox(height: 20),

                      // Title and Subtitle
                      Text(
                        "Operator Guide",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "How to manage your parking area",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Animated Guide Steps List
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: guideSteps.length,
                          itemBuilder: (context, index) {
                            return _AnimatedGuideStep(
                              step: guideSteps[index],
                              animationController: _animationController,
                              // Stagger the start time for each item
                              delay: index * 100,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET: Animated Header Icon ---
class _AnimatedHeaderIcon extends StatelessWidget {
  const _AnimatedHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], // Green gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_outlined,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

// --- WIDGET: Animated Guide Step ---
class _AnimatedGuideStep extends StatelessWidget {
  final GuideStep step;
  final AnimationController animationController;
  final int delay; // Delay in milliseconds for staggering

  const _AnimatedGuideStep({
    required this.step,
    required this.animationController,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    // Create a specific animation for this list item
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        // Start the animation slightly after the previous one starts
        curve: Interval(
          delay / 1000,
          (delay + 500) / 1000, // Duration of 500ms for each item
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              20 * (1 - animation.value),
            ), // Slide down from 20px
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Step Number Icon
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853), // Bright Green/Teal
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${step.number}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Step Title
            Expanded(
              child: Text(
                step.title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
