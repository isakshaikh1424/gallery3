import 'package:puluspatient/lib/screens/payment_options_for_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookTestScreen extends StatefulWidget {
  final Map<String, dynamic> test;

  const BookTestScreen(this.test, {super.key});

  @override
  _BookTestScreenState createState() => _BookTestScreenState();
}

class _BookTestScreenState extends State<BookTestScreen> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  bool _isHomeSampleCollection = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _timeController.text = DateFormat('HH:mm').format(DateTime.now());
  }

  void _bookTest() {
    // Booking logic
    final testDetails = {
      'testName': widget.test['name'],
      'date': _dateController.text,
      'time': _timeController.text,
      'homeSampleCollection': _isHomeSampleCollection,
    };

    // Show payment options
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentOptionsForTestScreen(testDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(
                    () =>
                        _dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(picked),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(
                    () =>
                        _timeController.text =
                            '${picked.hour}:${picked.minute}',
                  );
                }
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isHomeSampleCollection,
                  onChanged: (value) {
                    setState(() => _isHomeSampleCollection = value ?? false);
                  },
                ),
                Text('Home Sample Collection'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _bookTest, child: Text('Book Test')),
          ],
        ),
      ),
    );
  }
}
