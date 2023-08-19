import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseStorageRepoProvider =
    Provider((ref) => FirebaseStorageRepo(FirebaseStorage.instance));

class FirebaseStorageRepo {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageRepo(this.firebaseStorage);

  Future<UploadTask> uploadFileToFirebase(File file, String path) async {
    return firebaseStorage.ref().child(path).putFile(file);
  }

  Future<FullMetadata> getFileMetadata(String url) async {
    final ref = firebaseStorage.refFromURL(url);
    return await ref.getMetadata();
  }

  Future<DownloadTask> downloadFileFromFirebase(
    String url,
    String path,
  ) async {
    final ref = firebaseStorage.refFromURL(url);
    return ref.writeToFile(File(path));
  }
}
