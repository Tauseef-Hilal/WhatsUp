import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/recording_visualiser.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../../shared/utils/abc.dart';
import '../../../../theme/color_theme.dart';
import '../../controllers/chat_controller.dart';

class VoiceRecorderField extends ConsumerWidget {
  const VoiceRecorderField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder(
                stream:
                    ref.read(chatControllerProvider).soundRecorder.onProgress,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Icon(
                            Icons.mic,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        Text(
                          "0:00",
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorTheme.iconColor
                                    : colorTheme.textColor2,
                          ),
                        ),
                      ],
                    );
                  }

                  final data = snapshot.data!;
                  final duration = data.duration;
                  final showMic = duration.inMilliseconds % 1000 > 500;
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Icon(
                          Icons.mic,
                          color: showMic ? Colors.red : Colors.transparent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(
                        width: 12.0,
                      ),
                      Text(
                        timeFromSeconds(
                          duration.inSeconds,
                          true,
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colorTheme.iconColor
                              : colorTheme.textColor2,
                        ),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
          Text(
            "◀ Slide to cancel",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? colorTheme.iconColor
                  : colorTheme.textColor2,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceRecorder extends ConsumerWidget {
  const VoiceRecorder({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final recordingState = ref.watch(
      chatControllerProvider.select((s) => s.recordingState),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.appBarColor
          : AppColorsLight.incomingMessageBubbleColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RecordingVisualiser(),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  ref.read(chatControllerProvider.notifier).cancelRecording();
                },
                child: const Icon(
                  Icons.delete,
                  size: 36,
                ),
              ),
              InkWell(
                onTap: () {
                  if (recordingState == RecordingState.recordingLocked) {
                    ref.read(chatControllerProvider.notifier).pauseRecording();
                  } else {
                    ref.read(chatControllerProvider.notifier).resumeRecording();
                  }
                },
                child: recordingState == RecordingState.recordingLocked
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.red),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pause_rounded,
                          color: Colors.red,
                          size: 30,
                        ),
                      )
                    : const Icon(
                        Icons.mic,
                        color: Colors.red,
                        size: 30,
                      ),
              ),
              InkWell(
                onTap: () async {
                  ref.read(chatControllerProvider.notifier).onRecordingDone();
                },
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: colorTheme.greenColor,
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
