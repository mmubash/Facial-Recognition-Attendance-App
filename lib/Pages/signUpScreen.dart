import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'authUser.dart';
import 'loginScreen.dart';



class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  TextEditingController nameController = TextEditingController();
  TextEditingController gmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  labelText: 'User Name',
                                  contentPadding: EdgeInsets.all(8.0),
                                  suffixIcon: Icon(Icons.account_circle_outlined),
                                ),
                                controller: nameController,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  contentPadding: EdgeInsets.all(8.0),
                                  suffixIcon: Icon(Icons.email_outlined),
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
                              SizedBox(height: 10,),
                              TextButton(
                                onPressed: () {
                                  AuthUser.createUser(
                                      context: context,
                                      emailAddress: gmailController.text,
                                      password: passwordController.text,
                                      userName: nameController.text
                                  );
                                },
                                child: Text("Sign up", style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(Colors.deepPurpleAccent)
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
                            Text('You have an account?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                              },
                              child: Text('Sign in'),
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