import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

// The main application widget

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // === CORE PAYMENT IMPLEMENTATION DATA ===
  final String _receiverVpa =
      'test@upi'; // *** REQUIRED: Replace with your actual VPA ***
  final String _receiverName = 'Acme Solutions Pvt Ltd';
  final TextEditingController _amountController = TextEditingController(
    text: '100.00',
  );
  final String _currencyCode = 'INR';

  // Unique Transaction Reference ID (MANDATORY for UPI)
  String _transactionRefId = DateTime.now().millisecondsSinceEpoch.toString();

  String _paymentStatus = 'Pending';
  Color _statusColor = Colors.grey;

  // IMPLEMENTATION: Generates the UPI Deep Link URL
  Uri _buildUpiUri({required String amount}) {
    // UPI Deep Link format: upi://pay?pa=<VPA>&pn=<PayeeName>&mc=<MCC>&tid=<TxnID>&tr=<RefID>&am=<Amount>&cu=<Currency>&url=<URL>
    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': _receiverVpa, // Payee address (VPA)
        'pn': _receiverName, // Payee name
        'mc': '0000', // Merchant Category Code (optional)
        'tr': _transactionRefId, // Transaction Reference ID (MANDATORY)
        'am': amount, // Amount
        'cu': _currencyCode, // Currency Code (INR)
        'mode': '01', // Payment mode (01 for P2M)
        'purpose': '00', // Transaction purpose (00 for goods/services)
      },
    );
  }

  // IMPLEMENTATION: Launches the UPI application
  Future<void> _launchUPIPayment() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      _showSnackBar('Please enter a valid amount.', Colors.orange);
      return;
    }

    final uri = _buildUpiUri(amount: amountText);
    log('Attempting to launch UPI URL: $uri');

    // 1. Check if the URL scheme can be handled (i.e., if UPI apps are present)
    if (await canLaunchUrl(uri)) {
      // 2. Launch the URL using external application mode (to open a UPI app)
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Update UI to reflect initiation (actual status requires server-side checks)
      setState(() {
        _paymentStatus = 'Awaiting Confirmation...';
        _statusColor = Colors.lightBlue;
      });
    } else {
      // 3. Handle case where no UPI application is available
      log('Could not launch $uri');
      _showSnackBar('No UPI app found to process the payment.', Colors.red);
      setState(() {
        _paymentStatus = 'Payment Failed (No UPI App)';
        _statusColor = Colors.red;
      });
    }

    // Prepare for the next transaction attempt
    _transactionRefId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Payment Integration'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // UI: Payment Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaction Info',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      'Payee Name',
                      _receiverName,
                      Icons.person_outline,
                    ),
                    _buildDetailRow(
                      'Payee VPA',
                      _receiverVpa,
                      Icons.account_balance_wallet_outlined,
                    ),
                    _buildDetailRow(
                      'Currency',
                      _currencyCode,
                      Icons.monetization_on_outlined,
                    ),
                    _buildDetailRow(
                      'Ref ID (tr)',
                      _transactionRefId,
                      Icons.receipt_long,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Amount to Pay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            // UI: Amount Input Field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount (e.g., 100.00)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),

            const SizedBox(height: 40),

            // UI: Payment Button
            ElevatedButton.icon(
              onPressed: _launchUPIPayment, // IMPL: calls the launch function
              icon: const Icon(Icons.payment),
              label: const Text(
                'Launch UPI App to Pay',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),

            // UI: Status Display
            Center(
              child: Column(
                children: [
                  const Text(
                    'Latest Action Status:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _statusColor),
                    ),
                    child: Text(
                      _paymentStatus,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Note: The final SUCCESS/FAILURE status must be confirmed by your server via a payment gateway.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Helper widget for detail rows
  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.indigo.shade400),
          const SizedBox(width: 10),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black54,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
