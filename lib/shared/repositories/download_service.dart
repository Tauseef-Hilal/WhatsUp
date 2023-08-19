import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_storage.dart';

class DownloadService {
  final Map<String, DownloadTask> _downloadTasks = {};
  static DownloadService instance = DownloadService();

  static Future<void> download({
    required String taskId,
    required String url,
    required String path,
    required void Function(TaskSnapshot) onDownloadComplete,
    required void Function() onDownloadError,
  }) async {
    final downloadTask = await ProviderContainer()
        .read(firebaseStorageRepoProvider)
        .downloadFileFromFirebase(url, path);

    instance._downloadTasks[taskId] = downloadTask;
    downloadTask.then<void>(
      (snapshot) {
        onDownloadComplete(snapshot);
        instance._downloadTasks.remove(taskId);
      },
      onError: (_) => onDownloadError(),
    );
  }

  static Future<void> cancelDownload(String taskId) async {
    final task = instance._downloadTasks[taskId];
    if (task == null) return;

    await task.cancel();
    instance._downloadTasks.remove(taskId);
  }

  static Stream<TaskSnapshot>? getDownloadStream(String taskId) {
    final task = instance._downloadTasks[taskId];
    if (task == null) return null;

    return task.snapshotEvents;
  }
}
