import 'package:image_picker/image_picker.dart';

class MediaServices {
  static MediaServices instance = MediaServices();

  final ImagePicker imagePicker = ImagePicker();

  Future<XFile?> pickImageFromGallery() {
    return imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);
  }
}
