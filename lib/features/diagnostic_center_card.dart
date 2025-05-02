// 1. Create the widget file
// lib/features/diagnostic/widgets/diagnostic_center_card.dart

import 'package:puluspatient/lib/screens/test_booking_screen.dart';
import 'package:puluspatient/models/diagnostic_center_model.dart';
import 'package:flutter/material.dart';

class DiagnosticCenterCard extends StatelessWidget {
  final DiagnosticCenter center;

  const DiagnosticCenterCard({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.blue),
        title: Text(center.name),
        subtitle: Text(
          '${center.distance} km • ⭐ ${center.rating.toStringAsFixed(1)}',
        ),
        trailing:
            center.homeCollection
                ? const Text(
                  'Home Collection',
                  style: TextStyle(color: Colors.green),
                )
                : null,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TestBookingScreen(center),
              ),
            ),
      ),
    );
  }
}
