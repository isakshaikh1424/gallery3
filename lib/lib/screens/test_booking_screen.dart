import 'package:puluspatient/cubit/booking_cubit.dart';
import 'package:puluspatient/features/multi_select_dialog_field.dart';
import 'package:puluspatient/models/diagnostic_center_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class TestBookingScreen extends StatefulWidget {
  final DiagnosticCenter center;

  const TestBookingScreen(this.center, {super.key});

  @override
  _TestBookingScreenState createState() => _TestBookingScreenState();
}

class _TestBookingScreenState extends State<TestBookingScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle payment success
    _confirmBooking('PaymentSuccessful');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment error
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Payment failed')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
  }

  void _confirmBooking(String paymentStatus) {
    final bookingState = context.read<BookingCubit>().state;
    if (bookingState.selectedTests.isEmpty ||
        bookingState.date == null ||
        bookingState.time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all details before booking.'),
        ),
      );
      return;
    }

    context.read<BookingCubit>().confirmBooking(widget.center.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
    Navigator.pop(context);
  }

  void _makePayment(String paymentMethod) {
    if (paymentMethod == 'PayLater') {
      // Simpl/Lazypay integration
      // Currently not supported by Razorpay Flutter
      // Implement using their APIs if available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pay Later not supported yet')),
      );
      return;
    }

    var options = {
      'key': 'YOUR_RAZORPAY_KEY_ID', // Replace with your key
      'amount': 100, // Replace with the actual amount
      'name': 'Acme Corp.',
      'description': 'Test Payment',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
    };

    if (paymentMethod == 'UPI') {
      options['method'] = 'upi';
    } else if (paymentMethod == 'Cards') {
      options['method'] = 'card';
    }

    _razorpay.open(options);
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('UPI'),
              onTap: () => _makePayment('UPI'),
            ),
            ListTile(
              title: const Text('Cards'),
              onTap: () => _makePayment('Cards'),
            ),
            ListTile(
              title: const Text('Pay Later (Simpl/Lazypay)'),
              onTap: () => _makePayment('PayLater'),
            ),
            ListTile(
              title: const Text('Pay at Hospital'),
              onTap: () => _confirmBooking('PayAtHospital'),
            ),
            if (widget.center.homeCollection)
              ListTile(
                title: const Text('Pay at Home'),
                onTap: () => _confirmBooking('PayAtHome'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book at ${widget.center.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Tests/Scans',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            MultiSelectDialogField(
              items:
                  widget.center.availableTests
                      .map((test) => MultiSelectItem(test, test))
                      .toList(),
              dialogTitle: 'Select Tests',
              buttonText: 'Choose Tests',
              onConfirm:
                  (selected) => context
                      .read<BookingCubit>()
                      .updateSelectedTests(selected.cast<String>()),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Date & Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Date'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        context.read<BookingCubit>().updateDate(date);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Time'),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      );
                      if (time != null) {
                        context.read<BookingCubit>().updateTime(time);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (widget.center.homeCollection)
              CheckboxListTile(
                title: const Text('Home Sample Collection'),
                value: context.watch<BookingCubit>().state.homeCollection,
                onChanged:
                    (value) =>
                        context.read<BookingCubit>().toggleHomeCollection(),
              ),
            ElevatedButton(
              onPressed: _showPaymentOptions,
              child: const Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
