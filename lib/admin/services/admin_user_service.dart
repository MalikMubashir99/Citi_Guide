// lib/admin/services/admin_user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "users";

  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  Future<void> updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getUsersByFilter({
    String? searchQuery,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThan: searchQuery + 'z');
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection(collection).doc(userId).delete();
  }

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    await _firestore.collection(collection).doc(userId).update({
      'role': role,
    });
  }

  Future<int> getUsersCount() async {
    try {
      var snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting users count: $e');
      return 0;
    }
  }

  Future<int> getActiveUsersCount() async {
    try {
      var snapshot = await _firestore
          .collection(collection)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting active users count: $e');
      return 0;
    }
  }
}