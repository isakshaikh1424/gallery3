// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyServicesScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;

  const EmergencyServicesScreen({required this.hospital, super.key});

  @override
  _EmergencyServicesScreenState createState() =>
      _EmergencyServicesScreenState();
}

class _EmergencyServicesScreenState extends State<EmergencyServicesScreen> {
  final TextEditingController _emergencyDetailsController =
      TextEditingController();
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // Dispose of the controller to avoid memory leaks
    _emergencyDetailsController.dispose();
    super.dispose();
  }

  void _callAmbulance() async {
    try {
      final ambulanceNumber = widget.hospital['ambulanceNumber'];
      if (ambulanceNumber == null || ambulanceNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No ambulance number available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final url = 'tel:$ambulanceNumber';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to call ambulance'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calling ambulance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendEmergencyAlert() async {
    if (_emergencyDetailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter emergency details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final emergencyDetails = _emergencyDetailsController.text;
      final alertData = {
        'hospitalID': widget.hospital['id'],
        'emergencyDetails': emergencyDetails,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': "Timestamp.now()",
      };

      // await _firestore.collection('emergencyAlerts').add(alertData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Emergency Alert Sent'),
          backgroundColor: Colors.blue,
        ),
      );

      // Clear the text field after sending the alert
      _emergencyDetailsController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending emergency alert: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hospital['name']} - Emergency Services'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Call Ambulance'),
              trailing: ElevatedButton(
                onPressed: _callAmbulance,
                child: Text('Call Now'),
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Send Emergency Alert'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _emergencyDetailsController,
                  decoration: InputDecoration(
                    labelText: 'Enter Emergency Details',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              trailing: ElevatedButton(
                onPressed: _sendEmergencyAlert,
                child: Text('Send Alert'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
