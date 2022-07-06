import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<String> uploadImage(XFile image) async {
  UploadTask uploadTask;

  Reference ref = FirebaseStorage.instance.ref().child(image.name);

  final metadata = SettableMetadata(
    contentType: image.mimeType,
    customMetadata: {'picked-file-path': image.path},
  );

  uploadTask = ref.putFile(File(image.path), metadata);

  await Future.value(uploadTask);

  return Future.value(ref.getDownloadURL());
}
