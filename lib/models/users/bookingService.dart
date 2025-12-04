// File: lib/models/users/booking_service.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart'; // UPI Integration
// The specific RawSql import is removed/ignored, relying on PostgrestLiteral from core libs
// Keeping this for PostgrestLiteral definition

// --- 1. BOOKING MODEL (Unchanged) ---

/// Represents a single parking booking transaction.
class Booking {
  final int id;
  final int parkingId;
  final String userId;
  final String? userName;
  final String numberPlate;
  final DateTime startTime;
  final DateTime endTime;
  final double? durationHours;
  final double? pricePerHour;
  final double? totalAmount;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.parkingId,
    required this.userId,
    this.userName,
    required this.numberPlate,
    required this.startTime,
    required this.endTime,
    this.durationHours,
    this.pricePerHour,
    this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'parking_id': parkingId,
      'user_id': userId,
      'user_name': userName,
      'number_plate': numberPlate,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'duration_hours': durationHours,
      'price_per_hour': pricePerHour,
      'total_amount': totalAmount,
      'status': status,
    };
  }
}

// ---------------------------------------------------------------------
// --- 2. CORE BOOKING LOGIC: UPI PAYMENT & CONDITIONAL UPLOAD ---
// ---------------------------------------------------------------------

/// Initiates UPI payment, and on success, uploads the new booking to Supabase
/// AND **decrements the spot count for the specific parking lot (Isolated Update)**.
// File: lib/models/users/booking_service.dart (Updated initiateUpiPayment function)

/// Initiates UPI payment, and on success, uploads the new booking to Supabase
/// AND **decrements the spot count for the specific parking lot (Isolated Update)**.
Future<void> initiateUpiPayment({
  required BuildContext context,
  required int parkingId, // Used for isolated database update
  required double rate,
  required DateTime startTime,
  required DateTime endTime,
  required String numberPlate,
  required String userName,
  required double totalAmount, // Pre-calculated amount based on fetched rate
}) async {
  final supabase = Supabase.instance.client;

  const String merchantVpa = "abhishekpillai1350@okaxis";
  const String merchantName = "Smart Parking Vendor";
  // !!! -------------------- !!!

  final userId = supabase.auth.currentUser?.id;
  final String amountString = totalAmount.toStringAsFixed(2);

  if (userId == null || totalAmount <= 0) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not logged in or amount is invalid."),
        ),
      );
    }
    return;
  }

  // Generate a unique transaction reference
  final transactionRef = 'BOOKING${DateTime.now().millisecondsSinceEpoch}';

  // 1. Initiate the UPI Transaction
  try {
    final UpiTransactionResponse response = await UpiPay.initiateTransaction(
      app: UpiApplication.googlePay,
      receiverUpiAddress: merchantVpa,
      receiverName: merchantName,
      transactionRef: transactionRef,
      transactionNote: "Parking Booking for $numberPlate",
      amount: amountString,
    );

    // 2. Handle UPI Response
    if (response.status == UpiTransactionStatus.success) {
      // Payment was successful!

      final duration = endTime.difference(startTime);
      final durationHours = duration.inMinutes / 60.0;

      final newBookingData = {
        'parking_id': parkingId,
        'user_id': userId,
        'user_name': userName,
        'number_plate': numberPlate,
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'duration_hours': durationHours,
        'price_per_hour': rate,
        'total_amount': totalAmount,
        'status': 'confirmed',
        'checkout': false,
      };

      // 3a. Upload Booking to 'bookings' table
      await supabase.from('bookings').insert(newBookingData);

      // --- 🔑 FIX: Read-then-Update for Isolated Spot Decrement ---
      // 3b. Read the current number of spots for the specific parking ID
      final currentSpotData = await supabase
          .from('nearByParking')
          .select('spots')
          .eq('id', parkingId)
          .single();

      final currentSpots = currentSpotData['spots'] as int;
      final newSpots = currentSpots > 0 ? currentSpots - 1 : 0;

      // 3c. Update the 'spots' column with the new, decremented value
      await supabase
          .from('nearByParking')
          .update({'spots': newSpots})
          .eq('id', parkingId);
      // -------------------------------------------------------------------

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Payment & Booking successful! Total: ₹$amountString. Spots remaining: $newSpots",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Payment failed or was cancelled by the user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Payment failed or cancelled. Status: ${response.status?.name.toUpperCase() ?? 'UNKNOWN'}",
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('UPI initiation failed or DB update failed: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ System Error: Could not complete booking. Please check logs.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------
// --- 3. BOOKING FORM WIDGET (for Modal Sheet) ---
// ---------------------------------------------------------------------

/// Displays the BookingForm as a modal bottom sheet.
void showBookingSheet({
  required BuildContext context,
  required String parkingName,
  required int parkingId,
  required double rate,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        BookingForm(parkingName: parkingName, parkingId: parkingId, rate: rate),
  );
}

class BookingForm extends StatefulWidget {
  final String parkingName;
  final int parkingId;
  final double rate; // Price per hour fetched from nearByParking

  const BookingForm({
    super.key,
    required this.parkingName,
    required this.parkingId,
    required this.rate,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _nameController = TextEditingController(
    text:
        Supabase.instance.client.auth.currentUser?.email?.split('@').first ??
        '',
  );

  // Initialize times slightly in the future
  DateTime _startTime = DateTime.now().add(const Duration(minutes: 5));
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1, minutes: 5));

  @override
  void dispose() {
    _plateController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // --- Date/Time Pickers ---
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final initialTime = isStart ? _startTime : _endTime;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );

    if (pickedTime != null) {
      setState(() {
        final newTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (isStart) {
          _startTime = newTime;
          // Maintain a minimum booking duration
          if (_endTime.isBefore(_startTime.add(const Duration(minutes: 30)))) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          // Only allow end times that are at least 1 minute after the start time
          if (newTime.isAfter(_startTime.add(const Duration(minutes: 1)))) {
            _endTime = newTime;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("End time must be after start time."),
              ),
            );
          }
        }
      });
    }
  }

  // --- Calculate total amount for display (uses widget.rate) ---
  String calculateTotal() {
    final duration = _endTime.difference(_startTime);
    if (duration.inMinutes <= 0) return 'Invalid Time';

    // Calculation using fetched rate (widget.rate)
    final durationHours = duration.inMinutes / 60.0;
    final total = durationHours * widget.rate;
    return '₹${total.toStringAsFixed(2)}';
  }

  // --- SUBMIT LOGIC (Initiates UPI payment) ---
  void submit() {
    if (_formKey.currentState!.validate()) {
      final duration = _endTime.difference(_startTime);

      if (duration.inMinutes < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking duration must be valid.")),
        );
        return;
      }

      final durationHours = duration.inMinutes / 60.0;
      final totalAmount = durationHours * widget.rate; // Final calculation

      // Close the sheet before payment starts (UX improvement)
      Navigator.pop(context);

      // Call the payment initiation function
      initiateUpiPayment(
        context: context,
        parkingId: widget.parkingId,
        rate: widget.rate,
        startTime: _startTime,
        endTime: _endTime,
        numberPlate: _plateController.text.toUpperCase(),
        userName: _nameController.text,
        totalAmount: totalAmount,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book ${widget.parkingName}',
                style: GoogleFonts.alexandria(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rate: ₹${widget.rate.toStringAsFixed(2)}/hr',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Divider(height: 30),

              // 1. Number Plate Input
              TextFormField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number Plate',
                  hintText: 'e.g., MH 01 AB 1234',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle number plate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // 2. User Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name (for booking)',
                  hintText: 'e.g., Jane Doe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),

              // 3. Time Pickers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Start Time
                  _TimePickerButton(
                    label: 'Start Time',
                    time: _startTime,
                    onTap: () {
                      _selectTime(context, true).then((_) => setState(() {}));
                    },
                  ),
                  // End Time
                  _TimePickerButton(
                    label: 'End Time',
                    time: _endTime,
                    onTap: () {
                      _selectTime(context, false).then((_) => setState(() {}));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 4. Total Amount Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimated Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    calculateTotal(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 5. Final Confirmation Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirm and Pay',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Time Picker Helper Widget ---
class _TimePickerButton extends StatelessWidget {
  final String label;
  final DateTime time;
  final VoidCallback onTap;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  TimeOfDay.fromDateTime(time).format(context),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
