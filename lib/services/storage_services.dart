import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageServices {
  static StorageServices instance = StorageServices();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String userImage = "user_images";

  Future<String?> uploadUserImage(String uid, File image) async {
    try {
      Reference ref = _storage.ref().child(userImage).child('$uid.jpg');
      UploadTask uploadTask = ref.putFile(image);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print("Error: $e");

      return null;
    }
  }
}
