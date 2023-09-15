import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../controllers/chat_controller.dart';

class ChatInputMic extends ConsumerWidget {
  const ChatInputMic({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final recordingState = ref.watch(
      chatControllerProvider.select((s) => s.recordingState),
    );

    return GestureDetector(
      onLongPress: ref.read(chatControllerProvider.notifier).startRecording,
      onLongPressUp: () {
        if (recordingState == RecordingState.notRecording) {
          return;
        }
        ref.read(chatControllerProvider.notifier).onRecordingDone();
      },
      onLongPressMoveUpdate: (details) async {
        ref.read(chatControllerProvider.notifier).onMicDragLeft(
              details.globalPosition.dx,
              MediaQuery.of(context).size.width,
            );

        ref.read(chatControllerProvider.notifier).onMicDragUp(
              details.globalPosition.dy,
              MediaQuery.of(context).size.height,
            );
      },
      child: recordingState == RecordingState.notRecording
          ? CircleAvatar(
              radius: 24,
              backgroundColor: colorTheme.greenColor,
              child: const Icon(
                Icons.mic,
                color: Colors.white,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: colorTheme.appBarColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorTheme.appBarColor,
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorTheme.greenColor,
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
