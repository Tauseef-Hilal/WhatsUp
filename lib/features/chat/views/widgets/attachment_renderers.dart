import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/color_theme.dart';
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
  });

  final AttachmentType attachmentType;
  final File attachment;
  final BoxFit fit;
  final bool controllable;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    switch (attachmentType) {
      case AttachmentType.image:
        return ImageViewer(image: attachment, fit: fit);
      case AttachmentType.video:
        return VideoViewer(video: attachment, controllable: controllable);
      case AttachmentType.document:
        return DocumentViewer(
          document: attachment,
          compact: compact,
        );
      default:
        return const Placeholder();
    }
  }
}

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.image, required this.fit});
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

  @override
  void initState() {
    videoController = VideoPlayerController.file(widget.video);
    videoController.initialize().then((value) => setState(() {}));
    videoController.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  void changePlayState() {
    if (videoController.value.isPlaying) {
      videoController.pause();
    } else {
      videoController.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!videoController.value.isInitialized) return Container();

    return widget.controllable
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
                videoController.value.isPlaying
                    ? IconButton(
                        onPressed: () => changePlayState(),
                        icon: const Icon(Icons.pause),
                      )
                    : IconButton(
                        onPressed: () => changePlayState(),
                        icon: const Icon(Icons.play_arrow),
                      ),
              ],
            ),
          )
        : Center(
            child: AspectRatio(
              aspectRatio: videoController.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
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
    if (compact) {
      return const Center(
        child: Icon(
          Icons.file_present,
          color: AppColorsDark.iconColor,
        ),
      );
    }

    String fileName = document.path.split("/").last;
    if (fileName.length > 20) {
      fileName = "${fileName.substring(0, 15)}...${fileName.substring(15)}";
    }
    final fileSizeStr = strFormattedSize(document.lengthSync());

    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.file_present,
          size: 50,
          color: AppColorsDark.iconColor,
        ),
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
    ));
  }
}
