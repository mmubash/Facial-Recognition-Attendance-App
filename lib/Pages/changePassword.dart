import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'authUser.dart';



class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  TextEditingController newPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 330,
                    color: Colors.deepPurpleAccent,
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 50,),
                      Image.asset("assets/images/travel_guide.png",height: 150,),
                      Text(
                        'Change Password',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Card(
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Enter New Password',
                                contentPadding: EdgeInsets.all(8.0),
                                suffixIcon: Icon(Icons.email_outlined),
                              ),
                              controller: newPasswordController,
                            ),
                            SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                AuthUser.updatePassword(newPassword: newPasswordController.text);
                              },
                              child: Text("Change Password"),

                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: IconButton(onPressed: (){
                  Navigator.pop(context);
                },
                  icon: Icon(Icons.arrow_back),color: Colors.white,),
              ),
            ],
           ),
        );
    }
}