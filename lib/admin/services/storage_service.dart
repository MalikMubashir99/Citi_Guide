import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {

  final FirebaseStorage storage =
      FirebaseStorage.instance;

  Future<String> uploadImage(File image) async {

    String fileName =
        DateTime.now().millisecondsSinceEpoch.toString();

    Reference ref =
        storage.ref().child("attractions/$fileName.jpg");

    UploadTask uploadTask =
        ref.putFile(image);

    TaskSnapshot snapshot =
        await uploadTask;

    return await snapshot.ref.getDownloadURL();

  }

}