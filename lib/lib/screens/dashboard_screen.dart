import 'dart:io';

import 'package:puluspatient/GeoPoint.dart';
import 'package:puluspatient/lib/screens/Diagnostic_centres.dart';
import 'package:puluspatient/lib/screens/add_address_screen.dart';
import 'package:puluspatient/lib/screens/emergency_screen.dart';
import 'package:puluspatient/lib/screens/health_records.dart';
import 'package:puluspatient/lib/screens/hospitals_list_screen.dart';
import 'package:puluspatient/lib/screens/medical_store_screen.dart';
import 'package:puluspatient/lib/screens/profile_screen.dart';
import 'package:puluspatient/lib/screens/specialization_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  final String fullName;
  final String phoneNumber;
  final Map<String, String>? initialAddress;

  const DashboardScreen({
    super.key,
    required this.fullName,
    required this.phoneNumber,
    this.initialAddress,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _currentAddress;
  String? _currentTag;
  bool _isFetchingLocation = false;
  int _selectedIndex = 0;
  List<Map<String, String>> savedAddresses = [];
  Position? _currentPosition;
  String? _profilePicture; // Holds the path of the profile picture

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadSavedAddresses();
    _loadProfilePicture();
    if (widget.initialAddress != null) {
      _currentTag = widget.initialAddress!['tag'];
      _currentAddress = widget.initialAddress!['address'];
      _saveCurrentLocation(_currentTag!, _currentAddress!);
    }
  }

  Future<GeoPoint> _getUserLocation() async {
    try {
      // Check location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('Location permissions denied');
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      return GeoPoint(position.latitude, position.longitude);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initializeLocation() async {
    await _fetchCurrentLocation();
    await _loadPreviousLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        setState(() => _currentAddress = "Location permission denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _currentPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentAddress =
            "${placemarks[0].name}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}";
        _currentTag = "Current Location";
      });
    } catch (e) {
      print('Error fetching location: $e');
      setState(() => _currentAddress = "Unable to fetch location");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<bool> _requestLocationPermission() async {
    return (await Permission.location.request()).isGranted;
  }

  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddressesString = prefs.getStringList('savedAddresses') ?? [];
    setState(() {
      savedAddresses =
          savedAddressesString
              .map((a) => Map<String, String>.from(Uri.splitQueryString(a)))
              .toList();
    });
  }

  Future<void> _saveAllAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'savedAddresses',
      savedAddresses.map((a) => Uri(queryParameters: a).query).toList(),
    );
  }

  Future<void> _loadPreviousLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentTag = prefs.getString('currentTag');
      _currentAddress = prefs.getString('currentAddress');
    });
  }

  Future<void> _saveCurrentLocation(String tag, String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentTag', tag);
    await prefs.setString('currentAddress', address);
  }

  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profilePicture = prefs.getString('profilePicture');
    });
  }

  double _calculateDistance(Map<String, String> address) {
    try {
      return Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        double.parse(address['latitude']!),
        double.parse(address['longitude']!),
      );
    } catch (e) {
      return 0;
    }
  }

  String _formatDistance(double meters) {
    return meters < 1000
        ? '${meters.toStringAsFixed(0)} m'
        : '${(meters / 1000).toStringAsFixed(1)} km';
  }

  void _showLocationDialog() async {
    final screenWidth = MediaQuery.of(context).size.width;

    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
            ),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_drop_down, color: Colors.black),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Select a location',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddAddressScreen(
                                userName: widget.fullName,
                                userPhone: widget.phoneNumber,
                              ),
                        ),
                      );
                      if (result != null) {
                        setState(() => savedAddresses.add(result));
                        await _saveAllAddresses();
                      }
                    },
                    child: ListTile(
                      leading: Icon(Icons.add, color: Colors.red),
                      title: Text(
                        'Add address',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: screenWidth * 0.04,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Divider(),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _fetchCurrentLocation();
                    },
                    child: ListTile(
                      leading: Icon(Icons.gps_fixed, color: Colors.red),
                      title: Text(
                        'Use current location',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      subtitle: Text(
                        _isFetchingLocation
                            ? 'Fetching...'
                            : (_currentAddress ?? ''),
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: screenWidth * 0.04,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Divider(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showSavedAddresses(context);
                    },
                    child: ListTile(
                      leading: Icon(Icons.bookmark, color: Colors.red),
                      title: Text(
                        'Saved Addresses',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: screenWidth * 0.04,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSavedAddresses(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.04),
        ),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setSheetState) {
              return Container(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.1,
                  left: screenWidth * 0.04,
                  right: screenWidth * 0.04,
                  bottom: screenWidth * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Saved Addresses',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.05),
                    Expanded(
                      child: ListView.builder(
                        itemCount: savedAddresses.length,
                        itemBuilder: (context, index) {
                          final address = savedAddresses[index];
                          final distance = _calculateDistance(address);
                          final distanceText =
                              distance == 0
                                  ? 'Calculating...'
                                  : _formatDistance(distance);

                          return Card(
                            key: ValueKey(address.hashCode),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.03,
                              ),
                            ),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.02,
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getTagIcon(address['tag'] ?? 'Other'),
                                color: Colors.blue,
                                size: screenWidth * 0.06,
                              ),
                              title: Text(
                                address['tag'] ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address['address'] ?? '',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.01),
                                  Text(
                                    distanceText,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: screenWidth * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'Edit') {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AddAddressScreen(
                                              userName: widget.fullName,
                                              userPhone: widget.phoneNumber,
                                              initialData: address,
                                            ),
                                      ),
                                    );
                                    if (result != null) {
                                      setState(
                                        () => savedAddresses[index] = result,
                                      );
                                      await _saveAllAddresses();
                                      setSheetState(() {});
                                    }
                                  } else if (value == 'Delete') {
                                    final deletedAddress =
                                        savedAddresses[index];
                                    final wasCurrentAddress =
                                        _currentAddress ==
                                        deletedAddress['address'];
                                    setState(
                                      () => savedAddresses.removeAt(index),
                                    );
                                    await _saveAllAddresses();
                                    setSheetState(() {});
                                    if (wasCurrentAddress) {
                                      await _handleAddressDeletion(
                                        deletedAddress,
                                      );
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DashboardScreen(
                                                fullName: widget.fullName,
                                                phoneNumber: widget.phoneNumber,
                                              ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: 'Edit',
                                        child: Text(
                                          'Edit Address',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'Delete',
                                        child: Text(
                                          'Delete Address',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                          ),
                                        ),
                                      ),
                                    ],
                              ),
                              onTap: () {
                                setState(() {
                                  _currentTag = address['tag'];
                                  _currentAddress = address['address'];
                                });
                                _saveCurrentLocation(
                                  _currentTag!,
                                  _currentAddress!,
                                );
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Future<void> _handleAddressDeletion(
    Map<String, String> deletedAddress,
  ) async {
    if (savedAddresses.isNotEmpty) {
      int newIndex = savedAddresses.indexWhere(
        (a) => a['address'] != deletedAddress['address'],
      );
      if (newIndex == -1) newIndex = 0;
      setState(() {
        _currentTag = savedAddresses[newIndex]['tag'];
        _currentAddress = savedAddresses[newIndex]['address'];
      });
      await _saveCurrentLocation(_currentTag!, _currentAddress!);
    } else {
      await _fetchCurrentLocation();
      await _saveCurrentLocation("Current Location", _currentAddress!);
    }
  }

  IconData _getTagIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'hotel':
        return Icons.hotel;
      case 'hospital':
        return Icons.local_hospital;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => SystemNavigator.pop(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: _showLocationDialog,
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTag ?? 'Select location',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _isFetchingLocation
                            ? 'Fetching location...'
                            : (_currentAddress ?? 'Add address'),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  await _loadProfilePicture();
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey[500],
                  backgroundImage:
                      (_profilePicture != null &&
                              File(_profilePicture!).existsSync())
                          ? FileImage(File(_profilePicture!))
                          : null,
                  radius: screenWidth * 0.05,
                  child:
                      (_profilePicture == null || _profilePicture!.isEmpty)
                          ? Text(
                            widget.fullName.isNotEmpty
                                ? widget.fullName[0].toUpperCase()
                                : "U",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(77),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search medicines, doctors, labs...',
                      hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.red,
                        size: screenWidth * 0.05,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.035,
                      ),
                    ),
                  ),
                ),
              ),
              // Doctors widget
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecializationScreen(),
                      ),
                    ),
                child: Card(
                  elevation: 6,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Container(
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_hospital,
                          size: screenWidth * 0.1,
                          color: Colors.white,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          'Doctors',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Hospitals Section
              GestureDetector(
                onTap: () async {
                  try {
                    final userLocation = await _getUserLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                HospitalsListScreen(userLocation: userLocation),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Card(
                  elevation: 6,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Container(
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_hospital_rounded,
                          size: screenWidth * 0.1,
                          color: Colors.white,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          'Hospitals',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Lab & Scanning Centres Section
              GestureDetector(
                onTap: () async {
                  try {
                    final userLocation = await _getUserLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CentersListScreen(userLocation),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Card(
                  elevation: 6,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Container(
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink, Colors.pinkAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Row(
                      children: [
                        Icon(
                          Icons.medical_services_rounded,
                          size: screenWidth * 0.1,
                          color: Colors.white,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          'Lab & Scanning Centres',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Medical Stores Section
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalStoreScreen(),
                      ),
                    ),
                child: Card(
                  elevation: 6,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Container(
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Row(
                      children: [
                        Icon(
                          Icons.medication_rounded,
                          size: screenWidth * 0.1,
                          color: Colors.white,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          'Medical Stores',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthRecordsScreen(),
                ),
              ).then((_) => setState(() => _selectedIndex = 0));
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyScreen(),
                ),
              ).then((_) => setState(() => _selectedIndex = 0));
            }
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Health Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency),
              label: 'Emergency',
            ),
          ],
        ),
      ),
    );
  }
}
