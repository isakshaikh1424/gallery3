// lib/models/health_record.dart
class HealthRecord {
  String id;
  String patientName;
  String condition;
  DateTime date;

  HealthRecord({
    required this.id,
    required this.patientName,
    required this.condition,
    required this.date,
  });

  // Convert a HealthRecord object into a Map object for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientName': patientName,
      'condition': condition,
      'date': date.toIso8601String(),
    };
  }

  // Create a HealthRecord object from a Map object
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      patientName: map['patientName'],
      condition: map['condition'],
      date: DateTime.parse(map['date']),
    );
  }
}
