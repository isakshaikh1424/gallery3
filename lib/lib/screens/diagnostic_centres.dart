import 'package:puluspatient/cubit/diagnostic_cubit.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import GeoPoint
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../GeoPoint.dart';
import 'test_booking_screen.dart';

class CentersListScreen extends StatelessWidget {
  final GeoPoint userLocation;

  const CentersListScreen(this.userLocation, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lab & Scanning Centers'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search tests or centers...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.red,
                        ), // Red icon
                        border: InputBorder.none, // No border
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                      ),
                      onChanged:
                          (query) => context
                              .read<DiagnosticCubit>()
                              .filterCenters(query),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _showSortOptions(context, value),
                  icon: const Icon(Icons.sort),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'rating',
                          child: const Text('Sort by Rating'),
                        ),
                        PopupMenuItem(
                          value: 'distance',
                          child: const Text('Sort by Distance'),
                        ),
                      ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DiagnosticCubit, DiagnosticState>(
              builder: (context, state) {
                if (state is DiagnosticLoaded) {
                  return state.filteredCenters.isEmpty
                      ? const Center(child: Text('No centers found'))
                      : ListView.builder(
                        itemCount: state.filteredCenters.length,
                        itemBuilder: (context, index) {
                          final center = state.filteredCenters[index];
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
                                        (context) => TestBookingScreen(center),
                                  ),
                                ),
                          );
                        },
                      );
                } else {
                  return const SizedBox(); // Do not show anything if not loaded
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, String? value) {
    if (value != null) {
      context.read<DiagnosticCubit>().sortCenters(
        value == 'rating' ? SortOption.rating : SortOption.distance,
      );
    }
  }
}
