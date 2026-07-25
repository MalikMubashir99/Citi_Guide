import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // ✅ Upload image with custom folder path
  Future<String> uploadImage(
    File image, {
    String folder = 'attractions',
  }) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage.ref().child("$folder/$fileName.jpg");
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // ✅ Upload image with custom name
  Future<String> uploadImageWithName(
    File image,
    String fileName, {
    String folder = 'attractions',
  }) async {
    Reference ref = storage.ref().child("$folder/$fileName.jpg");
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // ✅ Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}