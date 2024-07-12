
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddClassDetails extends StatefulWidget {
  const AddClassDetails({Key? key}) : super(key: key);

  @override
  _AddClassDetailsState createState() => _AddClassDetailsState();
}

class _AddClassDetailsState extends State<AddClassDetails> {
  final _classNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _subjectNameController = TextEditingController();
  final Map<String, dynamic> _attendance = {};
  final Map<String, dynamic> _students = {};

  Future<void> _saveClassDetails() async {
    final className = _classNameController.text.trim();
    final courseCode = _courseCodeController.text.trim();
    final subjectName = _subjectNameController.text.trim();

    if (className.isEmpty || courseCode.isEmpty || subjectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and add at least one student')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('classes').add({
        'className': className,
        'courseCode': courseCode,
        'subjectName': subjectName,
        'students': _students,
        'attendance': _attendance
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Class details saved successfully!')),
      );
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save class details: $e')),
      );
    }
  }

  void _clearFields() {
    _classNameController.clear();
    _courseCodeController.clear();
    _subjectNameController.clear();
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _courseCodeController.dispose();
    _subjectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Class Details'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(
                labelText: 'Class Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _subjectNameController,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _courseCodeController,
              decoration: InputDecoration(
                labelText: 'Course Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _saveClassDetails,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Save Class Details',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
