import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteClass extends StatelessWidget {
  const DeleteClass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Class'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('classes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No classes found'));
          }
          final classDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: classDocs.length,
            itemBuilder: (context, index) {
              final classData = classDocs[index].data() as Map<String, dynamic>;
              final className = classData['className'] ?? 'N/A';
              final courseCode = classData['courseCode'] ?? 'N/A';
              final classTime = classData['classTime'] ?? 'N/A';
              final classDay = classData['classDays'] ?? 'N/A'; // Note the use of 'classDays'

              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        className,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Course Code: $courseCode'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class Time: $classTime'),
                          Text('Class Day: $classDay'),
                        ],
                      ),
                    ),
                    ButtonBar(
                      children: [
                        TextButton(
                          onPressed: () {
                            _deleteClass(context, classDocs[index].reference);
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteClass(BuildContext context, DocumentReference reference) async {
    try {
      await reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Class deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete class: $e')),
      );
    }
  }
}
