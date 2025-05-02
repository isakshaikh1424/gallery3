import 'package:puluspatient/lib/screens/dashboard_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMoreAddressDetailsScreen extends StatefulWidget {
  final String userName;
  final String currentAddress;
  final Map<String, String>? initialData;

  const AddMoreAddressDetailsScreen({
    super.key,
    required this.userName,
    required this.currentAddress,
    this.initialData,
    required String userPhone,
  });

  @override
  _AddMoreAddressDetailsScreenState createState() =>
      _AddMoreAddressDetailsScreenState();
}

class _AddMoreAddressDetailsScreenState
    extends State<AddMoreAddressDetailsScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  bool _isAddressFilled = false;
  String _selectedTag = 'Home';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _addressController.text =
        widget.initialData?['address'] ?? widget.currentAddress;
    _floorController.text = widget.initialData?['floor'] ?? '';
    _landmarkController.text = widget.initialData?['landmark'] ?? '';
    _selectedTag = widget.initialData?['tag'] ?? 'Home';
    _addressController.addListener(_updateAddressStatus);
    _updateAddressStatus();
    //_fetchUserPhone();
  }

  // Future<void> _fetchUserPhone() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final userData =
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .get();
  //     setState(() {
  //       _userPhone = userData['phone'] ?? '';
  //     });
  //   }
  // }

  void _updateAddressStatus() {
    setState(() {
      _isAddressFilled = _addressController.text.isNotEmpty;
    });
  }

  Future<void> _saveAddress(Map<String, String> newAddress) async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddresses = prefs.getStringList('savedAddresses') ?? [];

    if (widget.initialData != null) {
      savedAddresses.removeWhere(
        (addr) =>
            Uri.splitQueryString(addr)['address'] ==
            widget.initialData!['address'],
      );
    }

    savedAddresses.add(Uri(queryParameters: newAddress).query);
    await prefs.setStringList('savedAddresses', savedAddresses);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          Colors.white, // Set background color of the entire screen
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.initialData != null
              ? 'Edit address details'
              : 'Enter address details',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Name and Phone Row
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white, // Set background color of the row
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.red,
                    ), // Prefix icon for username
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Icon(
                      Icons.phone,
                      color: Colors.red,
                    ), // Prefix icon for phone number
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        _userPhone,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Tag this location for later',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTagButton('Home', Icons.home, screenWidth),
                    SizedBox(width: screenWidth * 0.02),
                    _buildTagButton('Work', Icons.work, screenWidth),
                    SizedBox(width: screenWidth * 0.02),
                    _buildTagButton('Hotel', Icons.hotel, screenWidth),
                    SizedBox(width: screenWidth * 0.02),
                    _buildTagButton(
                      'Hospital',
                      Icons.local_hospital,
                      screenWidth,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    _buildTagButton('Other', Icons.more_horiz, screenWidth),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      // Address section with "Change" button
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentAddress,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            'Updated based on your exact map pin',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Change',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Complete Address *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _floorController,
                decoration: InputDecoration(
                  labelText: 'Floor (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _landmarkController,
                decoration: InputDecoration(
                  labelText: 'Landmark (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              ElevatedButton(
                onPressed:
                    _isAddressFilled
                        ? () async {
                          final newAddress = {
                            'tag': _selectedTag,
                            'address': _addressController.text,
                            'floor': _floorController.text,
                            'landmark': _landmarkController.text,
                            'latitude': widget.initialData?['latitude'] ?? '',
                            'longitude': widget.initialData?['longitude'] ?? '',
                          };
                          await _saveAddress(newAddress);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DashboardScreen(
                                    fullName: widget.userName,
                                    phoneNumber: _userPhone,
                                    initialAddress: newAddress,
                                  ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAddressFilled ? Colors.red : Colors.grey,
                  minimumSize: Size(double.infinity, screenHeight * 0.06),
                ),
                child: const Text(
                  'Confirm address',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagButton(String label, IconData icon, double screenWidth) {
    bool isSelected = _selectedTag == label;
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        size: screenWidth * 0.045,
        color: isSelected ? Colors.white : Colors.grey,
      ),
      label: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
      ),
      onPressed: () => setState(() => _selectedTag = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red : Colors.white,
        side: BorderSide(color: isSelected ? Colors.red : Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _floorController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }
}
