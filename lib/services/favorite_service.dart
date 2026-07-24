import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot> getAttraction(String attractionId) {
    return FirebaseFirestore.instance
        .collection('attractions')
        .doc(attractionId)
        .get();
  }

  Future<bool> isFavorite(String attractionId) async {
    var result = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('attractionId', isEqualTo: attractionId)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<QuerySnapshot> checkFavorite(String attractionId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('attractionId', isEqualTo: attractionId)
        .get();
  }

  // Add Favorite
  Future<void> addFavorite(String attractionId) async {
    await _firestore.collection('favorites').add({
      'userId': _auth.currentUser!.uid,
      'attractionId': attractionId,
      'createdAt': Timestamp.now(),
    });
  }

  // Remove Favorite
  Future<void> removeFavorite(String favoriteId) async {
    await _firestore.collection('favorites').doc(favoriteId).delete();
  }

  // Get User Favorites
  Stream<QuerySnapshot> getFavorites() {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }

  Future<void> removeFavoriteByAttraction(String attractionId) async {
    var result = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('attractionId', isEqualTo: attractionId)
        .get();

    for (var doc in result.docs) {
      await doc.reference.delete();
    }
  }

  
}
