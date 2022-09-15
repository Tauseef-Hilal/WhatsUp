import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emojiPickerControllerProvider =
    AutoDisposeStateNotifierProvider<EmojiPickerController, bool>(
  (ref) => EmojiPickerController(),
);

class EmojiPickerController extends StateNotifier<bool> {
  EmojiPickerController() : super(false);

  late final TextEditingController _usernameController;
  late final StreamSubscription<bool> _keyboardSubscription;
  final FocusNode _fieldFocusNode = FocusNode();
  bool _isKeyboardVisible = true;

  TextEditingController get usernameController => _usernameController;
  FocusNode get fieldFocusNode => _fieldFocusNode;
  bool get keyboardVisible => _isKeyboardVisible;

  void init() {
    _usernameController = TextEditingController();

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
    _usernameController.dispose();
    _keyboardSubscription.cancel();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  void toggleEmojiPicker() async {
    if (_isKeyboardVisible) {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      await Future.delayed(const Duration(milliseconds: 100));
      state = !state;
    } else if (state) {
      _fieldFocusNode.requestFocus();
      await SystemChannels.textInput.invokeMethod('TextInput.show');
    } else {
      state = !state;
    }
  }
}
