import 'package:puluspatient/models/diagnostic_center_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../GeoPoint.dart';

enum SortOption { rating, distance }

/// Abstract state class for DiagnosticCubit
abstract class DiagnosticState {
  const DiagnosticState();
}

/// Initial state
class DiagnosticInitial extends DiagnosticState {}

/// Loading state
class DiagnosticLoading extends DiagnosticState {}

/// Loaded state with diagnostic centers and filtering/sorting options
class DiagnosticLoaded extends DiagnosticState {
  final List<DiagnosticCenter> centers;
  final List<DiagnosticCenter> filteredCenters;
  final SortOption sortBy;

  const DiagnosticLoaded({
    required this.centers,
    required this.filteredCenters,
    this.sortBy = SortOption.rating,
  });

  /// Copy method for immutability
  DiagnosticLoaded copyWith({
    List<DiagnosticCenter>? centers,
    List<DiagnosticCenter>? filteredCenters,
    SortOption? sortBy,
  }) {
    return DiagnosticLoaded(
      centers: centers ?? this.centers,
      filteredCenters: filteredCenters ?? this.filteredCenters,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Error state
class DiagnosticError extends DiagnosticState {
  final String message;
  const DiagnosticError(this.message);
}

/// Cubit for managing diagnostic centers
class DiagnosticCubit extends Cubit<DiagnosticState> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late GeoPoint _userLocation;

  /// Constructor initializes with the initial state
  DiagnosticCubit() : super(DiagnosticInitial());

  /// Load diagnostic centers based on user location
/*
  Future<void> loadCenters(GeoPoint userLocation) async {
    try {
      emit(DiagnosticLoading());
      _userLocation = userLocation;

      final centers = await _fetchNearbyCenters();
      emit(
        DiagnosticLoaded(
          centers: centers,
          filteredCenters: centers,
          sortBy: SortOption.rating,
        ),
      );
    } catch (e) {
      emit(DiagnosticError('Failed to load centers: ${e.toString()}'));
    }
  }
*/

  /// Fetch nearby diagnostic centers from Firestore
  // Future<List<DiagnosticCenter>> _fetchNearbyCenters() async {
  //   final collection = _firestore.collection('diagnostic_centers');
  //   final querySnapshot = await collection.get();
  //
  //   final List<DiagnosticCenter> centers =
  //       querySnapshot.docs.map((doc) {
  //         final data = doc.data();
  //         final geoPoint = data['location'] as GeoPoint;
  //
  //         // Calculate distance using Geolocator
  //         final distance =
  //             Geolocator.distanceBetween(
  //               _userLocation.latitude,
  //               _userLocation.longitude,
  //               geoPoint.latitude,
  //               geoPoint.longitude,
  //             ) /
  //             1000; // Convert meters to kilometers
  //
  //         return DiagnosticCenter(
  //           id: doc.id,
  //           name: data['name'],
  //           location: geoPoint, // Pass GeoPoint here
  //           rating: (data['rating'] as num).toDouble(),
  //           distance: distance,
  //           availableTests: List<String>.from(data['availableTests']),
  //           homeCollection: data['homeCollection'] as bool? ?? false,
  //         );
  //       }).toList();
  //
  //   return centers;
  // }

  /// Filter diagnostic centers based on search query
  void filterCenters(String query) {
    if (state is! DiagnosticLoaded) return;
    final loadedState = state as DiagnosticLoaded;

    final filtered =
        loadedState.centers.where((center) {
          return center.name.toLowerCase().contains(query.toLowerCase()) ||
              center.availableTests.any(
                (test) => test.toLowerCase().contains(query.toLowerCase()),
              );
        }).toList();

    emit(
      loadedState.copyWith(
        filteredCenters: _applySort(filtered, loadedState.sortBy),
      ),
    );
  }

  /// Sort diagnostic centers based on selected option
  void sortCenters(SortOption option) {
    if (state is! DiagnosticLoaded) return;
    final loadedState = state as DiagnosticLoaded;

    emit(
      loadedState.copyWith(
        filteredCenters: _applySort(loadedState.filteredCenters, option),
        sortBy: option,
      ),
    );
  }

  /// Apply sorting logic to a list of diagnostic centers
  List<DiagnosticCenter> _applySort(
    List<DiagnosticCenter> centers,
    SortOption option,
  ) {
    final sorted = List<DiagnosticCenter>.from(centers);
    sorted.sort(
      (a, b) =>
          option == SortOption.rating
              ? b.rating.compareTo(a.rating)
              : a.distance.compareTo(b.distance),
    );
    return sorted;
  }
}
