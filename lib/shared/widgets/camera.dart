import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../features/chat/models/attachement.dart';
import '../../features/chat/views/attachment_sender.dart';

enum CameraType {
  video,
  photo,
}

class CameraView extends ConsumerStatefulWidget {
  const CameraView({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends ConsumerState<CameraView>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late AnimationController _animationController;

  final progressNotifier = ValueNotifier<int>(0);
  final btnSizeNotifier = ValueNotifier<double>(30);
  final flashIdxNotifier = ValueNotifier<int>(1);
  final flashIcons = {
    FlashMode.off: Icons.flash_off_rounded,
    FlashMode.auto: Icons.flash_auto_rounded,
    FlashMode.always: Icons.flash_on_rounded,
  };

  CameraType cameraType = CameraType.photo;
  bool isRecording = false;
  Timer timer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.max,
      enableAudio: true,
    )..prepareForVideoRecording();

    _controller.setFlashMode(FlashMode.off);
    _initializeControllerFuture = _controller.initialize();
    _animationController = AnimationController(
      value: 1,
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    if (timer.isActive) {
      timer.cancel();
    }

    progressNotifier.dispose();
    flashIdxNotifier.dispose();
    btnSizeNotifier.dispose();
    _animationController.dispose();
    await _controller.dispose();
  }

  void handleCaptureBtnClick() async {
    XFile file;

    if (cameraType == CameraType.photo) {
      file = await _controller.takePicture();
      if (!mounted) return;

      final result = await ref
          .read(chatControllerProvider.notifier)
          .createAttachmentsFromFiles([File(file.path)]);

      return navigateToSender(result);
    }

    if (!isRecording) {
      await _controller.startVideoRecording();
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) => progressNotifier.value = timer.tick,
      );

      return setState(() => isRecording = true);
    }

    file = await _controller.stopVideoRecording();
    timer.cancel();
    progressNotifier.value = 0;

    if (!mounted) return;
    final result = await ref
        .read(chatControllerProvider.notifier)
        .createAttachmentsFromFiles([File(file.path)]);

    navigateToSender(result);
    setState(() => isRecording = false);
  }

  void navigateToSender(List<Attachment> attachments) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttachmentMessageSender(
          attachments: attachments,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container();
                  }

                  return CameraPreview(_controller);
                },
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                        ),
                      ),
                      if (cameraType == CameraType.video) ...[
                        ValueListenableBuilder(
                          valueListenable: progressNotifier,
                          builder: (context, progress, _) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isRecording ? Colors.red : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              timeFromSeconds(progress, true),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                      ValueListenableBuilder(
                        valueListenable: flashIdxNotifier,
                        builder: (context, flashIdx, _) => IconButton(
                          onPressed: () {
                            final newIdx = (flashIdxNotifier.value + 1) %
                                flashIcons.length;

                            flashIdxNotifier.value = newIdx;
                            _controller.setFlashMode(
                              flashIcons.keys.toList()[newIdx],
                            );
                          },
                          icon: Icon(
                            flashIcons[flashIcons.keys.toList()[flashIdx]],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (!isRecording) ...[
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, _) => Transform.translate(
                        offset: Offset(
                          (cameraType == CameraType.photo ? -30 : 30) *
                              _animationController.value,
                          0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _animationController.forward(from: 0);
                                  setState(
                                    () => cameraType = CameraType.video,
                                  );
                                },
                                style: ButtonStyle(
                                  foregroundColor: MaterialStatePropertyAll(
                                    cameraType == CameraType.video
                                        ? colorTheme.yellowColor
                                        : colorTheme.greyColor,
                                  ),
                                ),
                                child: const Text("VIDEO"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _animationController.forward(from: 0);
                                  setState(
                                    () => cameraType = CameraType.photo,
                                  );
                                },
                                style: ButtonStyle(
                                  foregroundColor: MaterialStatePropertyAll(
                                    cameraType == CameraType.photo
                                        ? colorTheme.yellowColor
                                        : colorTheme.greyColor,
                                  ),
                                ),
                                child: const Text("PHOTO"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 100.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(169, 53, 53, 53),
                        child: IconButton(
                          onPressed: () {
                            ref
                                .read(chatControllerProvider.notifier)
                                .pickAttachmentsFromGallery(context);
                          },
                          icon: const Icon(
                            Icons.photo_library_rounded,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 3,
                            color: const Color.fromARGB(255, 235, 234, 234),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: btnSizeNotifier,
                          builder: (context, val, _) => CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: isRecording ? val : 30,
                            child: GestureDetector(
                              onTapDown: (details) {
                                btnSizeNotifier.value = 24;
                              },
                              onTapUp: (_) {
                                handleCaptureBtnClick();
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () => btnSizeNotifier.value = 30,
                                );
                              },
                              onLongPressUp: () {
                                handleCaptureBtnClick();
                                btnSizeNotifier.value = 31;
                              },
                              onLongPress: () {
                                setState(() {
                                  cameraType = CameraType.video;
                                });

                                handleCaptureBtnClick();
                                btnSizeNotifier.value = 50;
                              },
                              child: isRecording && btnSizeNotifier.value == 30
                                  ? CircleAvatar(
                                      radius: val,
                                      backgroundColor: Colors.transparent,
                                      child: Icon(
                                        Icons.square_rounded,
                                        color: Colors.red,
                                        size: val,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: val,
                                      backgroundColor:
                                          cameraType == CameraType.photo
                                              ? const Color.fromARGB(
                                                  255,
                                                  235,
                                                  234,
                                                  234,
                                                )
                                              : Colors.red,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(
                          169,
                          53,
                          53,
                          53,
                        ),
                        child: IconButton(
                          onPressed: () {
                            _controller.setDescription(
                              widget.cameras
                                  .where((element) =>
                                      element != _controller.description)
                                  .first,
                            );
                          },
                          icon: const Icon(Icons.loop),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
