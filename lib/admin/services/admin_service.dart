import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin Login
  Future<User?> login({required String email, required String password}) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  // Check Admin Role
  Future<bool> isAdmin(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('admins').doc(uid).get();

    if (doc.exists) {
      return doc['role'] == 'admin';
    }

    return false;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<int> getUsersCount() async {
    var snapshot = await _firestore.collection("users").get();
    return snapshot.docs.length;
  }

  Future<int> getCitiesCount() async {
    var snapshot = await _firestore.collection("cities").get();
    return snapshot.docs.length;
  }

  Future<int> getAttractionsCount() async {
    var snapshot = await _firestore.collection("attractions").get();
    return snapshot.docs.length;
  }

  Future<int> getHotelsCount() async {
    var snapshot = await _firestore.collection("hotels").get();
    return snapshot.docs.length;
  }

  Future<int> getRestaurantsCount() async {
    var snapshot = await _firestore.collection("restaurants").get();
    return snapshot.docs.length;
  }

  Future<int> getEventsCount() async {
    var snapshot = await _firestore.collection("events").get();
    return snapshot.docs.length;
  }
}
