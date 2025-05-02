class TestResult {
  final String id;
  final String testName;
  final String testType; // 'lab' or 'radiology'
  final DateTime date;
  final String result;
  final String? resultFileUrl;
  final bool homeCollection;
  final String? notes;

  TestResult({
    required this.id,
    required this.testName,
    required this.testType,
    required this.date,
    required this.result,
    this.resultFileUrl,
    this.homeCollection = false,
    this.notes,
  });
}
