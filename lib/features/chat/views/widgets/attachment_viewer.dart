import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
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

Directory? _appDirectory; // Cached directory reference

Future<Directory> getApplicationDirectory() async {
  if (_appDirectory != null) {
    return _appDirectory!;
  }

  _appDirectory = await getApplicationDocumentsDirectory();
  return _appDirectory!;
}

class AttachmentPreview extends StatefulWidget {
  const AttachmentPreview({
    super.key,
    required this.message,
  });
  final Message message;

  @override
  State<AttachmentPreview> createState() => _AttachmentPreviewState();
}

class _AttachmentPreviewState extends State<AttachmentPreview>
    with AutomaticKeepAliveClientMixin {
  late Future<bool> doesAttachmentExist = attachmentExists();

  @override
  bool get wantKeepAlive => true;

  Future<bool> attachmentExists() async {
    final appDir = await getApplicationDirectory();
    final fileName =
        "${widget.message.id}__${widget.message.attachment!.fileName}";
    final file = File("${appDir.path}/media/$fileName");

    if (file.existsSync()) {
      widget.message.attachment!.file = file;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final maxWidth = MediaQuery.of(context).size.width * 0.80;
    final maxHeight = MediaQuery.of(context).size.height * 0.60;
    final imgWidth = widget.message.attachment!.width ?? maxWidth;
    final imgHeight = widget.message.attachment!.height ?? 60.0;

    double width = min(imgWidth, maxWidth);
    double height = width / (imgWidth / imgHeight);
    height = min(height, maxHeight);

    return FutureBuilder(
        future: doesAttachmentExist,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return SizedBox(
              width: width,
              height: height,
            );
          }

          switch (widget.message.attachment!.type) {
            case AttachmentType.audio:
              return SizedBox(
                height: height,
                child: AttachedAudioViewer(
                  message: widget.message,
                  doesAttachmentExist: snap.data!,
                  onDownloadComplete: () => setState(() {
                    doesAttachmentExist = attachmentExists();
                  }),
                ),
              );
            case AttachmentType.document:
              return SizedBox(
                height: height + 10,
                child: AttachedDocumentViewer(
                  message: widget.message,
                  doesAttachmentExist: snap.data!,
                  onDownloadComplete: () => setState(() {
                    doesAttachmentExist = attachmentExists();
                  }),
                ),
              );
            default:
              return AttachedImageVideoViewer(
                width: width,
                height: height,
                message: widget.message,
                doesAttachmentExist: snap.data!,
                onDownloadComplete: () => setState(() {
                  doesAttachmentExist = attachmentExists();
                }),
              );
          }
        });
  }
}

class AttachedImageVideoViewer extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final Message message;
  final bool doesAttachmentExist;
  final VoidCallback onDownloadComplete;

  const AttachedImageVideoViewer({
    super.key,
    required this.width,
    required this.height,
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

  Future<void> navigateToViewer() async {
    final other = ref.read(chatControllerProvider.notifier).other;
    final sender = clientIsSender ? "You" : other.name;

    if (!mounted || file == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttachmentViewer(
          file: file!,
          message: widget.message,
          sender: sender,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAttachmentUploaded =
        widget.message.attachment!.uploadStatus == UploadStatus.uploaded;

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: navigateToViewer,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: const Color.fromARGB(150, 0, 0, 0),
                  width: widget.width,
                  height: widget.height,
                ),
                if (file != null) ...[
                  SizedBox(
                    width: widget.width,
                    height: widget.height,
                    child: Hero(
                      tag: widget.message.id,
                      child: AttachmentRenderer(
                        attachment: file!,
                        attachmentType: widget.message.attachment!.type,
                        fit: BoxFit.cover,
                        controllable: false,
                        fadeIn: true,
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
        if (!widget.doesAttachmentExist) ...[
          DownloadingAttachment(
            message: widget.message,
            onDone: widget.onDownloadComplete,
          )
        ] else if (!isAttachmentUploaded) ...[
          UploadingAttachment(
            message: widget.message,
          )
        ] else if (widget.message.attachment!.type == AttachmentType.video) ...[
          CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 209, 208, 208),
            foregroundColor: Colors.black87,
            radius: 30,
            child: GestureDetector(
              onTap: navigateToViewer,
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 50,
              ),
            ),
          )
        ],
      ],
    );
  }
}

class AttachedAudioViewer extends ConsumerStatefulWidget {
  final Message message;
  final bool doesAttachmentExist;
  final VoidCallback onDownloadComplete;

  const AttachedAudioViewer({
    super.key,
    required this.message,
    required this.doesAttachmentExist,
    required this.onDownloadComplete,
  });

  @override
  ConsumerState<AttachedAudioViewer> createState() =>
      _AttachedAudioViewerState();
}

class _AttachedAudioViewerState extends ConsumerState<AttachedAudioViewer> {
  late final File? file;
  late final User self;
  late final bool clientIsSender;
  final AudioPlayer player = AudioPlayer();
  late final Future<Duration> totalDuration = getDuration();
  double progress = 0;

  @override
  void initState() {
    file = widget.message.attachment!.file;
    self = ref.read(chatControllerProvider.notifier).self;
    clientIsSender = widget.message.senderId == self.id;
    player.onPlayerComplete.listen((event) {
      setState(() {});
    });
    player.onPositionChanged.listen((duration) async {
      final total = await totalDuration;
      setState(() {
        progress = duration.inSeconds / total.inSeconds;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> changePlayState() async {
    if (player.state == PlayerState.playing) {
      await player.pause();
    } else {
      if (player.state == PlayerState.completed) {
        await player.play(DeviceFileSource(file!.path),
            position: const Duration(seconds: 0));
      }
      await player.play(DeviceFileSource(file!.path));
    }

    setState(() {});
  }

  Future<Duration> getDuration() async {
    await player.setSourceDeviceFile(file!.path);
    return await player.getDuration() ?? const Duration();
  }

  void _updateProgress(double tapPosition) {
    RenderBox box = context.findRenderObject() as RenderBox;
    double width = box.size.width;
    int seconds = (tapPosition / width * 100).round();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await player.seek(
        Duration(seconds: seconds),
      );

      if (!mounted) return;
      setState(() {});
    });

    setState(() {});
  }

  void onProgressTapDown(TapDownDetails details) {
    _updateProgress(details.localPosition.dx - 6);
  }

  void onProgressDragUpdate(DragUpdateDetails details) {
    _updateProgress(details.localPosition.dx - 6);
  }

  @override
  Widget build(BuildContext context) {
    final bool isAttachmentUploaded =
        widget.message.attachment!.uploadStatus == UploadStatus.uploaded;
    final attachment = widget.message.attachment!;
    bool showDuration = true;

    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.iconColor
        : AppColorsLight.greyColor;

    Widget? trailing;
    if (!widget.doesAttachmentExist) {
      showDuration = false;
      trailing = DownloadingAttachment(
        message: widget.message,
        onDone: widget.onDownloadComplete,
        showSize: false,
      );
    } else if (!isAttachmentUploaded) {
      showDuration = false;
      trailing = UploadingAttachment(
        message: widget.message,
        showSize: false,
      );
    } else {
      if (player.state == PlayerState.playing) {
        trailing = SizedBox(
          width: 38,
          height: 48,
          child: IconButton(
            color: iconColor,
            onPressed: changePlayState,
            iconSize: 30,
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.pause_rounded),
          ),
        );
      } else {
        trailing = SizedBox(
          width: 38,
          height: 48,
          child: IconButton(
            color: iconColor,
            onPressed: changePlayState,
            iconSize: 30,
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        );
      }
    }

    final backgroundColor = widget.message.content.isEmpty
        ? clientIsSender
            ? Theme.of(context).custom.colorTheme.outgoingMessageBubbleColor
            : Theme.of(context).custom.colorTheme.incomingMessageBubbleColor
        : clientIsSender
            ? Theme.of(context).custom.colorTheme.outgoingEmbedColor
            : Theme.of(context).custom.colorTheme.incomingEmbedColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 248, 131, 144),
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(4.0),
            child: const Center(
              child: Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16.0),
                GestureDetector(
                  onHorizontalDragUpdate: onProgressDragUpdate,
                  onTapDown: onProgressTapDown,
                  child: SizedBox(
                    height: 12,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.0),
                                child: LinearProgressIndicator(
                                  backgroundColor: clientIsSender
                                      ? Theme.of(context)
                                          .custom
                                          .colorTheme
                                          .greyColor
                                      : null,
                                  value: progress,
                                ),
                              ),
                            ),
                            Positioned(
                              left: (constraints.maxWidth - 12) * progress,
                              child: Container(
                                width: 12.0,
                                height: 12.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .custom
                                      .colorTheme
                                      .greenColor,
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    showDuration
                        ? FutureBuilder(
                            future: totalDuration,
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return Container();
                              }
                              return Text(
                                strFormattedTime(snap.data!.inSeconds),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          )
                        : Text(
                            strFormattedSize(attachment.fileSize),
                            style: const TextStyle(fontSize: 12),
                          ),
                    Text(
                      formattedTimestamp(widget.message.timestamp, true),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [trailing],
          )
        ],
      ),
    );
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
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
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
                color: AppColorsLight.incomingMessageBubbleColor,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(blurRadius: 1, color: Color.fromARGB(80, 0, 0, 0))
                ],
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

class AttachmentViewer extends StatefulWidget {
  const AttachmentViewer({
    super.key,
    required this.file,
    required this.message,
    required this.sender,
  });
  final File file;
  final Message message;
  final String sender;

  @override
  State<AttachmentViewer> createState() => _AttachmentViewerState();
}

class _AttachmentViewerState extends State<AttachmentViewer> {
  bool showControls = true;
  SystemUiOverlayStyle currentStyle = const SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(186, 0, 0, 0),
  );

  @override
  Widget build(BuildContext context) {
    String title = widget.sender;
    String formattedTime = formattedTimestamp(widget.message.timestamp);

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: Theme.of(context).iconTheme.copyWith(
              color: Colors.white,
            ),
      ),
      child: AnnotatedRegion(
        value: currentStyle,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              InteractiveViewer(
                child: Align(
                  child: Hero(
                    tag: widget.message.id,
                    child: AttachmentRenderer(
                      attachment: widget.file,
                      attachmentType: widget.message.attachment!.type,
                      fit: BoxFit.contain,
                      controllable: true,
                    ),
                  ),
                ),
              ),
              if (showControls) ...[
                SafeArea(
                  child: Container(
                    height: 60,
                    color: const Color.fromARGB(206, 0, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: Theme.of(context)
                                        .custom
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.star_border_outlined),
                              Icon(Icons.turn_slight_right),
                              Icon(Icons.more_vert),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
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
          return const CircularProgressIndicator();
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
                return const CircularProgressIndicator();
              case TaskState.error:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => isDownloading = false);
                });
                return const CircularProgressIndicator();
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
          return const CircularProgressIndicator();
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
                return const CircularProgressIndicator();
              case TaskState.error:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onUploadError();
                  setState(() => isUploading = false);
                });
                return const CircularProgressIndicator();
              default:
                return const CircularProgressIndicator();
            }
          },
        );
      },
    );
  }
}
