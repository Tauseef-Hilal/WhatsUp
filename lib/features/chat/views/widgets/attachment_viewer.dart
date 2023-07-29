import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart' as aw;
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/attachment_renderers.dart';
import 'package:whatsapp_clone/shared/repositories/isar_db.dart';
import 'package:whatsapp_clone/shared/repositories/push_notifications.dart';
import 'package:whatsapp_clone/shared/utils/storage_paths.dart';
import 'package:whatsapp_clone/theme/color_theme.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../../shared/models/user.dart';
import '../../../../shared/repositories/firebase_firestore.dart';
import '../../../../shared/repositories/firebase_storage.dart';
import '../../../../shared/utils/abc.dart';
import '../../controllers/chat_controller.dart';
import '../../models/attachement.dart';
import '../../models/message.dart';

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
  bool attachmentExists() {
    final messageId = widget.message.id;
    final attachmentName = widget.message.attachment!.fileName;
    final fileName = "${messageId}__$attachmentName";
    final file = File("${DeviceStorage.appDocsDirPath}/media/$fileName");

    if (file.existsSync()) {
      widget.message.attachment!.file = file;
      return true;
    }

    return false;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.80;
    final maxHeight = MediaQuery.of(context).size.height * 0.60;
    final imgWidth = widget.message.attachment!.width ?? 1;
    final imgHeight = widget.message.attachment!.height ?? 1;

    double width = min(imgWidth, maxWidth);
    double height = width / (imgWidth / imgHeight);
    height = min(height, maxHeight);

    final attachmentType = widget.message.attachment!.type;
    return switch (attachmentType) {
      AttachmentType.audio => AttachedAudioViewer(
          message: widget.message,
          doesAttachmentExist: attachmentExists(),
          onDownloadComplete: () => setState(() {}),
        ),
      AttachmentType.voice => AttachedVoiceViewer(
          message: widget.message,
          doesAttachmentExist: attachmentExists(),
          onDownloadComplete: () => setState(() {}),
        ),
      AttachmentType.document => AttachedDocumentViewer(
          message: widget.message,
          doesAttachmentExist: attachmentExists(),
          onDownloadComplete: () => setState(() {}),
        ),
      _ => AttachedImageVideoViewer(
          width: width,
          height: height,
          message: widget.message,
          doesAttachmentExist: attachmentExists(),
          onDownloadComplete: () => setState(() {}),
        )
    };
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
  late final String sender;

  @override
  void initState() {
    final self = ref.read(chatControllerProvider.notifier).self;
    final other = ref.read(chatControllerProvider.notifier).other;
    final clientIsSender = widget.message.senderId == self.id;
    sender = clientIsSender ? "You" : other.name;

    super.initState();
  }

  Future<void> navigateToViewer() async {
    final file = widget.message.attachment!.file;

    if (!mounted || file == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttachmentViewer(
          file: file,
          message: widget.message,
          sender: sender,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.message.attachment!.file;
    final bool isAttachmentUploaded =
        widget.message.attachment!.uploadStatus == UploadStatus.uploaded;

    final background = sender == "You"
        ? const Color.fromARGB(255, 0, 0, 0)
        : const Color.fromARGB(150, 0, 0, 0);

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
                  color: background,
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
                        attachment: file,
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
            autoDownload:
                widget.message.attachment!.type == AttachmentType.image,
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

class AttachedVoiceViewer extends ConsumerStatefulWidget {
  final Message message;
  final bool doesAttachmentExist;
  final VoidCallback onDownloadComplete;

  const AttachedVoiceViewer({
    super.key,
    required this.message,
    required this.doesAttachmentExist,
    required this.onDownloadComplete,
  });

  @override
  ConsumerState<AttachedVoiceViewer> createState() =>
      _AttachedVoiceViewerState();
}

class _AttachedVoiceViewerState extends ConsumerState<AttachedVoiceViewer> {
  late final User self;
  late final bool clientIsSender;
  final aw.PlayerController player = aw.PlayerController();
  late String avatarUrl;
  double progress = 0;
  bool ranOnce = false;
  bool extractionDone = false;

  @override
  void initState() {
    final file = widget.message.attachment!.file;
    self = ref.read(chatControllerProvider.notifier).self;
    clientIsSender = widget.message.senderId == self.id;

    if (file != null) {
      player.preparePlayer(path: file.path);
      player.setRefresh(true);

      player.onPlayerStateChanged.listen((event) {
        if (!mounted) return;
        setState(() {});
      });
    }

    if (clientIsSender) {
      avatarUrl = self.avatarUrl;
    } else {
      final other = ref.read(chatControllerProvider.notifier).other;
      avatarUrl = other.avatarUrl;
    }

    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> changePlayState() async {
    if (player.playerState.isPlaying) {
      await player.pausePlayer();
    } else {
      await player.startPlayer(finishMode: aw.FinishMode.pause);
    }
  }

  void _updateProgress(BuildContext context, double tapPosition) async {
    RenderBox box = context.findRenderObject() as RenderBox;
    double width = box.size.width;

    int position = (tapPosition / width * player.maxDuration).round();

    bool isPlaying = true;
    if (player.playerState != aw.PlayerState.playing) {
      await player.setVolume(0);
      await player.startPlayer(finishMode: aw.FinishMode.pause);
      isPlaying = false;
    }
    await player.seekTo(position);

    if (!isPlaying) {
      Future.delayed(const Duration(milliseconds: 100), () async {
        if (!mounted) return;
        await player.pausePlayer();
        await player.setVolume(1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.message.attachment!.file;
    final bool isAttachmentUploaded =
        widget.message.attachment!.uploadStatus == UploadStatus.uploaded;
    bool showDuration = true;

    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 235, 234, 234)
        : AppColorsLight.greyColor;

    final micColor = widget.message.status == MessageStatus.seen
        ? AppColorsLight.blueColor
        : iconColor;

    Widget? trailing;
    if (!widget.doesAttachmentExist) {
      showDuration = false;
      trailing = DownloadingAttachment(
        message: widget.message,
        onDone: widget.onDownloadComplete,
        showSize: false,
        autoDownload: true,
      );
    } else if (!isAttachmentUploaded) {
      showDuration = false;
      trailing = UploadingAttachment(
        message: widget.message,
        showSize: false,
      );
    } else {
      if (player.playerState.isPlaying) {
        trailing = SizedBox(
          width: 38,
          height: 30,
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
          height: 30,
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

    final fixedWaveColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white38
        : Colors.black26;

    final liveWaveColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(avatarUrl),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(
                    Icons.mic_rounded,
                    color: micColor,
                    size: 20,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                trailing,
                const SizedBox(width: 4.0),
                Expanded(
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (!extractionDone && file != null) {
                            final sampleCount = const aw.PlayerWaveStyle()
                                .getSamplesForWidth(constraints.maxWidth);
                            player.extractWaveformData(
                                path: file.path, noOfSamples: sampleCount);

                            extractionDone = ranOnce;
                          }
                          return GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              _updateProgress(
                                context,
                                details.localPosition.dx,
                              );
                            },
                            onTapUp: (details) {
                              _updateProgress(
                                context,
                                details.localPosition.dx,
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                aw.AudioFileWaveforms(
                                  size: Size(constraints.maxWidth, 30),
                                  playerController: player,
                                  waveformType: aw.WaveformType.fitWidth,
                                  enableSeekGesture: false,
                                  playerWaveStyle: aw.PlayerWaveStyle(
                                    showSeekLine: false,
                                    fixedWaveColor: fixedWaveColor,
                                    liveWaveColor: liveWaveColor,
                                  ),
                                ),
                                StatefulBuilder(
                                  builder: (context, setState_) {
                                    if (!ranOnce) {
                                      initSeeker(setState_);
                                      ranOnce = true;
                                    }

                                    return Positioned(
                                      left: (constraints.maxWidth * progress) %
                                          constraints.maxWidth,
                                      child: Container(
                                        width: 12.0,
                                        height: 12.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: micColor,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          showDuration
                              ? Text(
                                  timeFromSeconds(
                                      player.maxDuration ~/ 1000, true),
                                  style: const TextStyle(fontSize: 12),
                                )
                              : Text(
                                  strFormattedSize(
                                      widget.message.attachment!.fileSize),
                                  style: const TextStyle(fontSize: 12),
                                ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Text(
                              formattedTimestamp(
                                widget.message.timestamp,
                                true,
                                Platform.isIOS,
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void initSeeker(StateSetter setState_) {
    player.onCurrentDurationChanged.listen((duration) {
      if (!mounted) return;
      setState_(() {
        progress = duration / player.maxDuration;
      });
    });
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
  late final User self;
  late final bool clientIsSender;
  late final Future<Duration> totalDuration = getDuration();
  late String avatarUrl;
  final AudioPlayer player = AudioPlayer();
  double progress = 0;

  @override
  void initState() {
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
    final file = widget.message.attachment!.file;

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
    final file = widget.message.attachment!.file;
    await player.setSourceDeviceFile(file!.path);
    return await player.getDuration() ?? const Duration();
  }

  void _updateProgress(BuildContext context, double tapPosition) async {
    RenderBox box = context.findRenderObject() as RenderBox;
    double width = box.size.width;
    progress = tapPosition / width;

    int seconds = (progress * (await totalDuration).inSeconds).round();
    await player.seek(Duration(seconds: seconds));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isAttachmentUploaded =
        widget.message.attachment!.uploadStatus == UploadStatus.uploaded;
    final attachment = widget.message.attachment!;
    bool showDuration = true;

    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
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
          height: 40,
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
          height: 40,
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 248, 131, 144),
              shape: BoxShape.circle,
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
                SizedBox(
                  height: 12,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2.0),
                              child: GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  _updateProgress(
                                    context,
                                    details.localPosition.dx,
                                  );
                                },
                                onTapUp: (details) {
                                  _updateProgress(
                                    context,
                                    details.localPosition.dx,
                                  );
                                },
                                child: LinearProgressIndicator(
                                  backgroundColor: clientIsSender
                                      ? const Color.fromARGB(202, 96, 125, 139)
                                      : const Color.fromARGB(117, 96, 125, 139),
                                  value: progress,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: (constraints.maxWidth * progress) %
                                constraints.maxWidth,
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
                                timeFromSeconds(snap.data!.inSeconds, true),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          )
                        : Text(
                            strFormattedSize(attachment.fileSize),
                            style: const TextStyle(fontSize: 12),
                          ),
                    Text(
                      formattedTimestamp(
                        widget.message.timestamp,
                        true,
                        Platform.isIOS,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [trailing],
          ),
          const SizedBox(width: 4.0),
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
  late final User self;
  late final bool clientIsSender;

  @override
  void initState() {
    self = ref.read(chatControllerProvider.notifier).self;
    clientIsSender = widget.message.senderId == self.id;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.message.attachment!.file;
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
    final len = fileName.length;
    if (fileName.length > 20) {
      fileName =
          "${fileName.substring(0, 15)}....${fileName.substring(len - 6, len)}";
    }

    return GestureDetector(
      onTap: () async {
        if (!widget.doesAttachmentExist) return;
        await OpenFile.open(file!.path);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 40,
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
                    fontSize: 9,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    "${strFormattedSize(attachment.fileSize)} · $ext",
                    style:
                        const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [trailing ?? const Text("")],
            ),
          ],
        ),
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
          body: GestureDetector(
            onTap: () => setState(() {
              showControls = !showControls;
              if (showControls) {
                setState(() {
                  currentStyle = const SystemUiOverlayStyle(
                    statusBarColor: Color.fromARGB(206, 0, 0, 0),
                  );
                });
                return;
              }
              setState(() {
                currentStyle = const SystemUiOverlayStyle(
                  statusBarColor: AppColorsDark.appBarColor,
                );
              });
            }),
            child: Stack(
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
                                          .titleLarge
                                          .copyWith(color: Colors.white),
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
      ),
    );
  }
}

class DownloadingAttachment extends ConsumerStatefulWidget {
  const DownloadingAttachment({
    super.key,
    required this.message,
    required this.onDone,
    this.autoDownload = false,
    this.showSize = true,
  });
  final Message message;
  final VoidCallback onDone;
  final bool showSize;
  final bool autoDownload;

  @override
  ConsumerState<DownloadingAttachment> createState() =>
      _DownloadingAttachmentState();
}

class _DownloadingAttachmentState extends ConsumerState<DownloadingAttachment> {
  late bool isDownloading;
  late bool clientIsSender;
  late Future<(File, DownloadTask)> downloadTaskFuture;

  @override
  void initState() {
    isDownloading = widget.autoDownload;
    if (isDownloading) {
      downloadTaskFuture = download();
    }

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

    if (!isDownloading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              downloadTaskFuture = download();
              setState(() => isDownloading = true);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Theme.of(context).custom.colorTheme.greenColor,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download_rounded,
                color: Theme.of(context).custom.colorTheme.greenColor,
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
            if (!mounted) return;
            setState(() => isDownloading = false);
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
                return GestureDetector(
                  onTap: () {
                    downloadTask.cancel();
                    setState(() => isDownloading = false);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: snapData.bytesTransferred / snapData.totalBytes,
                      ),
                      const Icon(Icons.close),
                    ],
                  ),
                );
              case TaskState.success:
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => widget.onDone());
                return const CircularProgressIndicator();
              case TaskState.error:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
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
  late Future<UploadTask> uploadTaskFuture;
  late bool clientIsSender;

  @override
  void initState() {
    isUploading =
        widget.message.attachment!.uploadStatus == UploadStatus.uploading;
    if (isUploading) {
      uploadTaskFuture = upload();
    }

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

    await ref.read(firebaseFirestoreRepositoryProvider).sendMessage(
          widget.message
            ..status = MessageStatus.sent
            ..attachment!.url = url
            ..attachment!.uploadStatus = UploadStatus.uploaded,
        );

    await IsarDb.updateMessage(
      widget.message.id,
      status: widget.message.status,
      attachment: widget.message.attachment!
        ..url = url
        ..uploadStatus = UploadStatus.uploaded,
    );

    await ref
        .read(pushNotificationsRepoProvider)
        .sendPushNotification(widget.message);
  }

  Future<void> stopAutoUpload() async {
    if (widget.message.attachment!.uploadStatus == UploadStatus.notUploading) {
      return;
    }

    await IsarDb.updateMessage(
      widget.message.id,
      attachment: widget.message.attachment!
        ..uploadStatus = UploadStatus.notUploading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final overlayColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(150, 0, 0, 0)
        : const Color.fromARGB(225, 255, 255, 255);

    if (!isUploading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              uploadTaskFuture = upload();
              setState(() => isUploading = true);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Theme.of(context).custom.colorTheme.greenColor,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.upload_rounded,
                color: Theme.of(context).custom.colorTheme.greenColor,
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
            stopAutoUpload();
            if (!mounted) return;
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

        final uploadTask = snapshot.data!;
        return StreamBuilder(
          stream: uploadTask.snapshotEvents,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final snapData = snapshot.data!;

            switch (snapData.state) {
              case TaskState.running:
                return GestureDetector(
                  onTap: () async {
                    await uploadTask.cancel();
                    await stopAutoUpload();
                    setState(() => isUploading = false);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: snapData.bytesTransferred / snapData.totalBytes,
                      ),
                      const Icon(Icons.close),
                    ],
                  ),
                );
              case TaskState.success:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onUploadDone(snapData);
                });
                return const CircularProgressIndicator();
              case TaskState.error:
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await stopAutoUpload();
                  if (!mounted) return;
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
