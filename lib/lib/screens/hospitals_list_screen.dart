import 'package:puluspatient/lib/screens/hospital_details_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../GeoPoint.dart';

class HospitalsListScreen extends StatefulWidget {
  final GeoPoint userLocation;

  const HospitalsListScreen({required this.userLocation, super.key});

  @override
  _HospitalsListScreenState createState() => _HospitalsListScreenState();
}

class _HospitalsListScreenState extends State<HospitalsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List<DocumentSnapshot> _hospitals = [];
  // List<DocumentSnapshot> _filteredHospitals = [];
  bool _isLoading = true;
  String _sortBy = 'distance'; // Default sorting by distance

  @override
  void initState() {
    super.initState();
    // _fetchNearbyHospitals();
  }

  // Future<void> _fetchNearbyHospitals() async {
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     // Get hospitals collection
  //     final querySnapshot = await _firestore.collection('hospitals').get();
  //
  //     // Process and sort by distance
  //     final hospitals = querySnapshot.docs;
  //     hospitals.sort((a, b) {
  //       final aData = a.data();
  //       final bData = b.data();
  //
  //       final GeoPoint locationA = aData['location'];
  //       final GeoPoint locationB = bData['location'];
  //
  //       final distanceA = _calculateDistance(
  //         locationA.latitude,
  //         locationA.longitude,
  //         widget.userLocation.latitude,
  //         widget.userLocation.longitude,
  //       );
  //
  //       final distanceB = _calculateDistance(
  //         locationB.latitude,
  //         locationB.longitude,
  //         widget.userLocation.latitude,
  //         widget.userLocation.longitude,
  //       );
  //
  //       return distanceA.compareTo(distanceB);
  //     });
  //
  //     setState(() {
  //       _hospitals = hospitals;
  //       _filteredHospitals = hospitals;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error fetching hospitals: $e');
  //     setState(() => _isLoading = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error fetching hospitals: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // Convert to km
  }

  // void _filterHospitals(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       _filteredHospitals = _hospitals;
  //     } else {
  //       _filteredHospitals =
  //           _hospitals.where((element) {
  //             return (element.data() as Map<String, dynamic>)['name']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(query.toLowerCase());
  //           }).toList();
  //     }
  //   });
  // }

  // void _sortHospitals(String criteria) {
  //   setState(() => _sortBy = criteria);
  //
  //   if (_sortBy == 'distance') {
  //     // Sort by nearest distance
  //     _filteredHospitals.sort((a, b) {
  //       final aData = a.data() as Map<String, dynamic>;
  //       final bData = b.data() as Map<String, dynamic>;
  //
  //       final GeoPoint locationA = aData['location'];
  //       final GeoPoint locationB = bData['location'];
  //
  //       final distanceA = _calculateDistance(
  //         locationA.latitude,
  //         locationA.longitude,
  //         widget.userLocation.latitude,
  //         widget.userLocation.longitude,
  //       );
  //
  //       final distanceB = _calculateDistance(
  //         locationB.latitude,
  //         locationB.longitude,
  //         widget.userLocation.latitude,
  //         widget.userLocation.longitude,
  //       );
  //
  //       return distanceA.compareTo(distanceB);
  //     });
  //   } else if (_sortBy == 'rating') {
  //     // Sort by highest rating
  //     _filteredHospitals.sort((a, b) {
  //       final aData = a.data() as Map<String, dynamic>;
  //       final bData = b.data() as Map<String, dynamic>;
  //
  //       return bData['rating'].compareTo(aData['rating']); // Descending order
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Hospitals'), backgroundColor: Colors.white),
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
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Hospitals...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.red),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                      ),
                      // onChanged: _filterHospitals, on changed by ajeej for search
                    ),
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  // onSelected: (value) => _sortHospitals(value), on selected by ajeej for search
                  icon: Icon(Icons.sort),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'distance',
                          child: Text('Sort by Distance'),
                        ),
                        PopupMenuItem(
                          value: 'rating',
                          child: Text('Sort by Rating'),
                        ),
                      ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      // itemCount: _filteredHospitals.length,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        final hospital =null;
                        // final hospital =
                        //     (_filteredHospitals[index].data()
                        //         as Map<String, dynamic>);
                        return ListTile(
                          title: Text(hospital['name']),
                          subtitle: Text(
                            '${_calculateDistance(hospital['location'].latitude, hospital['location'].longitude, widget.userLocation.latitude, widget.userLocation.longitude)} km away',
                          ),
                          trailing: Text('Rating: ${hospital['rating']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => HospitalDetailsScreen(
                                      hospital: hospital,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
