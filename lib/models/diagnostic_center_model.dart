// diagnostic_center_model.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

import '../GeoPoint.dart';

class DiagnosticCenter {
  final String id;
  final String name;
  final GeoPoint location; // Add this field
  final double rating;
  final double distance; // Distance in kilometers
  final List<String> availableTests;
  final bool homeCollection;

  DiagnosticCenter({
    required this.id,
    required this.name,
    required this.location, // Include this parameter in the constructor
    required this.rating,
    required this.distance,
    required this.availableTests,
    required this.homeCollection,
  });

  factory DiagnosticCenter.fromJson(
    String id,
    Map<String, dynamic> json,
    double distance,
  ) {
    return DiagnosticCenter(
      id: id,
      name: json['name'] as String,
      location:
          json['location'] as GeoPoint, // Ensure Firestore GeoPoint is used
      rating: (json['rating'] as num).toDouble(),
      distance: distance,
      availableTests: List<String>.from(json['availableTests']),
      homeCollection: json['homeCollection'] as bool? ?? false,
    );
  }
}
