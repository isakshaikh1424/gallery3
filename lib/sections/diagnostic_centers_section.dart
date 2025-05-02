// diagnostic_centers_section.dart
import 'package:puluspatient/cubit/diagnostic_cubit.dart';
import 'package:puluspatient/lib/screens/diagnostic_centres.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import GeoPoint
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../GeoPoint.dart';

/*
Widget buildDiagnosticCentersSection(
  BuildContext context,
  GeoPoint userLocation,
) {
  return BlocProvider(
    create: (context) => DiagnosticCubit()..loadCenters(userLocation),
    child: Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearby Diagnostic Centers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            BlocBuilder<DiagnosticCubit, DiagnosticState>(
              builder: (context, state) {
                if (state is DiagnosticLoaded) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.centers.take(3).length,
                    itemBuilder: (context, index) {
                      final center = state.centers[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.local_hospital,
                          color: Colors.blue,
                        ),
                        title: Text(center.name),
                        subtitle: Text(
                          '${center.distance.toStringAsFixed(1)} km • ⭐ ${center.rating.toStringAsFixed(1)}',
                        ),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        CentersListScreen(center.location),
                              ),
                            ),
                      );
                    },
                  );
                } else if (state is DiagnosticLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text('No centers found.'));
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
*/
