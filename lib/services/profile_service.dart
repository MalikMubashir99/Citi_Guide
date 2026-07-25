import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<DocumentSnapshot> getUser() async {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get();
  }

  Future<void> updateUser({
    required String name,
    required String image,
  }) async {
    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .update({
      "name": name,
      "image": image,
    });
  }
}