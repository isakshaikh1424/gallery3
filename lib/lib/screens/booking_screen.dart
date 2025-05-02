// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BookingScreen extends StatefulWidget {
  // final QueryDocumentSnapshot doctor;

  // const BookingScreen({super.key, required this.doctor});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _showPaymentOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Payment Option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => _makePayment('UPI'),
                  child: Text('UPI'),
                ),
                ElevatedButton(
                  onPressed: () => _makePayment('Cards'),
                  child: Text('Cards'),
                ),
                ElevatedButton(
                  onPressed: () => _showPayAtHospitalDialog(),
                  child: Text('Pay at Hospital'),
                ),
              ],
            ),
          ),
    );
  }

  void _showPayAtHospitalDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Pay at Hospital'),
            content: Text('You will pay at the hospital during your visit.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Save appointment without payment
                  // _saveAppointment('Pay at Hospital');
                  Navigator.pop(context);
                },
                child: Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _makePayment(String paymentMethod) {
    var options = {
      'key': 'YOUR_API_KEY_HERE', // Replace with your Razorpay API key
      'amount': 100, // Replace with actual amount
      'name': 'Vaidyava',
      'description': 'Doctor Appointment',
      'prefill': {'contact': '8888888888', 'email': 'test@example.com'},
      'method': paymentMethod, // UPI or Cards
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Save appointment with payment details
    // _saveAppointment('Paid via Razorpay');
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    print('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
    print('External wallet selected: ${response.walletName}');
  }

/*
  void _saveAppointment(String paymentStatus) async {
    // Save appointment to Firestore
    await FirebaseFirestore.instance.collection('appointments').add({
      'doctorId': widget.doctor.id,
      'userId':" FirebaseAuth.instance.currentUser!.uid",
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'time': _selectedTime!.format(context),
      'status': 'pending',
      'paymentStatus': paymentStatus,
    });

    // Show confirmation message
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Appointment booked successfully!')));

    // Navigate back to the previous screen
    Navigator.pop(context);
  }
*/

  void _confirmBooking() async {
    if (_selectedDate == null || _selectedTime == null) return;

    _showPaymentOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctor: ${"widget.doctor['name']"}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Select Date:', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: _selectDate,
              child: Text(
                _selectedDate == null
                    ? 'Choose Date'
                    : DateFormat.yMMMd().format(_selectedDate!),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Time:', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: _selectTime,
              child: Text(
                _selectedTime == null
                    ? 'Choose Time'
                    : _selectedTime!.format(context),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_selectedDate != null && _selectedTime != null)
                        ? _confirmBooking
                        : null,
                child: Text('Confirm Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
