import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../models/attachement.dart';

class AttachmentRenderer extends StatelessWidget {
  const AttachmentRenderer({
    super.key,
    required this.attachmentType,
    required this.attachment,
    this.fit = BoxFit.none,
    this.controllable = false,
    this.compact = false,
    this.fadeIn = false,
  });

  final AttachmentType attachmentType;
  final File attachment;
  final BoxFit fit;
  final bool controllable;
  final bool compact;
  final bool fadeIn;

  @override
  Widget build(BuildContext context) {
    switch (attachmentType) {
      case AttachmentType.image:
        return ImageViewer(image: attachment, fit: fit);
      case AttachmentType.video:
        return VideoViewer(video: attachment, controllable: controllable);
      case AttachmentType.audio:
        return AudioViewer(audio: attachment, controllable: controllable);
      default:
        return DocumentViewer(
          document: attachment,
          compact: compact,
        );
    }
  }
}

class ImageViewer extends StatelessWidget {
  const ImageViewer({
    super.key,
    required this.image,
    required this.fit,
  });
  final File image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      image,
      fit: fit,
    );
  }
}

class VideoViewer extends StatefulWidget {
  const VideoViewer({
    super.key,
    required this.video,
    required this.controllable,
  });
  final File video;
  final bool controllable;

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late final VideoPlayerController videoController;
  Timer timer = Timer(Duration.zero, () {});
  bool showControls = true;

  @override
  void initState() {
    videoController = VideoPlayerController.file(widget.video);
    videoController.initialize().then((value) {
      if (widget.controllable) {
        videoController.play();
        showControls = false;
      }

      setState(() {});
    });
    videoController.addListener(playerListener);

    super.initState();
  }

  @override
  void dispose() {
    videoController.removeListener(playerListener);
    videoController.dispose();
    timer.cancel();
    super.dispose();
  }

  void playerListener() {
    if (videoController.value.position == videoController.value.duration) {
      videoController.seekTo(Duration.zero);
      setState(() {});
    }
  }

  void changePlayState() {
    if (videoController.value.isPlaying) {
      videoController.pause();
    } else {
      videoController.play();
    }

    toggleControls();
  }

  void toggleControls() {
    showControls = !showControls;
    if (timer.isActive) timer.cancel();

    timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        showControls = false;
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!videoController.value.isInitialized) {
      return SizedBox(
        width: videoController.value.size.width,
        height: videoController.value.size.height,
      );
    }

    Widget button = videoController.value.isPlaying
        ? CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 209, 208, 208),
            radius: 25,
            child: GestureDetector(
              onTap: () => changePlayState(),
              child: const Icon(
                Icons.pause_rounded,
                size: 30,
              ),
            ),
          )
        : CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 209, 208, 208),
            radius: 25,
            child: GestureDetector(
              onTap: () => changePlayState(),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 30,
              ),
            ),
          );

    return widget.controllable
        ? GestureDetector(
            onTap: toggleControls,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
                if (showControls) ...[button],
              ],
            ),
          )
        : AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          );
  }
}

class AudioViewer extends StatefulWidget {
  const AudioViewer({
    super.key,
    required this.audio,
    required this.controllable,
  });

  final File audio;
  final bool controllable;

  @override
  State<AudioViewer> createState() => _AudioViewerState();
}

class _AudioViewerState extends State<AudioViewer> {
  final player = AudioPlayer();

  @override
  void initState() {
    player.onPlayerComplete.listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void changePlayState() async {
    if (player.state == PlayerState.playing) {
      await player.pause();
    } else {
      if (player.state == PlayerState.completed) {
        await player.play(DeviceFileSource(widget.audio.path),
            position: const Duration(seconds: 0));
      }
      await player.play(DeviceFileSource(widget.audio.path));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.controllable
        ? GestureDetector(
            onTap: () => changePlayState(),
            child: Stack(
              fit: StackFit.loose,
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.music_note_rounded,
                  size: MediaQuery.of(context).size.width * 0.80,
                ),
                if (player.state != PlayerState.playing) ...[
                  CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 209, 208, 208),
                    radius: 40,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () => changePlayState(),
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        size: 50,
                      ),
                    ),
                  )
                ],
              ],
            ),
          )
        : const Center(
            child: Icon(Icons.music_note_rounded),
          );
  }
}

class DocumentViewer extends StatelessWidget {
  const DocumentViewer({
    super.key,
    required this.document,
    this.compact = false,
  });
  final File document;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    String fileName = document.path.split("/").last;
    if (fileName.length > 20) {
      fileName = "${fileName.substring(0, 15)}...${fileName.substring(15)}";
    }
    final fileSizeStr = strFormattedSize(document.lengthSync());
    final fileExtension = fileName.split(".").last;

    final compactView = Container(
      width: 40,
      height: 50,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 233, 245, 245),
        borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Center(
        child: Text(
          fileExtension.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );

    return compact
        ? compactView
        : GestureDetector(
            onTap: () async {
              await OpenFile.open(document.path);
            },
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                compactView,
                const SizedBox(
                  height: 8,
                ),
                Text(
                  fileName,
                  style: Theme.of(context)
                      .custom
                      .textTheme
                      .titleLarge
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(fileSizeStr),
              ],
            )),
          );
  }
}
