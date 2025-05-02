import 'package:puluspatient/lib/screens/add_more_address_details.dart';
import 'package:puluspatient/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice2/places.dart';

class AddAddressScreen extends StatefulWidget {
  final String userName;
  final String userPhone;
  final Map<String, String>? initialData;

  const AddAddressScreen({
    super.key,
    required this.userName,
    required this.userPhone,
    this.initialData,
  });

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // Constants
  static const String _kGoogleApiKey =
      "AIzaSyCTEzWZeNLmHt3kICZKupyIsoZkxWT9Jhk";

  // Controllers and services
  final places = GoogleMapsPlaces(apiKey: _kGoogleApiKey);
  GoogleMapController? _mapController;

  // State variables
  LatLng? _currentPosition;
  String _currentAddress = 'Select a location...';
  bool _isLoading = true;
  List<Prediction> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _initializeWithExistingData();
    } else {
      _initializeLocation();
    }
  }

  void _initializeWithExistingData() {
    try {
      setState(() {
        _currentPosition = LatLng(
          double.parse(widget.initialData!['latitude'] ?? '0'),
          double.parse(widget.initialData!['longitude'] ?? '0'),
        );
        _currentAddress = widget.initialData!['address'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Error initializing with existing data: $e');
      _initializeLocation();
    }
  }

  Future<void> _initializeLocation() async {
    try {
      setState(() => _isLoading = true);

      final position = await LocationService.getCurrentPosition();
      final address = await LocationService.getAddressFromLatLng(
        LatLng(position.latitude, position.longitude),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _currentAddress = address;
        _isLoading = false;
      });

      _animateToPosition(_currentPosition!);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error fetching location: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _animateToPosition(LatLng position) {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
    }
  }

  Future<void> _handleSearch(String value) async {
    if (value.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final predictions = await places.autocomplete(
      value,
      components: [Component(Component.country, "IN")],
    );

    if (predictions.status == "OK") {
      setState(() => _searchResults = predictions.predictions);
    }
  }

  Future<void> _selectPlace(Prediction prediction) async {
    final placeDetails = await places.getDetailsByPlaceId(prediction.placeId!);

    if (placeDetails.status == "OK") {
      final lat = placeDetails.result.geometry!.location.lat;
      final lng = placeDetails.result.geometry!.location.lng;

      setState(() {
        _currentPosition = LatLng(lat, lng);
        _currentAddress = placeDetails.result.formattedAddress ?? "";
        _searchResults = [];
        _searchController.clear();
      });

      _animateToPosition(_currentPosition!);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _animateToPosition(_currentPosition!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.initialData != null ? 'Edit Address' : 'Confirm Your Location',
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : (_currentPosition == null
                  ? Center(child: Text('Unable to fetch location'))
                  : Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            GoogleMap(
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: _currentPosition ?? LatLng(0, 0),
                                zoom: 16,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId('delivery_location'),
                                  position: _currentPosition!,
                                  draggable: true,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed,
                                  ),
                                  onDragEnd: (newPosition) async {
                                    final address =
                                        await LocationService.getAddressFromLatLng(
                                          newPosition,
                                        );
                                    setState(() {
                                      _currentPosition = newPosition;
                                      _currentAddress = address;
                                    });
                                  },
                                ),
                              },
                              onTap: (position) async {
                                final address =
                                    await LocationService.getAddressFromLatLng(
                                      position,
                                    );
                                setState(() {
                                  _currentPosition = position;
                                  _currentAddress = address;
                                });
                              },
                            ),
                            // Search bar
                            Positioned(
                              top: 20,
                              left: 20,
                              right: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _searchController,
                                      onChanged: _handleSearch,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search for area, street name...',
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.red,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                    ),
                                    if (_searchResults.isNotEmpty)
                                      Container(
                                        color: Colors.white,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _searchResults.length,
                                          itemBuilder: (context, index) {
                                            final prediction =
                                                _searchResults[index];
                                            return ListTile(
                                              title: Text(
                                                prediction.description ?? "",
                                              ),
                                              onTap:
                                                  () =>
                                                      _selectPlace(prediction),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.my_location, color: Colors.red),
                              label: Text('Use current location'),
                              onPressed: _initializeLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected location:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _currentAddress,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            AddMoreAddressDetailsScreen(
                                              userName: widget.userName,
                                              userPhone: widget.userPhone,
                                              currentAddress: _currentAddress,
                                              initialData: widget.initialData,
                                            ),
                                  ),
                                );
                                if (result != null) {
                                  result['latitude'] =
                                      _currentPosition!.latitude.toString();
                                  result['longitude'] =
                                      _currentPosition!.longitude.toString();
                                  Navigator.pop(context, result);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                widget.initialData != null
                                    ? 'Update address details'
                                    : 'Add more address details',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
