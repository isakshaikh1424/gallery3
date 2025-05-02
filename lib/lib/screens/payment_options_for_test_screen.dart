import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentOptionsForTestScreen extends StatefulWidget {
  final Map<String, dynamic> testDetails;

  const PaymentOptionsForTestScreen(this.testDetails, {super.key});

  @override
  _PaymentOptionsForTestScreenState createState() =>
      _PaymentOptionsForTestScreenState();
}

class _PaymentOptionsForTestScreenState
    extends State<PaymentOptionsForTestScreen> {
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
    _razorpay.clear(); // Clear all event listeners
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Online Payment Successful\nPayment ID: ${response.paymentId}',
        ),
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
      'key': 'rzp_test_FV4AbXsCYMqPcC', // Replace with your Razorpay API key
      'amount':
          (widget.testDetails['amount'] * 100).toInt(), // Convert to paise
      'name': 'Vaidyava',
      'description': 'Payment for Test',
      'prefill': {'contact': '1234567890', 'email': 'test@razorpay.com'},
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening payment gateway: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _payAtHospital() async {
    final invoiceId = await _generateInvoice(widget.testDetails);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pay at Hospital Confirmed\nInvoice ID: $invoiceId'),
        backgroundColor: Colors.blue,
      ),
    );
    Navigator.pop(context);
  }

  void _payAtHome() async {
    final invoiceId = await _generateInvoice(widget.testDetails);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pay at Home Confirmed\nInvoice ID: $invoiceId'),
        backgroundColor: Colors.blue,
      ),
    );
    Navigator.pop(context);
  }

  Future<String> _generateInvoice(Map<String, dynamic> testDetails) async {
    // Simulate invoice generation logic
    final invoiceId = DateTime.now().millisecondsSinceEpoch.toString();
    final invoiceData = {
      'invoiceId': invoiceId,
      'testName': testDetails['testName'],
      'amount': testDetails['amount'],
      'paymentMethod': 'Pay at Hospital/Home',
    };

    print('Invoice Generated: $invoiceData');
    return invoiceId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Options for Test')),
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
          ListTile(
            title: Text('Pay at Home'),
            subtitle: Text('For Home Sample Collection'),
            trailing: ElevatedButton(
              onPressed: _payAtHome,
              child: Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}
