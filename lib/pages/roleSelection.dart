import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartparking/pages/auth/authPage.dart';
import 'package:smartparking/pages/operator/login.dart';

// --- Main Application Wrapper ---
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    // Determine if the screen is wide enough to place cards side-by-side
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              // --- App Logo ---
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5), // Blue background
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: const Icon(
                  Icons.directions_car, // Using a car icon for the logo
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 15),

              // --- Main Heading ---
              Text(
                'ParkMate',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find, Book & Manage Parking Spaces Effortlessly',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- Role Selection Cards (User and Operator) ---
              // Use a Row for wide screens (side-by-side) or a Wrap (for responsive stacking)
              isWideScreen
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildRoleCard(context, isUser: true),
                        const SizedBox(width: 40),
                        _buildRoleCard(context, isUser: false),
                      ],
                    )
                  : Column(
                      // Stack vertically on smaller screens
                      children: [
                        _buildRoleCard(context, isUser: true),
                        const SizedBox(height: 30),
                        _buildRoleCard(context, isUser: false),
                      ],
                    ),

              const SizedBox(height: 30),

              // --- Footer ---
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget for a Single Role Card (User or Operator) ---
  Widget _buildRoleCard(BuildContext context, {required bool isUser}) {
    // Determine the content based on the role
    final String title = isUser ? "I'm a User" : "I'm an Operator";
    final String description = isUser
        ? "Looking for parking spaces? Search, book, and pay seamlessly."
        : "Manage your parking area, track users, and boost revenue.";
    final List<String> bulletPoints = isUser
        ? [
            "Search nearby parking areas",
            "Scan QR & book instantly",
            "Track parking time & extend",
            "Subscription plans available",
          ]
        : [
            "Real-time capacity monitoring",
            "Generate QR codes instantly",
            "Track revenue & user list",
            "Predict availability trends",
          ];

    final IconData icon = isUser ? Icons.person : Icons.house_siding;
    final Color primaryColor = isUser
        ? Colors.blue.shade700
        : Colors.green.shade700;
    final Color bulletColor = isUser ? Colors.blue : Colors.green;

    return Container(
      width: 400, // Fixed width for the card (adjust as needed for tablets)
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Icon
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: bulletColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, color: primaryColor, size: 30),
            ),
            const SizedBox(height: 20),

            // Title and Description
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Bullet Points
            ...bulletPoints.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.circle, size: 8, color: bulletColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isUser) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Loginpage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OperatorLoginScreen(),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: Text(
                  'Continue as ${isUser ? 'User' : 'Operator'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
