// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'booking_screen.dart'; // Import the booking screen

class DoctorListScreen extends StatefulWidget {
  final String specialty;

  const DoctorListScreen({required this.specialty, super.key});

  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  // List<QueryDocumentSnapshot> _doctors = [];
  // List<QueryDocumentSnapshot> _filteredDoctors = [];
  bool _isSortedByReviews = false;
  bool _isSortedByDistance = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    final position = await _getCurrentLocation();
    final lat = position.latitude;
    final lng = position.longitude;

    // final querySnapshot =
    //     await FirebaseFirestore.instance
    //         .collection('doctors')
    //         .where('specialty', isEqualTo: widget.specialty)
    //         .get();

    setState(() {
      // _doctors = querySnapshot.docs;
      // _filteredDoctors = _doctors;
    });
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

 /* void _filterDoctors(String query) {
    final filteredList =
        _doctors.where((doc) {
          return doc['name'].toLowerCase().contains(query.toLowerCase()) ||
              doc['hospital'].toLowerCase().contains(query.toLowerCase());
        }).toList();

    setState(() {
      _filteredDoctors = filteredList;
    });
  }
*/
/*
  void _sortDoctors() {
    if (_isSortedByReviews) {
      _filteredDoctors.sort((a, b) => b['rating'].compareTo(a['rating']));
    } else if (_isSortedByDistance) {
      _filteredDoctors.sort((a, b) {
        final distanceA = Geolocator.distanceBetween(
          a['location']['latitude'],
          a['location']['longitude'],
          // User's location
          37.7749,
          -122.4194,
        );
        final distanceB = Geolocator.distanceBetween(
          b['location']['latitude'],
          b['location']['longitude'],
          // User's location
          37.7749,
          -122.4194,
        );
        return distanceA.compareTo(distanceB);
      });
    }
    setState(() {});
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Doctors in ${widget.specialty}'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search doctors, hospitals ...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.red,
                        ), // Red icon
                        border: InputBorder.none, // No border
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                      ),
                      onChanged: (query) => {}/*_filterDoctors(query)*/,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.sort),
                  onPressed: () {
                    if (_isSortedByReviews) {
                      _isSortedByReviews = false;
                      _isSortedByDistance = true;
                    } else {
                      _isSortedByReviews = true;
                      _isSortedByDistance = false;
                    }
                    /*_sortDoctors();*/
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 0/*_filteredDoctors.length*/,
              itemBuilder: (context, index) {
                final doctor = null/*_filteredDoctors[index]*/;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      doctor['image'],
                    ), // Doctor's image URL
                  ),
                  title: Text(doctor['name']),
                  subtitle: Text(
                    '${doctor['hospital']} • ${doctor['rating']} ⭐',
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                  ), // Arrow icon for navigation
                  onTap:
                      () => /*Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(doctor: doctor),
                        ),
                      ),*/{},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
