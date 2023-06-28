import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../shared/repositories/firebase_firestore.dart';
import '../../../../shared/repositories/firebase_storage.dart';
import '../../models/message.dart';

class AttachmentViewer extends ConsumerStatefulWidget {
  const AttachmentViewer({
    super.key,
    required this.message,
  });
  final Message message;

  @override
  ConsumerState<AttachmentViewer> createState() => _AttachmentViewerState();
}

class _AttachmentViewerState extends ConsumerState<AttachmentViewer> {
  bool isAttachmentDownloading = false;
  bool isAttachmentUploading = false;

  Future<bool> attachmentExists() async {
    final appDir = await getApplicationDocumentsDirectory();

    final file =
        File("${appDir.path}/media/${widget.message.attachment!.fileName}");
    if (await file.exists()) {
      widget.message.attachment!.file = file;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool uploading = widget.message.attachment!.url == "uploading";
    final bool uploaded = widget.message.attachment!.url.isNotEmpty &&
        widget.message.attachment!.url != "uploading";

    if (widget.message.attachment!.file != null) {
      return Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.file(
              widget.message.attachment!.file!,
              fit: BoxFit.cover,
            ),
          ),
          if (!uploaded) ...[
            uploading
                ? const Center(child: CircularProgressIndicator())
                : isAttachmentUploading
                    ? UploadingImage(
                        message: widget.message,
                        onDone: () => setState(() {}),
                        onError: () =>
                            setState(() => isAttachmentUploading = false),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            isAttachmentUploading = true;
                          });
                        },
                        icon: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color.fromARGB(150, 0, 0, 0),
                          child: Icon(
                            Icons.upload,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      )
          ],
        ],
      );
    }
    return FutureBuilder(
        future: attachmentExists(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Container();
          }

          return snap.data!
              ? Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.file(
                        widget.message.attachment!.file!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (!uploaded) ...[
                      uploading
                          ? const Center(child: CircularProgressIndicator())
                          : isAttachmentUploading
                              ? UploadingImage(
                                  message: widget.message,
                                  onDone: () => setState(() {}),
                                  onError: () => setState(
                                      () => isAttachmentUploading = false),
                                )
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isAttachmentUploading = true;
                                    });
                                  },
                                  icon: const CircleAvatar(
                                    radius: 30,
                                    backgroundColor:
                                        Color.fromARGB(150, 0, 0, 0),
                                    child: Icon(
                                      Icons.upload,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                    ],
                  ],
                )
              : isAttachmentDownloading
                  ? DownloadingImage(
                      message: widget.message,
                      onDone: () => setState(() {}),
                      onError: () =>
                          setState(() => isAttachmentDownloading = false),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/landing_img.png',
                          color: Colors.teal,
                        ),
                        Center(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color.fromARGB(150, 0, 0, 0),
                            child: IconButton(
                              onPressed: () => setState(
                                  () => isAttachmentDownloading = true),
                              icon: const Icon(
                                Icons.download,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
        });
  }
}

class DownloadingImage extends ConsumerStatefulWidget {
  const DownloadingImage({
    super.key,
    required this.message,
    required this.onDone,
    required this.onError,
  });
  final Message message;
  final VoidCallback onDone;
  final VoidCallback onError;

  @override
  ConsumerState<DownloadingImage> createState() => _DownloadingImageState();
}

class _DownloadingImageState extends ConsumerState<DownloadingImage> {
  @override
  void initState() {
    if (widget.message.attachment!.url.isEmpty) {
      Navigator.of(context).pop();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(firebaseStorageRepoProvider).downloadFileFromFirebase(
            widget.message.attachment!.url,
            widget.message.id,
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final (_, downloadTask) = snapshot.data!;

        return StreamBuilder(
          stream: downloadTask.snapshotEvents,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            switch (snapshot.data!.state) {
              case TaskState.success:
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => widget.onDone());
                return Container();
              case TaskState.error:
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => widget.onError());
                return Container();
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}

class UploadingImage extends ConsumerStatefulWidget {
  const UploadingImage({
    super.key,
    required this.message,
    required this.onDone,
    required this.onError,
  });
  final Message message;
  final VoidCallback onDone;
  final VoidCallback onError;

  @override
  ConsumerState<UploadingImage> createState() => _UploadingImageState();
}

class _UploadingImageState extends ConsumerState<UploadingImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ref.read(firebaseStorageRepoProvider).uploadFileToFirebase(
              widget.message.attachment!.file!,
              "attachments/${widget.message.attachment!.fileName}",
            ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => widget.onError());
            return Container();
          }

          switch (snapshot.connectionState) {
            case ConnectionState.done:
              ref
                  .read(firebaseFirestoreRepositoryProvider)
                  .updateMessage(widget.message, {
                "status": "SENT",
                "attachment": widget.message.attachment!.toMap()
                  ..addAll({"url": snapshot.data!})
              }).then((value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onDone();
                });
              });
              return Container();
            default:
              return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
