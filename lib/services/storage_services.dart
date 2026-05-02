import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryServices {
  static CloudinaryServices instance = CloudinaryServices();

  final String cloudName = "dfeaec5nh";
  final String uploadPreset = "chatum";

  late CloudinaryPublic _cloudinaryPublic;

  CloudinaryServices() {
    _cloudinaryPublic = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  Future<String?> uploadUserImage(String uid, File image) async {
    try {
      CloudinaryResponse response = await _cloudinaryPublic.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: "users/$uid",
          publicId: uid,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
