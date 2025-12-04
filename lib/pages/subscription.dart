import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String _selectedPlan = 'Monthly';
  int _hoursPerDay = 1;
  final TextEditingController _parkingAreaController = TextEditingController(
    text: "Enter parking area name",
  );
  final TextEditingController _vehicleNumberController = TextEditingController(
    text: "DL 01 AB 1234",
  );

  static const int monthlyPrice = 300;
  static const int quarterlyPrice = 800;
  static const int yearlyPrice = 2100;

  // Calculates the total amount based on plan and hours
  int _calculateTotalAmount() {
    int baseAmount;
    int durationDays;
    double discount = 0.0;

    switch (_selectedPlan) {
      case 'Quarterly':
        baseAmount = quarterlyPrice;
        durationDays = 90;
        discount = 0.20; // 20% saved
        break;
      case 'Yearly':
        baseAmount = yearlyPrice;
        durationDays = 365;
        discount = 0.30; // 30% saved
        break;
      case 'Monthly':
      default:
        baseAmount = monthlyPrice;
        durationDays = 30;
        discount = 0.10; // 10% saved
        break;
    }

    int total = baseAmount * _hoursPerDay;

    if (_selectedPlan == 'Monthly' && _hoursPerDay == 1) {
      return 900;
    }

    return total;
  }

  // Helper widget to build the individual plan card
  Widget _buildSubscriptionCard(
    String plan,
    String duration,
    String saveText,
    int basePrice,
    String savePercentage,
  ) {
    bool isSelected = _selectedPlan == plan;

    // Determine the save percentage based on the plan for display
    String actualSaveText = savePercentage;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPlan = plan;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x0ffe0e0f) : Colors.white,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF7C3AED)
                  : Colors.grey.shade200,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (plan == 'Monthly')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Popular",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(height: 18), // Placeholder for alignment

              const SizedBox(height: 8),
              Text(
                plan,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF7C3AED).withOpacity(0.1)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  saveText,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF065F46),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for form input fields
  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for subscription benefits
  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF00C853),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalAmount = _calculateTotalAmount();

    // Map selected plan to its duration display string
    String durationDisplay = switch (_selectedPlan) {
      'Quarterly' => '90 days',
      'Yearly' => '365 days',
      _ => '30 days',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Cannot go back")));
            }
          },
        ),
        title: const Text(""),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.blue],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.workspace_premium_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Subscription Plans",
                      style: GoogleFonts.alexandria(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Save more with monthly parking subscriptions",
                      style: GoogleFonts.alexandria(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Subscription Cards Row
              Row(
                children: [
                  _buildSubscriptionCard(
                    'Monthly',
                    '30 days',
                    'Save 10%',
                    monthlyPrice,
                    '10%',
                  ),
                  const SizedBox(width: 12),
                  _buildSubscriptionCard(
                    'Quarterly',
                    '90 days',
                    'Save 20%',
                    quarterlyPrice,
                    '20%',
                  ),
                  const SizedBox(width: 12),
                  _buildSubscriptionCard(
                    'Yearly',
                    '365 days',
                    'Save 30%',
                    yearlyPrice,
                    '30%',
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Form Inputs
              _buildInputField(
                "Parking Area Name",
                _parkingAreaController,
                "Enter parking area name",
              ),
              _buildInputField(
                "Vehicle Number",
                _vehicleNumberController,
                "DL 01 AB 1234",
              ),

              // Hours Required Per Day (Simple Dropdown/Input)
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hours Required Per Day",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _hoursPerDay,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          items: List.generate(10, (index) => index + 1).map((
                            int value,
                          ) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _hoursPerDay = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Price Breakdown Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duration & Hours Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Hours/Day",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Text(
                          "$_hoursPerDay",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Duration",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Text(
                          durationDisplay,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),

                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "₹$totalAmount",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED), // Purple accent
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Subscription Benefits",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Benefits List
                    _buildBenefitItem("No daily payment hassle"),
                    _buildBenefitItem("Guaranteed parking slot"),
                    _buildBenefitItem("Priority entry"),
                    _buildBenefitItem("Digital ID card"),
                    _buildBenefitItem("Save up to 30%"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Subscribe Button
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.purple,
                      Colors.blue,
                    ], // Purple to Blue gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Subscribing to $_selectedPlan plan for ₹$totalAmount!",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Subscribe Now",
                    style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
