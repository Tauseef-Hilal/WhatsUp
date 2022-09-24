import 'dart:async';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class CustomEmojiPicker extends StatelessWidget {
  const CustomEmojiPicker({
    super.key,
    required this.textController,
    this.afterEmojiPlaced,
  });

  final TextEditingController textController;
  final void Function(Emoji emoji)? afterEmojiPlaced;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.75 * (MediaQuery.of(context).size.height / 2),
      child: EmojiPicker(
        textEditingController: textController,
        onEmojiSelected: (_, emoji) => afterEmojiPlaced?.call(emoji),
        config: const Config(
          columns: 8,
          emojiSizeMax: 28,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          gridPadding: EdgeInsets.zero,
          initCategory: Category.SMILEYS,
          bgColor: AppColors.backgroundColor,
          indicatorColor: AppColors.tabColor,
          iconColor: AppColors.iconColor,
          iconColorSelected: Colors.white70,
          backspaceColor: AppColors.iconColor,
          showRecentsTab: true,
          recentsLimit: 28,
          noRecents: Text(
            'No Recents',
            style: TextStyle(fontSize: 20, color: Colors.black26),
            textAlign: TextAlign.center,
          ),
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: CategoryIcons(),
        ),
      ),
    );
  }
}

class EmojiPickerController extends StateNotifier<bool> {
  EmojiPickerController() : super(false);

  late final StreamSubscription<bool> _keyboardSubscription;
  final FocusNode _fieldFocusNode = FocusNode();
  late bool _isKeyboardVisible;

  FocusNode get fieldFocusNode => _fieldFocusNode;
  bool get keyboardVisible => _isKeyboardVisible;

  void init({required bool keyboardVisibility}) {
    _isKeyboardVisible = keyboardVisibility;
    _keyboardSubscription = KeyboardVisibilityController().onChange.listen(
      (bool visible) {
        _isKeyboardVisible = visible;

        if (visible) {
          state = false;
        }
      },
    );
  }

  @override
  void dispose() {
    _keyboardSubscription.cancel();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  void toggleEmojiPicker() async {
    if (_isKeyboardVisible) {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      await Future.delayed(const Duration(milliseconds: 50));
      state = !state;
    } else if (state) {
      _fieldFocusNode.requestFocus();
      await SystemChannels.textInput.invokeMethod('TextInput.show');
    } else {
      state = !state;
    }
  }
}

final emojiPickerControllerProvider =
    StateNotifierProvider.autoDispose<EmojiPickerController, bool>(
  (ref) => EmojiPickerController(),
);
