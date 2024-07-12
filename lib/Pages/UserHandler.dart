
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHandler{
  static final FirebaseFirestore  _firestore = FirebaseFirestore.instance;

  static addNewUser({required String userName,required String gmail,required String uuid}) async {
    try {
      await _firestore.collection("Users").doc(uuid).set({
        'userName': userName,
        'g-mail': gmail,
        'uuid': uuid
      });
    } catch (e) {
      print("Data Not Added");
    }
  }

}