import 'package:puluspatient/lib/screens/book_test_screen.dart';
import 'package:flutter/material.dart';

class LabAndScanningScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;

  const LabAndScanningScreen({required this.hospital, super.key});

  @override
  _LabAndScanningScreenState createState() => _LabAndScanningScreenState();
}

class _LabAndScanningScreenState extends State<LabAndScanningScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _tests = [];
  List<Map<String, dynamic>> _filteredTests = [];

  @override
  void initState() {
    super.initState();
    _tests = widget.hospital['tests'] ?? [];
    _filteredTests = _tests;
  }

  void _filterTests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTests = _tests;
      } else {
        _filteredTests =
            _tests
                .where(
                  (element) => element['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hospital['name']} - Lab & Scanning'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Tests',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterTests,
            ),
          ),
          Expanded(
            child:
                _filteredTests.isEmpty
                    ? Center(child: Text('No tests found'))
                    : ListView.builder(
                      itemCount: _filteredTests.length,
                      itemBuilder: (context, index) {
                        final test = _filteredTests[index];
                        return ListTile(
                          title: Text(test['name']),
                          subtitle: Text(test['description']),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookTestScreen(test),
                                ),
                              );
                            },
                            child: Text('Book Test'),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
