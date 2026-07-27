// lib/services/user_service.dart
import 'package:app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserModel> getUser() async {
    final doc = await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get();

    return UserModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }

  Future<void> updateUser({
    required String name,
    required String phone,
    String image = '',
  }) async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({
      'name': name,
      'phone': phone,
      'image': image,
    });
  }
}