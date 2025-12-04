import 'package:flutter/material.dart';

// Define the primary colors used for consistency with the profile page and the new gradient
const Color primaryBlue = Color(0xFF1E88E5); // Standard Material Blue 600
const Color secondaryGreen = Color(
  0xFF4CAF50,
); // A green shade for the gradient

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String _selectedCategory = 'General Feedback';
  final TextEditingController _feedbackController = TextEditingController();

  void _submitFeedback() {
    final feedbackText = _feedbackController.text;
    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback.')),
      );
      return;
    }

    // In a real app, you would send this data to a backend service.
    debugPrint('Submitting Feedback:');
    debugPrint('Category: $_selectedCategory');
    debugPrint('Feedback: $feedbackText');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feedback submitted successfully under $_selectedCategory!',
        ),
      ),
    );
    _feedbackController.clear();
    setState(() {
      _selectedCategory = 'General Feedback';
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the max width for the feedback card on larger screens
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth > 800 ? 700 : screenWidth * 0.95;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Light grey background

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: cardWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                // Back to Home Link
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Text("pressed");
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Colors.black54,
                        ),
                        Text(
                          'Back to Home',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Feedback Card
                Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(200),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Icon (Gradient Box)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade700, Colors.green],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withAlpha(100),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Send Feedback',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Feedback Category Selection Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Feedback Category',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category Buttons Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Adjusting grid layout based on screen width
                          final isWide = constraints.maxWidth > 500;
                          return GridView.count(
                            crossAxisCount: isWide ? 2 : 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: isWide ? 5 : 6,
                            children: [
                              _FeedbackCategoryButton(
                                label: 'General Feedback',
                                isSelected:
                                    _selectedCategory == 'General Feedback',
                                onTap: () => setState(
                                  () => _selectedCategory = 'General Feedback',
                                ),
                              ),
                              _FeedbackCategoryButton(
                                label: 'Report a Bug',
                                isSelected: _selectedCategory == 'Report a Bug',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Report a Bug',
                                ),
                              ),
                              _FeedbackCategoryButton(
                                label: 'Feature Request',
                                isSelected:
                                    _selectedCategory == 'Feature Request',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Feature Request',
                                ),
                              ),
                              _FeedbackCategoryButton(
                                label: 'Complaint',
                                isSelected: _selectedCategory == 'Complaint',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Complaint',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Your Feedback Text Area Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Feedback',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Text Area
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                        child: TextField(
                          controller: _feedbackController,
                          maxLines: 8,
                          minLines: 5,
                          decoration: const InputDecoration(
                            hintText:
                                'Share your thoughts, suggestions, or report issues...',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button (with Gradient)
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          gradient: const LinearGradient(
                            colors: [primaryBlue, secondaryGreen],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _submitFeedback,
                            borderRadius: BorderRadius.circular(8.0),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Submit Feedback',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A reusable widget for displaying a selectable category button.
class _FeedbackCategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackCategoryButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.black12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryBlue : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
