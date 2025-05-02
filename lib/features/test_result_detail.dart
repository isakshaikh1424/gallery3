import 'package:puluspatient/models/test_result_model.dart'; // Import TestResult model
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

class TestResultDetailScreen extends StatelessWidget {
  final TestResult result;

  const TestResultDetailScreen({
    super.key,
    required this.result,
  }); // Fix constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(result.testName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Type: ${result.testType}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Date: ${DateFormat.yMMMd().format(result.date)}', // Fix date formatting
            ),
            const SizedBox(height: 20),
            const Text(
              'Result:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(result.result),
            if (result.resultFileUrl != null)
              ElevatedButton(
                onPressed: () => _downloadResult(result.resultFileUrl!),
                child: const Text('Download Full Report'),
              ),
            if (result.notes != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(result.notes!),
            ],
          ],
        ),
      ),
    );
  }

  void _downloadResult(String url) {
    // Implement download logic here
    print('Downloading report from $url');
  }
}
