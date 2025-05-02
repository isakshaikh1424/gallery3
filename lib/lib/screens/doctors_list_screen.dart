import 'package:puluspatient/lib/screens/book_appointment_screen.dart';
import 'package:flutter/material.dart';

class DoctorsListScreen extends StatefulWidget {
  final Map<String, dynamic> department;

  const DoctorsListScreen({required this.department, super.key});

  @override
  _DoctorsListScreenState createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.department['name']} - Doctors')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.department['doctors']?.length ?? 0,
              itemBuilder: (context, index) {
                final doctor = widget.department['doctors'][index];
                return ListTile(
                  title: Text(doctor['name']),
                  subtitle: Text(doctor['specialty']),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookAppointmentScreen(
                                doctor: doctor,
                                amount: doctor['fees'], // Pass doctor fees
                              ),
                        ),
                      );
                    },
                    child: Text('Book Appointment'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
