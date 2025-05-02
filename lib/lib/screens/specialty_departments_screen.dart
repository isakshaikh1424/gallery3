import 'package:puluspatient/lib/screens/doctors_list_screen.dart';
import 'package:flutter/material.dart';

class SpecialtyDepartmentsScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;

  const SpecialtyDepartmentsScreen({required this.hospital, super.key});

  @override
  _SpecialtyDepartmentsScreenState createState() =>
      _SpecialtyDepartmentsScreenState();
}

class _SpecialtyDepartmentsScreenState
    extends State<SpecialtyDepartmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.hospital['name']} - Departments')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.hospital['departments']?.length ?? 0,
              itemBuilder: (context, index) {
                final department = widget.hospital['departments'][index];
                return ListTile(
                  title: Text(department['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                DoctorsListScreen(department: department),
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
