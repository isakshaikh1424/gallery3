import 'package:puluspatient/models/test_result_model.dart'; // Import TestResult model
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class TestResultRepository {
  // final CollectionReference _collection = FirebaseFirestore.instance.collection(
  //   'test_results',
  // );
  //
  // Future<List<TestResult>> getTestResults(
  //   String? sortOption,
  //   String? query,
  // ) async {
  //   QuerySnapshot snapshot =
  //       await _collection
  //           .where(
  //             'patientId',
  //             isEqualTo: FirebaseAuth.instance.currentUser!.uid,
  //           )
  //           .get();
  //
  //   return snapshot.docs.map((doc) {
  //     return TestResult(
  //       id: doc.id,
  //       testName: doc['testName'],
  //       testType: doc['testType'],
  //       date:
  //           (doc['date'] as Timestamp)
  //               .toDate(), // Convert Firestore Timestamp to DateTime
  //       result: doc['result'],
  //       resultFileUrl: doc['resultFileUrl'],
  //       homeCollection: doc['homeCollection'] ?? false,
  //       notes: doc['notes'],
  //     );
  //   }).toList();
  // }
}
