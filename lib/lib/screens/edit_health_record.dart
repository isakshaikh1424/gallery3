import 'package:puluspatient/models/health_record.dart';
import 'package:puluspatient/repositories/health_record_repository.dart';
import 'package:flutter/material.dart';

class EditHealthRecordScreen extends StatefulWidget {
  final HealthRecord record;

  const EditHealthRecordScreen({super.key, required this.record});

  @override
  _EditHealthRecordScreenState createState() => _EditHealthRecordScreenState();
}

class _EditHealthRecordScreenState extends State<EditHealthRecordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final HealthRecordRepository repository = HealthRecordRepository();

  late String patientName;
  late String condition;

  @override
  void initState() {
    super.initState();
    patientName = widget.record.patientName;
    condition = widget.record.condition;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedRecord = HealthRecord(
        id: widget.record.id,
        patientName: patientName,
        condition: condition,
        date: widget.record.date,
      );

      await repository.updateHealthRecord(updatedRecord);
      Navigator.pop(context); // Go back after updating record.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Health Record')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: patientName,
                decoration: InputDecoration(labelText: 'Patient Name'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter patient name' : null,
                onChanged: (value) => patientName = value,
              ),
              TextFormField(
                initialValue: condition,
                decoration: InputDecoration(labelText: 'Condition'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter condition' : null,
                onChanged: (value) => condition = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Update Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
