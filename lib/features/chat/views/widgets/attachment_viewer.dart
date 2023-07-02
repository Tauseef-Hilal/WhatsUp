import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/attachment_renderers.dart';
import 'package:whatsapp_clone/theme/color_theme.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../../shared/models/user.dart';
import '../../../../shared/repositories/firebase_firestore.dart';
import '../../../../shared/repositories/firebase_storage.dart';
import '../../../../shared/utils/abc.dart';
import '../../controllers/chat_controller.dart';
import '../../models/attachement.dart';
import '../../models/message.dart';

class AttachmentPreview extends ConsumerStatefulWidget {
  const AttachmentPreview({
    super.key,
    required this.message,
  });
  final Message message;

  @override
  ConsumerState<AttachmentPreview> createState() => _AttachmentPreviewState();
}

class _AttachmentPreviewState extends ConsumerState<AttachmentPreview> {
  late Future<bool> doesAttachmentExist = attachmentExists();

  Future<bool> attachmentExists() async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        "${widget.message.id}__${widget.message.attachment!.fileName}";
    final file = File("${appDir.path}/media/$fileName");

    if (await file.exists()) {
      widget.message.attachment!.file = file;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: doesAttachmentExist,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Container();
          }

          switch (widget.message.attachment!.type) {
            case AttachmentType.image:
              return SizedBox(
                height: MediaQuery.of(context).size.width * 0.75,
                child: AttachedImageVideoViewer(
                  message: widget.message,
                  doesAttachmentExist: snap.data!,
                  onDownloadComplete: () => setState(() {
                    doesAttachmentExist = attachmentExists();
                  }),
                ),
              );
            case AttachmentType.video:
              return SizedBox(
                height: MediaQuery.of(context).size.width * 0.75,
                child: AttachedImageVideoViewer(
                  message: widget.message,
                  doesAttachmentExist: snap.data!,
                  onDownloadComplete: () => setState(() {
                    doesAttachmentExist = attachmentExists();
                  }),
                ),
              );
            case AttachmentType.audio:
              return AttachedAudioViewer(
                attachment: widget.message.attachment!,
                doesAttachmentExist: snap.data!,
              );
            default:
              return SizedBox(
                height: 70,
                child: AttachedDocumentViewer(
                  message: widget.message,
                  doesAttachmentExist: snap.data!,
                  onDownloadComplete: () => setState(() {
                    doesAttachmentExist = attachmentExists();
                  }),
                ),
              );
          }
        });
  }
}

class AttachedImageVideoViewer extends ConsumerStatefulWidget {
  final Message message;
  final bool doesAttachmentExist;
  final VoidCallback onDownloadComplete;

  const AttachedImageVideoViewer({
    super.key,
    required this.message,
    required this.doesAttachmentExist,
    required this.onDownloadComplete,
  });

  @override
  ConsumerState<AttachedImageVideoViewer> createState() =>
      _AttachedImageVideoViewerState();
}

class _AttachedImageVideoViewerState
    extends ConsumerState<AttachedImageVideoViewer> {
  late final File? file;
  late final User self;
  late final bool clientIsSender;

  @override
  void initState() {
    file = widget.message.attachment!.file;
    self = ref.read(chatControllerProvider.notifier).self;
    clientIsSender = widget.message.senderId == self.id;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAttachmentUploaded =
        widget.message.attachment!.uploadStatus == UploadStatus.uploaded;
    final attachmentType = widget.message.attachment!.type;

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            final other = ref.read(chatControllerProvider.notifier).other;
            final sender = clientIsSender ? "You" : other.name;

            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AttachmentViewer(
                  image: file!,
                  sender: sender,
                  timestamp: widget.message.timestamp,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: widget.doesAttachmentExist
                ? Hero(
                    tag: file!.path,
                    child: AttachmentRenderer(
                      attachment: file!,
                      attachmentType: attachmentType,
                      fit: BoxFit.cover,
                      controllable: false,
                    ),
                  )
                : Container(),
          ),
        ),
        if (!widget.doesAttachmentExist) ...[
          Center(
            child: DownloadingAttachment(
              message: widget.message,
              onDone: widget.onDownloadComplete,
            ),
          )
        ] else if (!isAttachmentUploaded) ...[
          Center(
            child: UploadingAttachment(
              message: widget.message,
            ),
          )
        ],
      ],
    );
  }
}

class AttachedAudioViewer extends ConsumerStatefulWidget {
  final Attachment attachment;
  final bool doesAttachmentExist;

  const AttachedAudioViewer({
    super.key,
    required this.attachment,
    required this.doesAttachmentExist,
  });

  @override
  ConsumerState<AttachedAudioViewer> createState() =>
      _AttachedAudioViewerState();
}

class _AttachedAudioViewerState extends ConsumerState<AttachedAudioViewer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AttachedDocumentViewer extends ConsumerStatefulWidget {
  final Message message;
  final bool doesAttachmentExist;
  final VoidCallback onDownloadComplete;

  const AttachedDocumentViewer({
    super.key,
    required this.message,
    required this.doesAttachmentExist,
    required this.onDownloadComplete,
  });

  @override
  ConsumerState<AttachedDocumentViewer> createState() =>
      _AttachedDocumentViewerState();
}

class _AttachedDocumentViewerState
    extends ConsumerState<AttachedDocumentViewer> {
  late final File? file;
  late final User self;
  late final bool clientIsSender;

  @override
  void initState() {
    file = widget.message.attachment!.file;
    self = ref.read(chatControllerProvider.notifier).self;
    clientIsSender = widget.message.senderId == self.id;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAttachmentUploaded =
        widget.message.attachment!.uploadStatus == UploadStatus.uploaded;
    final attachment = widget.message.attachment!;
    final ext = attachment.fileExtension;

    Widget? trailing;
    if (!widget.doesAttachmentExist) {
      trailing = DownloadingAttachment(
        message: widget.message,
        onDone: widget.onDownloadComplete,
        showSize: false,
      );
    } else if (!isAttachmentUploaded) {
      trailing = UploadingAttachment(
        message: widget.message,
        showSize: false,
      );
    }

    final backgroundColor = clientIsSender
        ? Theme.of(context).custom.colorTheme.outgoingEmbedColor
        : Theme.of(context).custom.colorTheme.incomingEmbedColor;

    String fileName = attachment.fileName;
    if (fileName.length > 27) {
      fileName = "${fileName.substring(0, 21)}...${fileName.substring(21, 28)}";
    }
    return Container(
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: ListTile(
            onTap: () async {
              if (!widget.doesAttachmentExist) return;
              await OpenFile.open(file!.path);
            },
            leading: Container(
              width: 40,
              height: 50,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 233, 245, 245),
                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Center(
                child: Text(
                  ext.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            title: Text(fileName),
            subtitle: Text("${strFormattedSize(attachment.fileSize)} · $ext"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [trailing ?? const Text("")],
            )),
      ),
    );
  }
}

class AttachmentViewer extends StatelessWidget {
  const AttachmentViewer({
    super.key,
    required this.image,
    required this.sender,
    required this.timestamp,
  });
  final File image;
  final String sender;
  final Timestamp timestamp;

  @override
  Widget build(BuildContext context) {
    String title = sender;
    String formattedTime = formattedTimestamp(timestamp);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColorsDark.appBarColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text("$title - $formattedTime",
            style: Theme.of(context).custom.textTheme.bodyText1),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("All Media"),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Align(
              child: InteractiveViewer(
                child: Hero(
                  tag: image.path,
                  child: Image.file(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: AppColorsDark.appBarColor,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      await Share.shareXFiles([XFile(image.path)]);
                    },
                    icon: const Icon(Icons.arrow_circle_up, size: 30),
                  ),
                  const Icon(Icons.draw, size: 30),
                  const Icon(Icons.star_outline, size: 30),
                  const Icon(Icons.delete, size: 30)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DownloadingAttachment extends ConsumerStatefulWidget {
  const DownloadingAttachment({
    super.key,
    required this.message,
    required this.onDone,
    this.showSize = true,
  });
  final Message message;
  final VoidCallback onDone;
  final bool showSize;

  @override
  ConsumerState<DownloadingAttachment> createState() =>
      _DownloadingAttachmentState();
}

class _DownloadingAttachmentState extends ConsumerState<DownloadingAttachment> {
  bool isDownloading = false;
  late bool clientIsSender;
  late Future<(File, DownloadTask)> downloadTaskFuture = download();

  @override
  void initState() {
    clientIsSender = ref.read(chatControllerProvider.notifier).self.id ==
        widget.message.senderId;
    super.initState();
  }

  Future<(File, DownloadTask)> download() {
    return ref.read(firebaseStorageRepoProvider).downloadFileFromFirebase(
          widget.message.attachment!.url,
          "${widget.message.id}__${widget.message.attachment!.fileName}",
        );
  }

  @override
  Widget build(BuildContext context) {
    final overlayColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(150, 0, 0, 0)
        : const Color.fromARGB(225, 255, 255, 255);

    final embedColor = clientIsSender
        ? Theme.of(context).custom.colorTheme.outgoingEmbedColor
        : Theme.of(context).custom.colorTheme.incomingEmbedColor;

    if (!isDownloading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.greenColor,
              borderRadius: BorderRadius.circular(20),
            ),
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: embedColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () => setState(() => isDownloading = true),
                  icon: Icon(
                    Icons.download_rounded,
                    color: Theme.of(context).custom.colorTheme.greenColor,
                  ),
                ),
              ),
            ),
          ),
          if (widget.showSize) ...[
            const SizedBox(height: 4.0),
            Container(
              decoration: BoxDecoration(
                color: overlayColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  strFormattedSize(widget.message.attachment!.fileSize),
                  style: TextStyle(
                    color: Theme.of(context).custom.colorTheme.greenColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ]
        ],
      );
    }

    return FutureBuilder(
      future: downloadTaskFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              isDownloading = false;
              downloadTaskFuture = download();
            });
          });
          return Container();
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final (_, downloadTask) = snapshot.data!;

        return StreamBuilder(
          stream: downloadTask.snapshotEvents,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final snapData = snapshot.data!;

            switch (snapData.state) {
              case TaskState.running:
                return CircularProgressIndicator(
                  value: snapData.bytesTransferred / snapData.totalBytes,
                );
              case TaskState.success:
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => widget.onDone());
                return Container();
              case TaskState.error:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => isDownloading = false);
                });
                return Container();
              default:
                return const CircularProgressIndicator();
            }
          },
        );
      },
    );
  }
}

class UploadingAttachment extends ConsumerStatefulWidget {
  final Message message;
  final bool showSize;

  const UploadingAttachment({
    super.key,
    required this.message,
    this.showSize = true,
  });

  @override
  ConsumerState<UploadingAttachment> createState() =>
      _UploadingAttachmentState();
}

class _UploadingAttachmentState extends ConsumerState<UploadingAttachment> {
  late bool isUploading;
  late Future<UploadTask> uploadTaskFuture = upload();
  late bool clientIsSender;

  @override
  void initState() {
    isUploading =
        widget.message.attachment!.uploadStatus == UploadStatus.uploading;
    clientIsSender = ref.read(chatControllerProvider.notifier).self.id ==
        widget.message.senderId;
    super.initState();
  }

  Future<UploadTask> upload() {
    final fileName =
        "${widget.message.id}__${widget.message.attachment!.fileName}";
    return ref.read(firebaseStorageRepoProvider).uploadFileToFirebase(
        widget.message.attachment!.file!, "attachments/$fileName");
  }

  void onUploadDone(TaskSnapshot snapshot) async {
    final url = await snapshot.ref.getDownloadURL();

    ref.read(firebaseFirestoreRepositoryProvider).updateMessage(
          widget.message,
          widget.message.toMap()
            ..addAll({
              "status": "SENT",
              "attachment": widget.message.attachment!.toMap()
                ..addAll({
                  "url": url,
                  "uploadStatus": UploadStatus.uploaded.value,
                })
            }),
        );
  }

  void onUploadError() {
    ref.read(firebaseFirestoreRepositoryProvider).updateMessage(
          widget.message,
          widget.message.toMap()
            ..addAll({
              "attachment": widget.message.attachment!.toMap()
                ..addAll({
                  "uploadStatus": UploadStatus.notUploading.value,
                })
            }),
        );
  }

  @override
  Widget build(BuildContext context) {
    final overlayColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(150, 0, 0, 0)
        : const Color.fromARGB(225, 255, 255, 255);

    final embedColor = clientIsSender
        ? Theme.of(context).custom.colorTheme.outgoingEmbedColor
        : Theme.of(context).custom.colorTheme.incomingEmbedColor;

    if (!isUploading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.greenColor,
              borderRadius: BorderRadius.circular(20),
            ),
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: embedColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () => setState(() => isUploading = true),
                  icon: Icon(
                    Icons.upload_rounded,
                    color: Theme.of(context).custom.colorTheme.greenColor,
                  ),
                ),
              ),
            ),
          ),
          if (widget.showSize) ...[
            const SizedBox(height: 4.0),
            Container(
              decoration: BoxDecoration(
                color: overlayColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  strFormattedSize(widget.message.attachment!.fileSize),
                  style: TextStyle(
                    color: Theme.of(context).custom.colorTheme.greenColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ]
        ],
      );
    }

    return FutureBuilder(
      future: uploadTaskFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onUploadError();
            setState(() {
              isUploading = false;
              uploadTaskFuture = upload();
            });
          });
          return Container();
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        return StreamBuilder(
          stream: snapshot.data!.snapshotEvents,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final snapData = snapshot.data!;

            switch (snapData.state) {
              case TaskState.running:
                return CircularProgressIndicator(
                    value: snapData.bytesTransferred / snapData.totalBytes);
              case TaskState.success:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onUploadDone(snapData);
                });
                return Container();
              case TaskState.error:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onUploadError();
                  setState(() => isUploading = false);
                });
                return Container();
              default:
                return Container();
            }
          },
        );
      },
    );
  }
}
