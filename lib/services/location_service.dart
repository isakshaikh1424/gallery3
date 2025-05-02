import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  /// Request location permissions and verify service status
  static Future<void> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Please enable location services on your device');
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('Location permissions required to continue');
        }
      }
    } catch (e) {
      throw Exception('Permission error: ${e.toString()}');
    }
  }

  /// Get current device position with high accuracy
  static Future<Position> getCurrentPosition() async {
    try {
      await requestLocationPermission();
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 15),
      );
    } on LocationServiceDisabledException {
      throw Exception('Location services are disabled');
    } catch (e) {
      throw Exception('Failed to get position: ${e.toString()}');
    }
  }

  /// Convert coordinates to human-readable address
  static Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return 'Address not found';

      final place = placemarks.first;
      return _formatAddress(
        street: place.street,
        sublocality: place.subLocality,
        locality: place.locality,
        administrativeArea: place.administrativeArea,
        postalCode: place.postalCode,
      );
    } on NoResultFoundException {
      return 'Address not available for this location';
    } catch (e) {
      throw Exception('Geocoding error: ${e.toString()}');
    }
  }

  /// Get continuous location updates stream
  static Stream<Position> getLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).handleError((error) {
      throw Exception('Location updates failed: ${error.toString()}');
    });
  }

  /// Format address components into readable string
  static String _formatAddress({
    String? street,
    String? sublocality,
    String? locality,
    String? administrativeArea,
    String? postalCode,
  }) {
    final components =
        [
          street,
          sublocality,
          locality,
          administrativeArea,
          postalCode,
        ].where((c) => c != null && c.isNotEmpty).toList();

    return components.isNotEmpty
        ? components.join(', ')
        : 'Address unavailable';
  }
}
