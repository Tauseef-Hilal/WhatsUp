import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/domain/auth_service.dart';
import 'package:whatsapp_clone/features/auth/views/auth_complete.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/colors.dart';

final userDetailsControllerProvider =
    StateNotifierProvider.autoDispose<UserDetailsController, File?>(
        (ref) => UserDetailsController(ref));

class UserDetailsController extends StateNotifier<File?> {
  UserDetailsController(this.ref) : super(null);

  final AutoDisposeStateNotifierProviderRef ref;
  late final TextEditingController _usernameController;

  void init() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _usernameController = TextEditingController();
    ref.read(emojiPickerControllerProvider.notifier).init();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _usernameController.dispose();
    super.dispose();
  }

  TextEditingController get usernameController => _usernameController;

  void deleteImage(BuildContext context) {
    state = null;
    Navigator.of(context).pop();
  }

  void setImageFromCamera(BuildContext context) async {
    state = await capturePhoto();
    Navigator.of(context).pop();
  }

  void setImageFromGallery(BuildContext context) async {
    state = await pickImageFromGallery();
    Navigator.of(context).pop();
  }

  void onNextBtnPressed(BuildContext context, WidgetRef ref) async {
    bool internetConnActive = await isConnected();

    final username = ref
        .read(userDetailsControllerProvider.notifier)
        .usernameController
        .text;

    String errorMsg = '';
    if (username.isEmpty) {
      errorMsg = 'Please type your name';
    } else if (!internetConnActive) {
      errorMsg = 'Unable to connect. Please check your '
          'internet connection and try again';
    }

    if (errorMsg.isNotEmpty) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsPadding: const EdgeInsets.all(0),
            backgroundColor: AppColors.appBarColor,
            content: Text(
              errorMsg,
              style: Theme.of(context).textTheme.bodySmall!,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.tabColor),
                ),
              ),
            ],
          );
        },
      );
    }

    final authController = ref.read(authControllerProvider);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return FutureBuilder<User>(
            future: authController.saveUserData(context, ref, username, state),
            builder: (context, snapshot) {
              String? text;
              Widget? widget;

              if (snapshot.hasData) {
                text = 'You\'re all set!';
                widget = const Icon(
                  Icons.check_circle,
                  color: AppColors.tabColor,
                  size: 38.0,
                );

                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => AuthCompletePage(
                          user: snapshot.data!,
                        ),
                      ),
                      (route) => false);
                });
              } else if (snapshot.hasError) {
                text = 'Oops! an error occured';
                widget = const Icon(
                  Icons.cancel,
                  color: AppColors.errorSnackBarColor,
                  size: 38.0,
                );

                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.of(context).pop();
                });
              }

              return AlertDialog(
                actionsPadding: const EdgeInsets.all(0),
                backgroundColor: AppColors.appBarColor,
                content: Row(
                  children: [
                    widget ??
                        const CircularProgressIndicator(
                          color: AppColors.tabColor,
                        ),
                    const SizedBox(
                      width: 24.0,
                    ),
                    Text(
                      text ?? 'Connecting',
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontSize: 16.0),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
}

final emojiPickerControllerProvider =
    AutoDisposeStateNotifierProvider<EmojiPickerController, bool>(
  (ref) => EmojiPickerController(),
);

class EmojiPickerController extends StateNotifier<bool> {
  EmojiPickerController() : super(false);

  late final StreamSubscription<bool> _keyboardSubscription;
  final FocusNode _fieldFocusNode = FocusNode();
  bool _isKeyboardVisible = true;

  FocusNode get fieldFocusNode => _fieldFocusNode;
  bool get keyboardVisible => _isKeyboardVisible;

  void init() {
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
