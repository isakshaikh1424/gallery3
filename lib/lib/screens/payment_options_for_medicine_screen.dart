import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentOptionsForMedicineScreen extends StatefulWidget {
  final List<Map<String, dynamic>> medicines;
  final Map<String, int> cart;

  const PaymentOptionsForMedicineScreen({
    required this.medicines,
    required this.cart,
    super.key,
  });

  @override
  _PaymentOptionsForMedicineScreenState createState() =>
      _PaymentOptionsForMedicineScreenState();
}

class _PaymentOptionsForMedicineScreenState
    extends State<PaymentOptionsForMedicineScreen> {
  late Razorpay _razorpay;
  int _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWalletSelected);

    // Calculate total amount
    for (var medicine in widget.medicines) {
      if (widget.cart.containsKey(medicine['name'])) {
        _totalAmount +=
            ((medicine['price'] as num) * widget.cart[medicine['name']]!)
                .toInt();
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear all event listeners
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful: ${response.paymentId}'),
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

  void _makeOnlinePayment() {
    var options = {
      'key': 'YOUR_RAZORPAY_API_KEY',
      'amount': _totalAmount * 100, // Convert to paise
      'name': 'Vaidyava',
      'description': 'Payment for Medicines',
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

  void _payAtDelivery() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pay at Delivery Confirmed'),
        backgroundColor: Colors.blue,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Options for Medicines')),
      body: Column(
        children: [
          ListTile(
            title: Text('Order Summary'),
            subtitle: Text('Total Amount: \$$_totalAmount'),
          ),
          ListTile(
            title: Text('Online Payment'),
            subtitle: Text('UPI, Cards, Pay Later'),
            trailing: ElevatedButton(
              onPressed: _makeOnlinePayment,
              child: Text('Pay Now'),
            ),
          ),
          ListTile(
            title: Text('Pay at Delivery'),
            subtitle: Text('Cash or Card'),
            trailing: ElevatedButton(
              onPressed: _payAtDelivery,
              child: Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}
