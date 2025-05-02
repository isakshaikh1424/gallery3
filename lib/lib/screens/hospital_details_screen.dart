import 'package:puluspatient/lib/screens/emergency_services_screen.dart';
import 'package:puluspatient/lib/screens/lab_and_scanning_screen.dart';
import 'package:puluspatient/lib/screens/pharmacy_store_screen.dart';
import 'package:puluspatient/lib/screens/specialty_departments_screen.dart';
import 'package:flutter/material.dart';

class HospitalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;

  const HospitalDetailsScreen({required this.hospital, super.key});

  @override
  _HospitalDetailsScreenState createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hospital['name'] ?? 'Hospital Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Specialty Departments'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SpecialtyDepartmentsScreen(
                              hospital: widget.hospital,
                            ),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Lab and Scanning'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                LabAndScanningScreen(hospital: widget.hospital),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Pharmacy Store'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                PharmacyStoreScreen(hospital: widget.hospital),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Emergency Services'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EmergencyServicesScreen(
                              hospital: widget.hospital,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
