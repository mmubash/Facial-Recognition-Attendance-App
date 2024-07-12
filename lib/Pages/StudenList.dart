import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatefulWidget {
  final String classId;

  StudentListScreen({required this.classId});

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late Future<List<Map<String, String>>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudents();
  }

  Future<List<Map<String, String>>> _fetchStudents() async {
    var classRef = FirebaseFirestore.instance.collection('classes').doc(widget.classId);
    DocumentSnapshot documentSnapshot = await classRef.get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> students = data['students'] ?? {};

      List<Map<String, String>> studentList = [];
      students.forEach((key, value) {
        String studentName = key.split(',')[0]; // Get student name from key
        String regNo = key.split(',')[1]; // Get registration number from key
        studentList.add({
          'studentName': studentName,
          'regNo': regNo,
        });
      });

      return studentList;
    } else {
      return [];
    }
  }

  Future<void> _deleteStudent(String studentKey) async {
    var classRef = FirebaseFirestore.instance.collection('classes').doc(widget.classId);
    await classRef.update({
      'students.$studentKey': FieldValue.delete()
    });
  }

  void _showDeleteDialog(String studentName, String studentKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Student'),
        content: Text('Do you want to delete $studentName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteStudent(studentKey);
              setState(() {
                _studentsFuture = _fetchStudents();
              });
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
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
      body: FutureBuilder<List<Map<String, String>>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No students found'));
          } else {
            List<Map<String, String>> studentList = snapshot.data!;
            return ListView.builder(
              itemCount: studentList.length,
              itemBuilder: (context, index) {
                String studentName = studentList[index]['studentName'] ?? 'N/A';
                String regNo = studentList[index]['regNo'] ?? 'N/A';
                String studentKey = '${studentName},${regNo}'; // Construct the key

                return Card(
                  margin: EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.blue,
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      studentName,
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Text(
                      'RegNo: $regNo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    onLongPress: () => _showDeleteDialog(studentName, studentKey),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
