import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/domain/auth_service.dart';
import 'package:whatsapp_clone/features/auth/views/auth_complete.dart';
import 'package:whatsapp_clone/shared/models/phone.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/emoji_picker.dart';
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
    ref
        .read(emojiPickerControllerProvider.notifier)
        .init(keyboardVisibility: true);
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

  void onNextBtnPressed(
    BuildContext context,
    WidgetRef ref,
    Phone phone,
  ) async {
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
                      .copyWith(color: AppColors.greenColor),
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
            future: authController.saveUserData(
              context,
              ref,
              username,
              phone,
              state,
            ),
            builder: (context, snapshot) {
              String? text;
              Widget? widget;

              if (snapshot.hasData) {
                text = 'You\'re all set!';
                widget = const Icon(
                  Icons.check_circle,
                  color: AppColors.greenColor,
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
                          color: AppColors.greenColor,
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
