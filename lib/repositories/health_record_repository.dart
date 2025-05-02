import 'package:puluspatient/models/health_record.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecordRepository {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addHealthRecord(HealthRecord record) async {
 /*   DocumentReference docRef = await _firestore
        .collection('health_records')
        .add(record.toMap());
    record.id = docRef.id; // Save Firestore-generated ID to the record*/
  }

  Future<List<HealthRecord>> getHealthRecords([
    String? sortBy,
    String? conditionFilter,
  ]) async {
    // Query query = _firestore.collection('health_records');
    //
    // // Apply filters if provided
    // if (conditionFilter != null && conditionFilter.isNotEmpty) {
    //   query = query.where('condition', isEqualTo: conditionFilter);
    // }

    // Apply sorting based on selected option
   /* switch (sortBy) {
      case 'Recent First':
        query = query.orderBy('date', descending: true);
        break;
      case 'Oldest First':
        query = query.orderBy('date', descending: false);
        break;
      default:
        break; // No sorting applied if no option is selected.
    }*/

  /*  final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include Firestore document ID in the record
      return HealthRecord.fromMap(data);
    }).toList();*/
    return List.empty();
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    // await _firestore
    //     .collection('health_records')
    //     .doc(record.id)
    //     .update(record.toMap());
  }

  Future<void> deleteHealthRecord(String id) async {
    // await _firestore.collection('health_records').doc(id).delete();
  }
}
