import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartparking/pages/auth/authPage.dart'; // Assuming your Login/RoleSelection is here
import 'package:smartparking/pages/homePage.dart'; // Your main user homepage
import 'package:smartparking/pages/operator/dashboard.dart';
import 'package:smartparking/pages/roleSelection.dart'; // Initial unauthenticated screen
import 'package:supabase_flutter/supabase_flutter.dart';

// Placeholder for a non-user role (e.g., Operator)
const Widget OperatorHomepage = Scaffold(
  body: Center(
    child: Text(
      "Operator/Non-User Homepage",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  ),
);

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;
  final supabase = Supabase.instance.client;

  // Synchronous getter for current user ID
  String? getCurrentUserId() {
    final User? user = supabase.auth.currentUser;
    return user?.id;
  }

  // Robust role fetch with a retry mechanism
  Future<String?> fetchRole() async {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      return null;
    }

    // Parameters for retry logic
    const int maxRetries = 4;
    const Duration delay = Duration(milliseconds: 500); // Max wait: 2 seconds

    for (int i = 0; i < maxRetries; i++) {
      try {
        final data = await supabase
            .from('users')
            .select("role")
            .eq('id', userId)
            .maybeSingle();

        // Success: Role found
        if (data != null && data.containsKey('role')) {
          debugPrint(
            'SUCCESS! Fetched role on attempt ${i + 1}: ${data['role']}',
          );
          return data['role'] as String;
        }

        // Failure: Role not found yet, wait and try again
        debugPrint(
          'Role not found for user. Retrying in 500ms... (Attempt ${i + 1})',
        );
        await Future.delayed(delay);
      } catch (e) {
        debugPrint('Error fetching profile: $e');
        // Stop retrying if a network error occurs
        return null;
      }
    }

    // All retries failed
    debugPrint('Role still not found after all retries.');
    return null;
  }

  @override
  void initState() {
    super.initState();

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      // Ignore initial session as the build method handles it
      if (event == AuthChangeEvent.initialSession) {
        return;
      }

      // Handle sign out: clear stack and go to RoleSelection
      if (event == AuthChangeEvent.signedOut) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
          (route) => false,
        );
      }
      // Handle sign in/update: force a rebuild
      else if (session != null) {
        if (!mounted) return;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // 1. No Session (Not Logged In)
    if (session == null) {
      return const RoleSelectionScreen();
    }
    // 2. Session Exists (Logged In)
    else {
      return FutureBuilder<String?>(
        future: fetchRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('Error loading user data. Check network.'),
              ),
            );
          }

          final String? role = snapshot.data;

          // A. Role is 'user'
          if (role == "user") {
            return const Homepage();
          }
          // B. Role exists but is NOT 'user' (e.g., 'operator')
          else if (role != null) {
            return ParkingDashboard();
          }
          // C. Role is NULL (Profile data missing after retries)
          else {
            return const RoleSelectionScreen();
          }
        },
      );
    }
  }
}
