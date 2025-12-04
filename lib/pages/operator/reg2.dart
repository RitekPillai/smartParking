import 'package:flutter/material.dart';
import 'package:smartparking/pages/operator/dashboard.dart';

const Color _primaryGreen = Color(0xFF00C853);
const Color _darkText = Color(0xFF212121);
const Color _noteBackground = Color(0xFFE3F2FD);
const Color _noteText = Color(0xFF1E88E5);

class RegistrationStep2Screen extends StatelessWidget {
  const RegistrationStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the screen width for responsive centering
    final double screenWidth = MediaQuery.of(context).size.width;
    // Set a max width for the content column to simulate the mobile view
    const double maxContentWidth = 400.0;

    return Scaffold(
      // The
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth > maxContentWidth ? maxContentWidth : screenWidth,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. Icon (Building/Parking)
              const SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Center(
                  child: Container(
                    height: 70,
                    width: 70,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade600,
                          Colors.blueAccent.shade700,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ),
              ),

              const Text(
                'Register as Operator',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step 2 of 2: Parking Area Details',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 150,
                      height: 5.0,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: _primaryGreen,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 150,
                      height: 5.0,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: _primaryGreen,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 4. Note Block
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _noteBackground,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: _noteText.withOpacity(0.5)),
                ),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Note: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _noteText,
                        ),
                      ),
                      TextSpan(
                        text:
                            'You can add your parking area details after logging in to your dashboard.',
                        style: TextStyle(
                          color: _darkText,
                          height: 1.4, // For better readability
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 5. Complete Registration Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.green, Colors.blueAccent.shade700],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Complete Registration Pressed');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkingDashboard(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Complete Registration',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// You can use this widget in your main.dart like this:
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Smart Parking App',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         fontFamily: 'Roboto', // Assuming a common font like Roboto
//       ),
//       home: const RegistrationStep2Screen(),
//     );
//   }
// }
