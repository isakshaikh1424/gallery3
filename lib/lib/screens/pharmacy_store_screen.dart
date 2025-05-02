import 'dart:convert';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'payment_options_for_medicine_screen.dart';

class PharmacyStoreScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;

  const PharmacyStoreScreen({required this.hospital, super.key});

  @override
  _PharmacyStoreScreenState createState() => _PharmacyStoreScreenState();
}

class _PharmacyStoreScreenState extends State<PharmacyStoreScreen> {
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
  //   }
  // }

  void _filterMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedicines = _medicines;
      } else {
        _filteredMedicines =
            _medicines.where((element) {
              return element['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              );
            }).toList();
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
          'AIzaSyCTEzWZeNLmHt3kICZKupyIsoZkxWT9Jhk'; // Replace with your API key

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
            if (dbMedicine['name'].toLowerCase() == medicine.toLowerCase()) {
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
      }
    } catch (e) {
      debugPrint('Error processing prescription: $e');
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
        title: Text('${widget.hospital['name']} - Pharmacy Store'),
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
