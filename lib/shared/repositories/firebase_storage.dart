import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';

import '../utils/storage_paths.dart';

final firebaseStorageRepoProvider =
    Provider((ref) => FirebaseStorageRepo(FirebaseStorage.instance));

class FirebaseStorageRepo {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageRepo(this.firebaseStorage);

  Future<UploadTask> uploadFileToFirebase(File file, String path) async {
    if (!await isConnected()) {
      throw Exception("No Internet");
    }

    return firebaseStorage.ref().child(path).putFile(file);
  }

  Future<FullMetadata> getFileMetadata(String url) async {
    final ref = firebaseStorage.refFromURL(url);
    return await ref.getMetadata();
  }

  Future<(File, DownloadTask)> downloadFileFromFirebase(
    String url,
    String fileName,
  ) async {
    if (!await isConnected()) {
      throw Exception("No Internet");
    }

    final ref = firebaseStorage.refFromURL(url);
    final path = "${DeviceStorage.mediaDirPath}/$fileName";
    final file = File(path);

    return (file, ref.writeToFile(file));
  }
}
