import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../../shared/models/user.dart';
import '../../../../shared/repositories/firebase_firestore.dart';
import '../../../../shared/repositories/firebase_storage.dart';
import '../../../../shared/utils/abc.dart';
import '../../../../shared/widgets/emoji_picker.dart';
import '../../controllers/chat_controller.dart';
import '../../models/attachement.dart';
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
  late Future<bool> doesAttachmentExist = attachmentExists();

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
    return FutureBuilder(
        future: doesAttachmentExist,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Container();
          }

          switch (widget.message.attachment!.type) {
            case AttachmentType.image:
              return ImageViewer(
                message: widget.message,
                doesAttachmentExist: snap.data!,
                onDownloadComplete: () => setState(() {
                  doesAttachmentExist = attachmentExists();
                }),
              );
            case AttachmentType.video:
              return VideoPlayer(
                attachment: widget.message.attachment!,
                doesAttachmentExist: snap.data!,
              );
            case AttachmentType.audio:
              return AudioPlayer(
                attachment: widget.message.attachment!,
                doesAttachmentExist: snap.data!,
              );
            default:
              return DocumentViewer(
                attachment: widget.message.attachment!,
                doesAttachmentExist: snap.data!,
              );
          }
        });
  }
}

class ImageViewer extends ConsumerStatefulWidget {
  final Message message;
  final bool doesAttachmentExist;
  final VoidCallback onDownloadComplete;

  const ImageViewer({
    super.key,
    required this.message,
    required this.doesAttachmentExist,
    required this.onDownloadComplete,
  });

  @override
  ConsumerState<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends ConsumerState<ImageViewer> {
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

    return widget.doesAttachmentExist
        ? Stack(
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
                      builder: (context) => FullScreenImage(
                        image: file!,
                        sender: sender,
                        timestamp: widget.message.timestamp,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Hero(
                    tag: file!.path,
                    child: Image.file(
                      file!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (!isAttachmentUploaded) ...[
                UploadingImage(
                  message: widget.message,
                )
              ],
            ],
          )
        : DownloadingImage(
            message: widget.message,
            onDone: widget.onDownloadComplete,
            onError: () => setState(() {}),
          );
  }
}

class VideoPlayer extends ConsumerStatefulWidget {
  final Attachment attachment;
  final bool doesAttachmentExist;

  const VideoPlayer({
    super.key,
    required this.attachment,
    required this.doesAttachmentExist,
  });

  @override
  ConsumerState<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends ConsumerState<VideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AudioPlayer extends ConsumerStatefulWidget {
  final Attachment attachment;
  final bool doesAttachmentExist;

  const AudioPlayer({
    super.key,
    required this.attachment,
    required this.doesAttachmentExist,
  });

  @override
  ConsumerState<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends ConsumerState<AudioPlayer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class DocumentViewer extends ConsumerStatefulWidget {
  final Attachment attachment;
  final bool doesAttachmentExist;

  const DocumentViewer({
    super.key,
    required this.attachment,
    required this.doesAttachmentExist,
  });

  @override
  ConsumerState<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends ConsumerState<DocumentViewer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AttachmentWidget extends ConsumerStatefulWidget {
  const AttachmentWidget({
    super.key,
    required this.attachments,
    required this.attachmentType,
  });

  final List<File> attachments;
  final AttachmentType attachmentType;

  @override
  ConsumerState<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends ConsumerState<AttachmentWidget> {
  late User self;
  late User other;
  late File current;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    self = ref.read(chatControllerProvider.notifier).self;
    other = ref.read(chatControllerProvider.notifier).other;
    controllers =
        widget.attachments.map((_) => TextEditingController()).toList();
    current = widget.attachments[0];
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorTheme.backgroundColor,
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: IconThemeData(
              color: colorTheme.iconColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Color.fromARGB(100, 0, 0, 0),
                      child: Icon(Icons.close),
                    ),
                  ),
                  trailing: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(100, 0, 0, 0),
                        child: Icon(Icons.crop),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(100, 0, 0, 0),
                        child: Icon(Icons.sticky_note_2),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(100, 0, 0, 0),
                        child: Icon(Icons.text_format_outlined),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(100, 0, 0, 0),
                        child: Icon(Icons.draw),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Image.file(
                    current,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.attachments.map(
                      (file) {
                        return GestureDetector(
                            onTap: () {
                              setState(() {
                                current = file;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Image.file(file, height: 50),
                            ));
                      },
                    ).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorTheme.appBarColor
                                    : colorTheme.backgroundColor,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: GestureDetector(
                                    onTap: ref
                                        .read(emojiPickerControllerProvider
                                            .notifier)
                                        .toggleEmojiPicker,
                                    child: const Icon(
                                      Icons.add,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: controllers[
                                        widget.attachments.indexOf(current)],
                                    maxLines: 6,
                                    minLines: 1,
                                    cursorColor: colorTheme.greenColor,
                                    cursorHeight: 20,
                                    style: Theme.of(context)
                                        .custom
                                        .textTheme
                                        .bodyText1,
                                    decoration: InputDecoration(
                                      hintText: 'Message',
                                      hintStyle: Theme.of(context)
                                          .custom
                                          .textTheme
                                          .bodyText1
                                          .copyWith(),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      InkWell(
                        onTap: () async {
                          for (var i = 0; i < controllers.length; i++) {
                            final attachedFile = widget.attachments[i];
                            String messageId = const Uuid().v4();
                            String fileName = attachedFile.path.split("/").last;
                            fileName = "${messageId}__$fileName";

                            attachedFile.copy(await ref
                                .read(firebaseStorageRepoProvider)
                                .getMediaFilePath(fileName));

                            ref
                                .read(chatControllerProvider.notifier)
                                .sendMessageWithAttachments(
                                  Message(
                                    id: messageId,
                                    content: controllers[i].text.trim(),
                                    status: MessageStatus.pending,
                                    senderId: self.id,
                                    receiverId: other.id,
                                    timestamp: Timestamp.now(),
                                    attachment: Attachment(
                                      type: widget.attachmentType,
                                      url: "",
                                      fileName: fileName,
                                      fileSize: "",
                                      file: attachedFile,
                                    ),
                                  ),
                                  self,
                                  other,
                                );
                          }

                          if (!mounted) return;
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: colorTheme.greenColor,
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  const FullScreenImage({
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
    final colorTheme = Theme.of(context).custom.colorTheme;
    String title = sender;
    String formattedTime = formattedTimestamp(timestamp);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "$title - $formattedTime",
          style: Theme.of(context)
              .custom
              .textTheme
              .bodyText1
              .copyWith(color: colorTheme.greyColor),
        ),
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
            color: colorTheme.appBarColor,
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
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    if (!isDownloading) {
      return Stack(
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
                onPressed: () => setState(() => isDownloading = true),
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
    }

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
  final Message message;

  const UploadingImage({
    super.key,
    required this.message,
  });

  @override
  ConsumerState<UploadingImage> createState() => _UploadingImageState();
}

class _UploadingImageState extends ConsumerState<UploadingImage> {
  late bool isUploading;

  @override
  void initState() {
    isUploading =
        widget.message.attachment!.uploadStatus == UploadStatus.uploading;
    super.initState();
  }

  void onUploadDone(url) {
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
    final file = widget.message.attachment!.file;
    final fileName = widget.message.attachment!.fileName;

    if (!isUploading) {
      return Center(
        child: CircleAvatar(
          radius: 30,
          backgroundColor: const Color.fromARGB(150, 0, 0, 0),
          child: IconButton(
            onPressed: () => setState(() => isUploading = true),
            icon: const Icon(
              Icons.upload,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return FutureBuilder(
      future: ref
          .read(firebaseStorageRepoProvider)
          .uploadFileToFirebase(file!, "attachments/$fileName"),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onUploadError();
            setState(() => isUploading = false);
          });
          return Container();
        }

        switch (snapshot.connectionState) {
          case ConnectionState.done:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onUploadDone(snapshot.data!);
            });
            return Container();
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
