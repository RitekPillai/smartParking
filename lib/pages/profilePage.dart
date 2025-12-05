import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import for debugPrint

// Initialize Supabase client globally
final supabase = Supabase.instance.client;

// --- DATA MODEL for Operator Profile ---
class OperatorProfileData {
  final String id;
  final String email;
  final String username;
  final String phoneno;

  OperatorProfileData({
    required this.id,
    required this.email,
    required this.username,
    required this.phoneno,
  });

  // Factory constructor to combine data from auth and 'users' table
  static OperatorProfileData fromJson(
    User authUser,
    Map<String, dynamic>? userData,
  ) {
    return OperatorProfileData(
      id: authUser.id,
      email: authUser.email ?? 'N/A',
      // The users table typically holds the username
      username: userData?['username'] as String? ?? 'Operator',
      phoneno: userData?['phoneno'] as String? ?? 'N/A',
    );
  }
}

// --- MAIN SCREEN WIDGET ---
class OperatorProfileScreen extends StatefulWidget {
  const OperatorProfileScreen({super.key});

  @override
  State<OperatorProfileScreen> createState() => _OperatorProfileScreenState();
}

class _OperatorProfileScreenState extends State<OperatorProfileScreen> {
  OperatorProfileData? _profileData;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  // Controller for the editable field
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // --- Supabase Data Fetching ---
  Future<void> _fetchUserData() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operator not logged in.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      // Fetch user data from the 'users' table
      final response = await supabase
          .from('users')
          .select('username, phoneno')
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _profileData = OperatorProfileData.fromJson(user, response);
          _usernameController.text = _profileData!.username;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching operator data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load profile data. Check connection.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Supabase Data Update ---
  Future<void> _updateUserData() async {
    if (_profileData == null) return;

    setState(() {
      _isSaving = true;
    });

    final String newUsername = _usernameController.text.trim();

    try {
      await supabase
          .from('users')
          .update({'username': newUsername})
          .eq('id', _profileData!.id);

      // Update local state with new data
      if (mounted) {
        setState(() {
          _profileData = OperatorProfileData(
            id: _profileData!.id,
            email: _profileData!.email,
            username: newUsername,
            phoneno: _profileData!.phoneno,
          );
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF28A745), // Green success color
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating operator data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save changes. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // --- Sign Out Logic ---
  void _signOut() {
    supabase.auth.signOut();
    // Assuming Navigator.pop until the root is required after sign out
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // --- UI Helpers ---
  void _toggleEdit(bool editing) {
    if (editing) {
      // Start editing: populate controller with current data
      _usernameController.text = _profileData?.username ?? '';
    }
    setState(() {
      _isEditing = editing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Back to Dashboard and Edit Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Back to Dashboard",
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit / Save / Cancel Buttons
                      _buildActionButtons(),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 2. Page Header
                  Text(
                    "Operator Profile",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Review and update your operational credentials.",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 3. Profile Form
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _profileData == null
                  ? const Center(child: Text("Could not load operator data."))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AnimatedProfileField(
                            delay: 0,
                            label: "Display Name (Username)",
                            icon: Icons.person_outline,
                            isEditing: _isEditing,
                            controller: _usernameController,
                            hintText: "Enter your username",
                            readOnlyNote: "This is your display name.",
                          ),
                          _AnimatedProfileField(
                            delay: 100,
                            label: "Email Address (Operator ID)",
                            icon: Icons.mail_outline,
                            isEditing: false, // Always false
                            value: _profileData!.email,
                            readOnlyNote:
                                "Your email is used for login and cannot be modified.",
                          ),
                          _AnimatedProfileField(
                            delay: 200,
                            label: "Phone Number",
                            icon: Icons.phone_android,
                            isEditing: false, // Always false
                            value: _profileData!.phoneno,
                            readOnlyNote:
                                "Your phone is used for communication and cannot be modified.",
                          ),
                          const SizedBox(height: 30),

                          // --- SIGN OUT BUTTON (Full Width) ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _signOut,
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Sign Out of Operator Account",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFDC3545,
                                ), // Red/Danger color
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                          const _SecurityNote(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to handle the transition between Edit and Save/Cancel buttons
  Widget _buildActionButtons() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: _isEditing
          ? Row(
              key: const ValueKey('edit_actions'),
              children: [
                // Cancel Button
                TextButton(
                  onPressed: _isSaving ? null : () => _toggleEdit(false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Save Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: _isSaving
                          ? [
                              Colors.grey.shade400,
                              Colors.grey.shade500,
                            ] // Greyed out when saving
                          : const [
                              Color(0xFF0D47A1),
                              Color(0xFF2196F3),
                            ], // Blue gradient (matching dashboard)
                    ),
                  ),
                  child: ElevatedButton(
                    key: const ValueKey('save_button'),
                    onPressed: _isSaving ? null : _updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            )
          : // Edit Button
            ElevatedButton.icon(
              key: const ValueKey('edit_button'),
              onPressed: () => _toggleEdit(true),
              icon: const Icon(Icons.edit, size: 18, color: Colors.white),
              label: Text(
                'Edit',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3), // Blue color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
              ),
            ),
    );
  }
}

// --- WIDGET: Animated Profile Field (Used for Staggered Load/View/Edit Modes) ---
class _AnimatedProfileField extends StatelessWidget {
  final int delay;
  final String label;
  final IconData icon;
  final bool isEditing;
  final TextEditingController? controller;
  final String? value; // For read-only fields
  final String? hintText;
  final String readOnlyNote;

  const _AnimatedProfileField({
    required this.delay,
    required this.label,
    required this.icon,
    required this.isEditing,
    this.controller,
    this.value,
    this.hintText,
    required this.readOnlyNote,
  });

  @override
  Widget build(BuildContext context) {
    // Staggered animation wrapper
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: EdgeInsets.only(
              top: (1 - opacity) * 20, // Slide up effect
              bottom: 15.0,
            ),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label text for the field
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Field Container (Animated between read-only text and TextField)
          Container(
            padding: EdgeInsets.symmetric(
              vertical: isEditing ? 0 : 16.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isEditing ? Colors.blue.shade400 : Colors.grey.shade200,
                width: isEditing ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isEditing
                      ? Colors.blue.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isEditing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(icon, color: Colors.grey.shade500),
                      hintText: hintText,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
                  )
                : // Read-only Display
                  Row(
                    children: [
                      Icon(icon, color: Colors.grey.shade500, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller?.text.isNotEmpty == true
                              ? controller!.text
                              : (value ?? 'N/A'),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 4),
          // Helper note (only for read-only fields or when editing is off)
          if (!isEditing)
            Text(
              readOnlyNote,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: label.contains("cannot be modified")
                    ? Colors.red.shade400
                    : Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }
}

// --- WIDGET: Security Note (Similar to a card/chip) ---
class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Security Note: ',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Your account is secured via Supabase. Always keep your credentials safe. Sensitive details like email and phone number must be changed via administrative access or support.',
                    style: GoogleFonts.inter(
                      color: Colors.blue.shade800,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
