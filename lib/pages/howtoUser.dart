import 'package:flutter/material.dart';

// You would typically navigate to this page from your main application.
// For demonstration, you can replace the main() function with this:
/*
void main() {
  runApp(const MaterialApp(
    title: 'Smart Parking',
    home: HowToUsePage(),
  ));
}
*/

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'How to Use Smart Parking',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Getting started is easy! Follow these simple steps for a smooth parking experience.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // --- Section 1: Booking a Spot ---
            const GuideStep(
              stepNumber: 1,
              title: 'Book a Parking Spot',
              description:
                  'Search for parking areas, select duration, make payment, and show confirmation at the entrance.',
              icon: Icons.search,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),

            // --- Section 2: Extending Time ---
            const GuideStep(
              stepNumber: 2,
              title: 'Extend Your Parking Time',
              description:
                  'Use the "Extend Time" button on the timer page and make additional payment.',
              icon: Icons.timer,
              color: Colors.green,
            ),
            const SizedBox(height: 20),

            // --- Section 3: Exiting Early ---
            const GuideStep(
              stepNumber: 3,
              title: 'Exit Early (End Parking)',
              description:
                  'Click "End Parking" on the timer page. Note: No refunds for unused time.',
              icon: Icons.exit_to_app,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),

            // --- Section 4: Using QR Scanner ---
            const GuideStep(
              stepNumber: 4,
              title: 'Use the QR Scanner',
              description:
                  'Click "Scan QR" on the home page, scan the code at the parking entrance to book instantly.',
              icon: Icons.qr_code_scanner,
              color: Color(0xFF9C27B0), // Purple
            ),
          ],
        ),
      ),
    );
  }
}

// --- Reusable Widget for Each Step ---
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Number Circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
        const SizedBox(width: 15),

        // Title and Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
