import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';

final firebaseStorageRepoProvider =
    Provider((ref) => FirebaseStorageRepo(FirebaseStorage.instance));

class FirebaseStorageRepo {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageRepo(this.firebaseStorage);

  Future<String> uploadFileToFirebase(File file, String path) async {
    if (!await isConnected()) {
      throw Exception("No Internet");
    }
    
    final snap = await firebaseStorage.ref().child(path).putFile(file);
    return await snap.ref.getDownloadURL();
  }

  Future<FullMetadata> getFileMetadata(String url) async {
    final ref = firebaseStorage.refFromURL(url);
    return await ref.getMetadata();
  }

  Future<(File, DownloadTask)> downloadFileFromFirebase(
      String url, String fileName) async {
    if (!await isConnected()) {
      throw Exception("No Internet");
    }
    
    final ref = firebaseStorage.refFromURL(url);
    // final fileSize = (metaData.size ?? 0 / 1024) / 1024;

    final path = await getMediaFilePath(ref.name);
    final file = File(path);

    return (file, ref.writeToFile(file));
  }

  Future<String> getMediaFilePath(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final path = appDir.path;

    final dir = Directory("$path/media");
    if (!(dir.existsSync())) {
      dir.createSync(recursive: true);
    }

    return "$path/media/$fileName";
  }
}
