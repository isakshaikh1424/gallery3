import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentDetails;

  const PaymentOptionsScreen({required this.appointmentDetails, super.key});

  @override
  _PaymentOptionsScreenState createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWalletSelected);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear Razorpay event listeners
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWalletSelected(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _makeOnlinePayment() async {
    var options = {
      'key': 'YOUR_RAZORPAY_API_KEY', // Replace with your Razorpay API key
      'amount':
          (widget.appointmentDetails['amount'] * 100)
              .toInt(), // Convert to paise
      'name': widget.appointmentDetails['doctor']['name'],
      'description': 'Appointment Payment',
      'prefill': {'contact': '1234567890', 'email': 'test@razorpay.com'},
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _payAtHospital() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pay at Hospital Confirmed'),
        backgroundColor: Colors.blue,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Options')),
      body: Column(
        children: [
          ListTile(
            title: Text('Online Payment'),
            subtitle: Text('UPI, Cards, Pay Later'),
            trailing: ElevatedButton(
              onPressed: _makeOnlinePayment,
              child: Text('Pay Now'),
            ),
          ),
          ListTile(
            title: Text('Pay at Hospital'),
            subtitle: Text('Cash or Card'),
            trailing: ElevatedButton(
              onPressed: _payAtHospital,
              child: Text('Confirm'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Pay for Appointment with ${widget.appointmentDetails['doctor']['name']} on ${widget.appointmentDetails['date']} at ${widget.appointmentDetails['time']}.\nAmount: \$${widget.appointmentDetails['amount']}',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
