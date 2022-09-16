import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sharedFirebaseRepoProvider =
    Provider((ref) => SharedFirebaseRepo(FirebaseStorage.instance));

class SharedFirebaseRepo {
  final FirebaseStorage firebaseStorage;

  SharedFirebaseRepo(this.firebaseStorage);

  Future<String> uploadFileToFirebase(File file, String path) async {
    try {
      final snap = await firebaseStorage.ref().child(path).putFile(file);
      return await snap.ref.getDownloadURL();
    } on FirebaseException {
      // handle error
      return ''; // for now
    }
  }
}
