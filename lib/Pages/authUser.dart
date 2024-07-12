import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'UserHandler.dart';
import 'home_page.dart';
import 'loginScreen.dart';

class AuthUser {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final currentUser = _auth.currentUser;

  static String? userUid ;

  static  String? userName ;

  static   String? userGmail ;

  static bool isUserLogin = false;

  static void checkLoginStatus(BuildContext context) async{
    await Future.delayed(Duration(seconds: 2));

    if(currentUser!=null){
      userUid = currentUser!.uid;
      await getUserDetails();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_){
        return HomePage();
      }));
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_){
        return LoginScreen();
      }));
    }
  }

  static void createUser({required String emailAddress, required String password, required userName ,required BuildContext context}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      ).then((value){
        UserHandler.addNewUser(
            userName:userName,
            gmail: emailAddress,
            uuid: value.user!.uid);
        return value;
      });


    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showMessage(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showMessage(context, 'The account already exists for that email.');
      } else {
        _showMessage(context, 'Failed to create account. Please try again later.');
      }
    } catch (e) {
      _showMessage(context, 'Failed to create account. Please try again later.');
    }
  }

  static void signInUser({required String emailAddress, required String password, required BuildContext context}) async {
    try {

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      userUid = userCredential.user!.uid;

      await getUserDetails();

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_){
        return HomePage();
      }));

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage(context, 'No user found for that email.');
      }
      else if (e.code == 'wrong-password') {
        _showMessage(context, 'Wrong password provided for that user.');
      }
      else {
        _showMessage(context, 'Failed to sign in. Please try again later.');
      }
    } catch (e) {
      _showMessage(context, 'Failed to sign in. Please try again later.');
    }
  }

  static void resetPassword({required String emailAddress, required BuildContext context}) async {
    try {
      await _auth.sendPasswordResetEmail(email: emailAddress);
      _showMessage(context, 'We have sent you an email. Please check it.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage(context, 'No user found for that email.');
      } else {
        _showMessage(context, 'Failed to send password reset email. Please try again later.');
      }
    } catch (e) {
      _showMessage(context, 'Failed to send password reset email. Please try again later.');
    }
  }

  static void updatePassword({required String newPassword}){
    currentUser!.updatePassword(newPassword);
  }

  static void _showMessage(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<UserCredential> _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential).then((value){
      UserHandler.addNewUser(
          userName: value.user!.displayName!,
          gmail: value.user!.email!,
          uuid: value.user!.uid);
      return value;
    });

    userUid = userCredential.user!.uid;
    await getUserDetails();

    return userCredential;
  }

  static void authenticateUserWithGoogle(BuildContext context) async{
    try{
      await _signInWithGoogle();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_){
        return HomePage();
      }));
    } catch(e){
      print(e);
    }
  }

  static void logout(){
    _auth.signOut();
  }

  static getUserDetails() async{
    // Fetch user details from Firestore
    if ( userUid != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.
      collection('Users').
      where('uuid', isEqualTo: userUid)
          .limit(1)
          .get()
          .then((value) => value.docs.first);
      if (userDoc.exists) {
        userGmail = userDoc['g-mail'];
        userName = userDoc['userName']
            .toString()
            .split(' ')
            .first;
      } else {
        print('User document does not exist in Firestore.');
      }
    }
  }
}