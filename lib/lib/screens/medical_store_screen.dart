import 'dart:convert';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'payment_options_for_medicine_screen.dart';

class MedicalStoreScreen extends StatefulWidget {
  const MedicalStoreScreen({super.key});

  @override
  _MedicalStoreScreenState createState() => _MedicalStoreScreenState();
}

class _MedicalStoreScreenState extends State<MedicalStoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _filteredStores = [];
  String _sortOption = 'Distance';

  @override
  void initState() {
    super.initState();
    // _fetchStores();
  }

  // Future<void> _fetchStores() async {
  //   try {
  //     final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     final storesSnapshot = await firestore.collection('stores').get();
  //     setState(() {
  //       _stores = storesSnapshot.docs.map((doc) => doc.data()).toList();
  //       _filteredStores = _stores;
  //     });
  //   } catch (e) {
  //     debugPrint('Error fetching stores: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error fetching stores'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  void _filterStores(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStores = _stores;
      } else {
        _filteredStores =
            _stores
                .where(
                  (element) => element['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  void _sortStores() {
    setState(() {
      if (_sortOption == 'Distance') {
        _filteredStores.sort((a, b) => a['distance'].compareTo(b['distance']));
      } else if (_sortOption == 'Ratings') {
        _filteredStores.sort((a, b) => b['rating'].compareTo(a['rating']));
      }
    });
  }

  void _changeSortOption(String option) {
    setState(() {
      _sortOption = option;
      _sortStores();
    });
  }

  void _navigateToStore(Map<String, dynamic> store) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoreScreen(store: store)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Medical Stores'),
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
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Stores...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.red),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                      ),
                      onChanged: _filterStores,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _sortStores(),
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
            child: ListView.builder(
              itemCount: _filteredStores.length,
              itemBuilder: (context, index) {
                final store = _filteredStores[index];
                return ListTile(
                  title: Text(store['name']),
                  subtitle: Text(
                    'Rating: ${store['rating']}, Distance: ${store['distance']} km',
                  ),
                  onTap: () => _navigateToStore(store),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StoreScreen extends StatefulWidget {
  final Map<String, dynamic> store;

  const StoreScreen({required this.store, super.key});

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _filteredMedicines = [];
  File? _prescriptionImage;
  final Map<String, int> _cart = {};

  @override
  void initState() {
    super.initState();
    // _fetchMedicines();
  }

  // Future<void> _fetchMedicines() async {
  //   try {
  //     final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     final medicinesSnapshot = await firestore.collection('medicines').get();
  //     setState(() {
  //       _medicines = medicinesSnapshot.docs.map((doc) => doc.data()).toList();
  //       _filteredMedicines = _medicines;
  //     });
  //   } catch (e) {
  //     debugPrint('Error fetching medicines: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error fetching medicines'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  void _filterMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedicines = _medicines;
      } else {
        _filteredMedicines =
            _medicines
                .where(
                  (element) => element['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  void _uploadPrescription() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _prescriptionImage = File(image.path));
      await _processPrescription(_prescriptionImage!);
    }
  }

  Future<void> _processPrescription(File image) async {
    try {
      // Convert image to base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Set API endpoint and credentials
      final String url = 'https://vision.googleapis.com/v1/images:annotate';
      final String apiKey =
          'AIzaSyCTEzWZeNLmHt3kICZKupyIsoZkxWT9Jhk'; // Use environment variables or secure storage

      // Prepare request body
      final requestBody = {
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'TEXT_DETECTION'},
            ],
          },
        ],
      };

      // Send request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final extractedText =
            jsonData['responses'][0]['textAnnotations'][0]['description'];

        // Process extracted text to match medicines
        List<String> extractedMedicines = extractedText.split('\n');
        List<Map<String, dynamic>> matchedMedicines = [];

        for (String medicine in extractedMedicines) {
          for (var dbMedicine in _medicines) {
            if (dbMedicine['name'].toLowerCase().contains(
              medicine.toLowerCase(),
            )) {
              matchedMedicines.add(dbMedicine);
            }
          }
        }

        // Display matched medicines
        if (matchedMedicines.isNotEmpty) {
          if (!mounted) return; // Ensure context is valid
          _showMedicinesDialog(matchedMedicines);
        } else {
          if (!mounted) return; // Ensure context is valid
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No medicines found in the prescription'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        debugPrint('Failed to process image');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing prescription: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing prescription: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMedicinesDialog(List<Map<String, dynamic>> medicines) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Matched Medicines'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  medicines
                      .map(
                        (medicine) => Text(
                          '${medicine['name']} - \$${medicine['price']}',
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _addToCart(Map<String, dynamic> medicine) {
    setState(() {
      if (_cart.containsKey(medicine['name'])) {
        _cart[medicine['name']] = _cart[medicine['name']]! + 1;
      } else {
        _cart[medicine['name']] = 1;
      }
    });
  }

  void _removeFromCart(Map<String, dynamic> medicine) {
    setState(() {
      if (_cart.containsKey(medicine['name'])) {
        if (_cart[medicine['name']]! > 1) {
          _cart[medicine['name']] = _cart[medicine['name']]! - 1;
        } else {
          _cart.remove(medicine['name']);
        }
      }
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cart: _cart, medicines: _medicines),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.store['name']}'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _navigateToCart,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                  hintText: 'Search medicines, instruments ...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.red,
                  ), // Red icon for search
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20.0,
                  ),
                ),
                onChanged: _filterMedicines,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMedicines.length,
              itemBuilder: (context, index) {
                final medicine = _filteredMedicines[index];
                return ListTile(
                  title: Text(medicine['name']),
                  subtitle: Text('Price: \$${medicine['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_cart.containsKey(medicine['name']))
                        ElevatedButton(
                          onPressed: () => _removeFromCart(medicine),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('-'),
                        ),
                      Text(
                        _cart.containsKey(medicine['name'])
                            ? _cart[medicine['name']].toString()
                            : '0',
                      ),
                      ElevatedButton(
                        onPressed: () => _addToCart(medicine),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('+'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _uploadPrescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Upload Prescription'),
            ),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> medicines;

  const CartScreen({required this.cart, required this.medicines, super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: ListView.builder(
        itemCount: widget.cart.length,
        itemBuilder: (context, index) {
          final medicineName = widget.cart.keys.elementAt(index);
          final quantity = widget.cart.values.elementAt(index);
          final medicine = widget.medicines.firstWhere(
            (m) => m['name'] == medicineName,
          );

          return ListTile(
            title: Text(medicineName),
            subtitle: Text('Price: \$${medicine['price']}'),
            trailing: Text('Total: \$${medicine['price'] * quantity}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Implement payment logic here
          // For example, using Razorpay or Stripe
          // Navigate to payment screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PaymentOptionsForMedicineScreen(
                    medicines: widget.medicines,
                    cart: widget.cart,
                  ),
            ),
          );
        },
        child: Icon(Icons.payment),
      ),
    );
  }
}
