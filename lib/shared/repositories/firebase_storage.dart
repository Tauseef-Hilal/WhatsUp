import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final firebaseStorageRepoProvider =
    Provider((ref) => FirebaseStorageRepo(FirebaseStorage.instance));

class FirebaseStorageRepo {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageRepo(this.firebaseStorage);

  Future<String> uploadFileToFirebase(File file, String path) async {
    final snap = await firebaseStorage.ref().child(path).putFile(file);
    return await snap.ref.getDownloadURL();
  }

  Future<FullMetadata> getFileMetadata(String url) async {
    final ref = firebaseStorage.refFromURL(url);
    return await ref.getMetadata();
  }

  Future<(File, DownloadTask)> downloadFileFromFirebase(
      String url, String fileName) async {
    final ref = firebaseStorage.refFromURL(url);
    // final fileSize = (metaData.size ?? 0 / 1024) / 1024;

    final appDir = await getApplicationDocumentsDirectory();
    final path = appDir.path;

    final dir = Directory("$path/media");
    if (!(dir.existsSync())) {
      dir.createSync(recursive: true);
    }

    final file = File("$path/media/${ref.name}");

    return (file, ref.writeToFile(file));
  }
}
