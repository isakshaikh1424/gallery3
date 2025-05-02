import 'package:puluspatient/lib/screens/edit_health_record.dart';
import 'package:puluspatient/models/health_record.dart';
import 'package:puluspatient/repositories/health_record_repository.dart';
import 'package:flutter/material.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final HealthRecordRepository repository = HealthRecordRepository();

  late Future<List<HealthRecord>> healthRecords;
  String? selectedSortOption;
  String? searchQuery;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    healthRecords = repository.getHealthRecords(null, null);
  }

  void _refreshRecords() {
    setState(() {
      healthRecords = repository.getHealthRecords(
        selectedSortOption,
        searchQuery,
      );
    });
  }

  void _onSortOptionChanged(String? value) {
    setState(() {
      selectedSortOption = value;
      _refreshRecords();
    });
  }

  void _filterRecords(String query) {
    setState(() {
      searchQuery = query.isEmpty ? null : query;
      _refreshRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search records...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.red),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                      ),
                      onChanged: _filterRecords,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _onSortOptionChanged(value),
                  icon: const Icon(Icons.sort),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'Recent First',
                          child: Text('Recent First'),
                        ),
                        const PopupMenuItem(
                          value: 'Oldest First',
                          child: Text('Oldest First'),
                        ),
                      ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<HealthRecord>>(
              future: healthRecords,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching records'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No health records found.'));
                }
                List<HealthRecord> records = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshRecords();
                  },
                  child: ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(records[index].condition),
                        subtitle: Text(
                          '${records[index].patientName} - ${records[index].date.toLocal()}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditHealthRecordScreen(
                                          record: records[index],
                                        ),
                                  ),
                                ).then((_) => _refreshRecords());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await repository.deleteHealthRecord(
                                  records[index].id,
                                );
                                _refreshRecords();
                              },
                            ),
                          ],
                        ),
                      );
                    },
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
