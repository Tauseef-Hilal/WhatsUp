import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/attachment_renderers.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/painters.dart';
import 'package:whatsapp_clone/shared/repositories/isar_db.dart';
import 'package:whatsapp_clone/shared/repositories/push_notifications.dart';
import 'package:whatsapp_clone/shared/utils/storage_paths.dart';
import 'package:whatsapp_clone/theme/color_theme.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../shared/models/user.dart';
import '../../../shared/repositories/firebase_firestore.dart';
import '../../../shared/repositories/firebase_storage.dart';
import '../../../shared/utils/abc.dart';
import '../controllers/chat_controller.dart';
import '../models/attachement.dart';
import '../models/message.dart';

class AttachmentPreview extends StatefulWidget {
  const AttachmentPreview({
    super.key,
    required this.message,
    required this.width,
    required this.height,
  });

  final Message message;
  final double width;
  final double height;

  @override
  State<AttachmentPreview> createState() => _AttachmentPreviewState();
}

class _AttachmentPreviewState extends State<AttachmentPreview> {
  bool _doesAttachmentExist() {
    final fileName = widget.message.attachment!.fileName;
    final file = File(DeviceStorage.getMediaFilePath(fileName));

    if (file.existsSync()) {
      widget.message.attachment!.file = file;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.message.attachment!.type) {
      AttachmentType.audio => AttachedAudioViewer(
          message: widget.message,
          doesAttachmentExist: _doesAttachmentExist(),
          onDownloadComplete: () => setState(() {}),
        ),
      AttachmentType.voice => AttachedVoiceViewer(
          message: widget.message,
          doesAttachmentExist: _doesAttachmentExist(),
          onDownloadComplete: () => setState(() {}),
        ),
      AttachmentType.document => AttachedDocumentViewer(
          message: widget.message,
          doesAttachmentExist: _doesAttachmentExist(),
          onDownloadComplete: () => setState(() {}),
        ),
      _ => AttachedImageVideoViewer(
          width: widget.width,
          height: widget.height,
          message: widget.message,
          doesAttachmentExist: _doesAttachmentExist(),
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
            borderRadius: BorderRadius.circular(8.0),
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
            radius: 25,
            child: GestureDetector(
              onTap: navigateToViewer,
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 40,
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
  late String avatarUrl;
  final dotWidth = 12.0;

  final player = AudioPlayer();
  final progressNotifier = ValueNotifier<double>(0);
  late final durationFuture = getDuration();
  late final StreamSubscription<Duration> progressListener;
  late final StreamSubscription<void> playerStateListener;

  @override
  void initState() {
    self = ref.read(chatControllerProvider.notifier).self;
    clientIsSender = widget.message.senderId == self.id;

    progressListener = player.onPositionChanged.listen((event) async {
      final totalDuration = await durationFuture;
      progressNotifier.value =
          event.inMilliseconds / totalDuration.inMilliseconds;
    });

    playerStateListener = player.onPlayerStateChanged.listen((event) {
      if (Platform.isAndroid && event == PlayerState.completed) {
        progressNotifier.value = 0;
      }

      setState(() {});
    });

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
    playerStateListener.cancel();
    progressListener.cancel();
    progressNotifier.dispose();
    player.dispose();
    super.dispose();
  }

  Future<Duration> getDuration() async {
    final file = widget.message.attachment!.file;
    await player.setSourceDeviceFile(file!.path);
    return await player.getDuration() ?? const Duration();
  }

  void _updateProgress(BuildContext context, double tapPosition) async {
    RenderBox box = context.findRenderObject() as RenderBox;
    double width = box.size.width;
    progressNotifier.value = tapPosition / width;
    player.seek(
      Duration(
        milliseconds:
            (tapPosition / width * (await durationFuture).inMilliseconds)
                .toInt(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      if (player.state == PlayerState.playing) {
        trailing = SizedBox(
          width: 38,
          height: 40,
          child: IconButton(
            color: iconColor,
            onPressed: () async {
              await player.pause();
            },
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
            onPressed: () async {
              await player.play(
                DeviceFileSource(widget.message.attachment!.file!.path),
                position: Duration(
                  milliseconds: (progressNotifier.value *
                          (await durationFuture).inMilliseconds)
                      .toInt(),
                ),
              );
            },
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

    const maxHeight = 20.0;
    final samples = [...(widget.message.attachment!.samples ?? <double>[])];

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: progressNotifier,
                        builder: (context, val, _) => LayoutBuilder(
                          builder: (context, constraints) {
                            final maxSampleCount = constraints.maxWidth ~/ 5;

                            if (samples.length < maxSampleCount) {
                              fixLowSampleCount(
                                maxSampleCount,
                                samples,
                              );
                            }

                            final averagedSamples = getAveragedSamples(
                              samples,
                              maxSampleCount,
                            );

                            return GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                player.pause();
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
                              child: SizedBox(
                                height: maxHeight,
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    CustomPaint(
                                      painter: WaveformPainter(
                                        maxHeight: maxHeight,
                                        samples: averagedSamples,
                                        colorGetter: (i) => i / maxSampleCount <
                                                progressNotifier.value
                                            ? liveWaveColor
                                            : fixedWaveColor,
                                      ),
                                      size: Size(
                                        constraints.maxWidth,
                                        maxHeight,
                                      ),
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: progressNotifier,
                                      builder: (context, val, _) => Positioned(
                                        left: fixedDotPosition(
                                          constraints,
                                          val,
                                        ),
                                        child: Container(
                                          width: dotWidth,
                                          height: dotWidth,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: iconColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          showDuration
                              ? ValueListenableBuilder(
                                  valueListenable: progressNotifier,
                                  builder: (context, val, _) => FutureBuilder(
                                    future: durationFuture,
                                    builder: (context, snap) {
                                      String text = "00:00";
                                      if (snap.hasData) {
                                        text = timeFromSeconds(
                                          player.state == PlayerState.playing ||
                                                  val > 0 && val < 1
                                              ? (snap.data!.inSeconds * val)
                                                  .toInt()
                                              : snap.data!.inSeconds,
                                          true,
                                        );
                                      }
                                      return Text(
                                        text,
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  strFormattedSize(
                                      widget.message.attachment!.fileSize),
                                  style: const TextStyle(fontSize: 12),
                                ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: clientIsSender ? 20.0 : 0,
                            ),
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

  List<double> getAveragedSamples(List<double> samples, int maxSampleCount) {
    final averagedSamples = <double>[];
    final sampleCount = samples.length;
    final upperLimit = sampleCount - sampleCount % maxSampleCount;

    int counter = 0;
    double current = 0;
    int step = sampleCount ~/ maxSampleCount;

    for (int i = 0; i < upperLimit; i++) {
      if (counter == step) {
        averagedSamples.add(current / step);
        counter = 0;
        current = 0;
      }
      current += samples[i];
      counter++;
    }

    return averagedSamples;
  }

  void fixLowSampleCount(int maxSampleCount, List<double> samples) {
    final diff = maxSampleCount - samples.length;

    samples.insertAll(0, List.filled(diff ~/ 2, 0));
    samples.addAll(List.filled(diff ~/ 2 + diff % 2, 0));
  }

  double fixedDotPosition(BoxConstraints constraints, double val) {
    final pos = constraints.maxWidth * val;

    if (pos < 0) {
      return 0;
    } else if (pos > constraints.maxWidth - dotWidth) {
      return constraints.maxWidth - dotWidth;
    } else {
      return constraints.maxWidth * val;
    }
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
  final dotWidth = 12.0;

  final AudioPlayer player = AudioPlayer();
  late final Future<Duration> totalDuration = getDuration();
  late StreamSubscription<void> playerStatusListener;
  late StreamSubscription<Duration> progressListener;
  final progressNotifier = ValueNotifier<double>(0);

  @override
  void initState() {
    self = ref.read(chatControllerProvider.notifier).self;
    clientIsSender = widget.message.senderId == self.id;

    playerStatusListener = player.onPlayerStateChanged.listen((event) {
      if (Platform.isAndroid && event == PlayerState.completed) {
        progressNotifier.value = 0;
      }

      setState(() {});
    });

    progressListener = player.onPositionChanged.listen((duration) async {
      final total = await totalDuration;
      progressNotifier.value = duration.inSeconds / total.inSeconds;
    });

    super.initState();
  }

  @override
  void dispose() {
    playerStatusListener.cancel();
    progressListener.cancel();
    player.dispose();
    super.dispose();
  }

  void _updateProgress(BuildContext context, double tapPosition) async {
    RenderBox box = context.findRenderObject() as RenderBox;
    double width = box.size.width;
    progressNotifier.value = tapPosition / width;
    player.seek(
      Duration(
        milliseconds:
            (tapPosition / width * (await totalDuration).inMilliseconds)
                .toInt(),
      ),
    );
  }

  Future<Duration> getDuration() async {
    final file = widget.message.attachment!.file;
    await player.setSourceDeviceFile(file!.path);
    return await player.getDuration() ?? const Duration();
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
            onPressed: () async {
              await player.pause();
            },
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
            onPressed: () async {
              await player.play(
                DeviceFileSource(widget.message.attachment!.file!.path),
                position: Duration(
                  milliseconds: (progressNotifier.value *
                          (await totalDuration).inMilliseconds)
                      .toInt(),
                ),
              );
            },
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
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                onHorizontalDragUpdate: (details) {
                  player.pause();
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16.0),
                    SizedBox(
                      height: dotWidth,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: ValueListenableBuilder(
                              valueListenable: progressNotifier,
                              builder: (context, val, _) =>
                                  LinearProgressIndicator(
                                backgroundColor: clientIsSender
                                    ? const Color.fromARGB(202, 96, 125, 139)
                                    : const Color.fromARGB(117, 96, 125, 139),
                                value: val,
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: progressNotifier,
                            builder: (context, val, _) => Positioned(
                              left: fixedDotPosition(constraints, val),
                              child: Container(
                                width: dotWidth,
                                height: dotWidth,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .custom
                                      .colorTheme
                                      .greenColor,
                                ),
                              ),
                            ),
                          )
                        ],
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
                                    timeFromSeconds(
                                      snap.data!.inSeconds,
                                      true,
                                    ),
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

  double fixedDotPosition(BoxConstraints constraints, double val) {
    final pos = constraints.maxWidth * val;

    if (pos < 0) {
      return 0;
    } else if (pos > constraints.maxWidth - dotWidth) {
      return constraints.maxWidth - dotWidth;
    } else {
      return constraints.maxWidth * val;
    }
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
            if (widget.message.content.length > 10) ...[
              const Spacer(),
            ],
            trailing ?? const Text('')
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
          widget.message.attachment!.fileName,
        );
  }

  @override
  Widget build(BuildContext context) {
    final overlayColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(150, 0, 0, 0)
        : const Color.fromARGB(225, 255, 255, 255);

    if (!isDownloading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
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
                color: widget.showSize ? overlayColor : Colors.transparent,
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
                      Container(
                        decoration: BoxDecoration(
                          color: widget.showSize
                              ? overlayColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(
                          value:
                              snapData.bytesTransferred / snapData.totalBytes,
                        ),
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
    final fileName = widget.message.attachment!.fileName;
    return ref.read(firebaseStorageRepoProvider).uploadFileToFirebase(
          widget.message.attachment!.file!,
          "attachments/$fileName",
        );
  }

  void onUploadDone(TaskSnapshot snapshot) async {
    final url = await snapshot.ref.getDownloadURL();

    ref
        .read(firebaseFirestoreRepositoryProvider)
        .sendMessage(
          widget.message
            ..status = MessageStatus.sent
            ..attachment!.url = url
            ..attachment!.uploadStatus = UploadStatus.uploaded,
        )
        .then((_) async {
      await IsarDb.updateMessage(
        widget.message.id,
        status: widget.message.status,
        attachment: widget.message.attachment!
          ..url = url
          ..uploadStatus = UploadStatus.uploaded,
      );

      ref
          .read(pushNotificationsRepoProvider)
          .sendPushNotification(widget.message);
    });
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
        mainAxisSize: MainAxisSize.min,
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
                color: widget.showSize ? overlayColor : Colors.transparent,
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
                      Container(
                        decoration: BoxDecoration(
                          color: widget.showSize
                              ? overlayColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(
                          value:
                              snapData.bytesTransferred / snapData.totalBytes,
                        ),
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
