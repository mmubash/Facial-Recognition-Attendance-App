import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';

class AttendanceScreen extends StatefulWidget {
  final String classId;

  AttendanceScreen({required this.classId});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<Map<String, Map<String, String>>> _attendanceDataFuture;

  @override
  void initState() {
    super.initState();
    _attendanceDataFuture = _fetchAttendanceData();
  }

  Future<Map<String, Map<String, String>>> _fetchAttendanceData() async {
    var classRef = FirebaseFirestore.instance.collection('classes').doc(widget.classId);
    DocumentSnapshot documentSnapshot = await classRef.get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> students = data['students'] ?? {};
      Map<String, dynamic> attendance = data['attendance'] ?? {};

      // Organize attendance data by student
      Map<String, Map<String, String>> organizedData = {};
      students.forEach((key, value) {
        String studentName = key.split(',')[0]; // Get student name from key
        String regNo = key.split(',')[1]; // Get registration number from key
        organizedData[key] = {};
        attendance.forEach((date, attendanceRecord) {
          if (attendanceRecord.containsKey(key)) {
            organizedData[key]![date] = attendanceRecord[key];
          } else {
            organizedData[key]![date] = 'A'; // Absent if no record found
          }
        });
      });

      return organizedData;
    } else {
      return {};
    }
  }

  Future<void> _generateAttendanceReport(Map<String, Map<String, String>> attendanceData) async {
    List<List<String>> csvData = [];

    // Add header row
    List<String> header = ['Student Name', 'RegNo'];
    List<String> dates = attendanceData.values.first.keys.toList();
    header.addAll(dates);
    csvData.add(header);

    // Add student rows
    attendanceData.forEach((studentKey, attendance) {
      List<String> row = [studentKey.split(',')[0], studentKey.split(',')[1]];
      dates.forEach((date) {
        row.add(attendance[date] ?? 'A');
      });
      csvData.add(row);
    });

    String csv = const ListToCsvConverter().convert(csvData);

    final directory = await getExternalStorageDirectory();
    final path = directory!.path;
    final file = File('$path/attendance_report.csv');
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance report saved to $path/attendance_report.csv')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 10), // Adding a gap between AppBar and heading
            Expanded(
              child: FutureBuilder<Map<String, Map<String, String>>>(
                future: _attendanceDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No attendance data found'));
                  } else {
                    Map<String, Map<String, String>> attendanceData = snapshot.data!;
                    List<String> dates = attendanceData.values.first.keys.toList();
                    print(attendanceData);
                    List<String> students = attendanceData.keys.toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16.0,
                        headingRowColor: MaterialStateProperty.all(Colors.blue),
                        columns: [
                          DataColumn(
                            label: Container(
                              width: 150, // Adjusted width
                              child: Text(
                                'Student Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: 100, // Adjusted width
                              child: Text(
                                'RegNo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          ...dates.map((date) => DataColumn(
                            label: Container(
                              width: 100, // Adjusted width
                              child: Text(
                                date,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                        ],
                        rows: students.map((studentKey) {
                          String studentName = studentKey.split(',')[0];
                          String regNo = studentKey.split(',')[1];
                          return DataRow(cells: [
                            DataCell(Container(width: 150, child: Text(studentName))),
                            DataCell(Container(width: 100, child: Text(regNo))),
                            ...dates.map((date) {
                              String status = attendanceData[studentKey]![date] ?? 'A';
                              return DataCell(
                                Container(
                                  width: 100,
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: status == 'P' ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ]);
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var attendanceData = await _attendanceDataFuture;
                await _generateAttendanceReport(attendanceData);
              },
              child: Text('Generate Attendance Report'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
