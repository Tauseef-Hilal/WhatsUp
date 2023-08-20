import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class CustomEmojiPicker extends ConsumerWidget {
  const CustomEmojiPicker({
    super.key,
    required this.textController,
    this.afterEmojiPlaced,
  });

  final TextEditingController textController;
  final void Function(Emoji emoji)? afterEmojiPlaced;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: EmojiPicker(
        textEditingController: textController,
        onEmojiSelected: (_, emoji) => afterEmojiPlaced?.call(emoji),
        config: Config(
          columns: 8,
          emojiSizeMax: 28,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          gridPadding: EdgeInsets.zero,
          initCategory: Category.SMILEYS,
          bgColor: colorTheme.backgroundColor,
          indicatorColor: Theme.of(context).brightness == Brightness.dark
              ? colorTheme.indicatorColor
              : colorTheme.greenColor,
          iconColor: Theme.of(context).brightness == Brightness.dark
              ? colorTheme.iconColor
              : colorTheme.greyColor,
          iconColorSelected: colorTheme.textColor2,
          backspaceColor: colorTheme.iconColor,
          recentTabBehavior: RecentTabBehavior.RECENT,
          recentsLimit: 28,
          noRecents: const Text(
            'No Recents',
            style: TextStyle(fontSize: 20, color: Colors.black26),
            textAlign: TextAlign.center,
          ),
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: const CategoryIcons(),
        ),
      ),
    );
  }
}
