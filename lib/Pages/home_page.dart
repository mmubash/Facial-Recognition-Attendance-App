import 'package:cli/Classes/add_class_details.dart';
import 'package:cli/Pages/StudenList.dart';
import 'package:cli/Pages/authUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import '../Attendance/AttendanceScreen.dart';
import '../face_recogination/faceRecognitionScreen.dart';
import 'loginScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> _deleteClass(BuildContext context, DocumentReference reference) async {
    // Show alert dialog for confirmation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this class?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                try {
                  await reference.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Class deleted successfully')),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete class: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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

      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddClassDetails()));
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add, color: Colors.white),
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

              return Hero(
                tag: classDocs[index].id,
                child: InkWell(
                  onLongPress: (){
                    _deleteClass(context, classDocs[index].reference);
                  },
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_){
                      return StudentListScreen(classId: classDocs[index].id);
                    }));
                  },
                  child: Column(
                    children: [
                      Card(
                        margin: EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.blue,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        className,
                                        style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'Course Code: $courseCode',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[200],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 150,
                                    margin: EdgeInsets.symmetric(vertical: 4.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FaceRecognition(
                                                    type: "asw",
                                                    classId: classDocs[index].id)));
                                      },
                                      child: Text(
                                        'Mark Attendance',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: Colors.purple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 150,
                                    margin: EdgeInsets.symmetric(vertical: 4.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AttendanceScreen(
                                                        classId:
                                                        classDocs[index].id)));
                                      },
                                      child: Text(
                                        'View Attendance List',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: Colors.purple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 150,
                                    margin: EdgeInsets.symmetric(vertical: 4.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => FaceRecognition(
                                                    type: "addNew",
                                                    classId: classDocs[index].id)));
                                      },
                                      child: Text(
                                        'Add Student',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]

                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('Mubashir'),
            accountEmail: Text('mubashorrao32@gmail.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "U",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              final GoogleSignIn googleSignIn = GoogleSignIn();
              await googleSignIn.disconnect();
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
  void _logout(BuildContext context) async {
    try {
      AuthUser.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
      print("signed out successfully");
    } catch (e) {
      // Display an error if sign-out fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: $e'),
        ),
      );
      print("Not signed out");
    }
  }
}
