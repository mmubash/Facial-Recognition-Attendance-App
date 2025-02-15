import 'package:cli/Pages/signUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'authUser.dart';
import 'forgetPassword.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController gmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: null,
        body: SingleChildScrollView( // Wrap the Stack with SingleChildScrollView
            child: Stack(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 50,),
                        Image.asset("assets/cap.jpeg",height: 180,),
                        Text(
                          'Welcome',
                          style: TextStyle(fontSize: 24,color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Card(
                          child: Column(
                            children:  [
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  contentPadding: EdgeInsets.all(8.0),
                                  suffixIcon: Icon(Icons.account_circle_outlined),
                                ),
                                controller: gmailController,
                              ),
                              SizedBox(height: 5),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  contentPadding: EdgeInsets.all(8.0),
                                  suffixIcon: Icon(Icons.lock),
                                ),
                                obscureText: true,
                                controller: passwordController,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPassword()));
                                  },
                                  child: Text('Forget Password'),
                                ),
                              ),
                              SizedBox(height: 10,),
                              FloatingActionButton(
                                onPressed: () {
                                  AuthUser.signInUser(
                                      context: context,
                                      emailAddress: gmailController.text,
                                      password: passwordController.text);
                                },
                                child: Icon(Icons.arrow_forward),
                                backgroundColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0), // Set the border radius as needed
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),
                        SizedBox(
                          width:250,
                          child: ElevatedButton(
                            onPressed: () {
                              AuthUser.authenticateUserWithGoogle(context);
                            },
                            child: Text('Login With Google',
                              style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0), // Set the border radius as needed
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("You don't have an account"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupPage()));
                              },
                              child: Text('Sign up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
        );
    }
}