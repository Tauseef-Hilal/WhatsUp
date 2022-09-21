import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseStorageRepoProvider =
    Provider((ref) => FirebaseStorageRepo(FirebaseStorage.instance));

class FirebaseStorageRepo {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageRepo(this.firebaseStorage);

  Future<String> uploadFileToFirebase(File file, String path) async {
    final snap = await firebaseStorage.ref().child(path).putFile(file);
    return await snap.ref.getDownloadURL();
  }
}
