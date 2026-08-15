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

    final data = doc.data();
    print('📸 User image length: ${data?['image']?.length ?? 0}');
    print('📸 Image starts with: ${data?['image']?.substring(0, 30)}');

    return UserModel.fromFirestore(data!, doc.id);
  }

  Future<void> updateUser({
    required String name,
    required String phone,
    String image = '',
  }) async {
    Map<String, dynamic> data = {'name': name, 'phone': phone};

    // ✅ Always save image if provided
    if (image.isNotEmpty) {
      data['image'] = image;
      print('📸 Saving image to Firestore, length: ${image.length}');
    }

    await firestore.collection('users').doc(auth.currentUser!.uid).update(data);

    print('✅ User updated in Firestore');
  }

    // ✅ Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await firestore.collection('users').doc(uid).update({
      'readNotifications': FieldValue.arrayUnion([notificationId]),
    });
  }

  // ✅ Mark all as read
  Future<void> markAllNotificationsAsRead(List<String> ids) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || ids.isEmpty) return;

    await firestore.collection('users').doc(uid).update({
      'readNotifications': FieldValue.arrayUnion(ids),
    });
  }
}
