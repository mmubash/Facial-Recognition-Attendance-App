import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'authUser.dart';


class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  TextEditingController emailController = TextEditingController();
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
                    height: 300,
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
                      SizedBox(height: 5,),
                      Image.asset("assets/cap.jpeg",height: 150,),
                      Text(
                        'Foreget Password',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Card(
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Enter Email Address',
                                contentPadding: EdgeInsets.all(8.0),
                                suffixIcon: Icon(Icons.email_outlined),
                              ),
                              controller: emailController,
                            ),
                            SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                AuthUser.resetPassword(
                                    emailAddress:emailController.text ,
                                    context: context);
                              },
                              child: Text("Forgot Password"),

                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            ),
        );
    }
}