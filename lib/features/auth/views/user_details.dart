import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controllers/user_details_controller.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';
import 'package:whatsapp_clone/shared/widgets/bottom_inset.dart';

import 'package:whatsapp_clone/shared/widgets/buttons.dart';
import 'package:whatsapp_clone/shared/widgets/emoji_picker.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../shared/models/user.dart';

class UserProfileCreationPage extends ConsumerStatefulWidget {
  const UserProfileCreationPage({
    super.key,
    required this.phone,
  });

  final Phone phone;

  @override
  ConsumerState<UserProfileCreationPage> createState() =>
      _UserProfileCreationPageState();
}

class _UserProfileCreationPageState
    extends ConsumerState<UserProfileCreationPage> {
  File? userImg;
  double keyboardHeight = SharedPref.instance.getDouble('keyboardHeight')!;
  bool showEmojiPicker = false;
  bool isKeyboardVisible = false;
  late final StreamSubscription<bool> _keyboardSubscription;
  final _focusNode = FocusNode();

  @override
  void initState() {
    _keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((isVisible) async {
      isKeyboardVisible = isVisible;
      if (isVisible) {
        showEmojiPicker = false;
      }
      setState(() {});
    });
    ref.read(userDetailsControllerProvider.notifier).init();
    super.initState();
  }

  void switchKeyboards() async {
    if (!showEmojiPicker && !isKeyboardVisible) {
      setState(() => showEmojiPicker = true);
    } else if (showEmojiPicker) {
      _focusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => showEmojiPicker = false);
      });
    } else if (isKeyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() => showEmojiPicker = true);
    }
  }

  void showImageSources(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? colorTheme.appBarColor
          : colorTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      elevation: 8.0,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 0.20 * MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profile photo'),
                    if (userImg != null) ...[
                      GestureDetector(
                        onTap: () => ref
                            .read(userDetailsControllerProvider.notifier)
                            .deleteImage(context),
                        child: Icon(
                          Icons.delete,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colorTheme.iconColor
                              : colorTheme.greyColor,
                        ),
                      )
                    ],
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ref
                            .read(userDetailsControllerProvider.notifier)
                            .setImageFromCamera(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              border: Border.all(
                                width: 1.0,
                                color: colorTheme.greyColor,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: colorTheme.greenColor,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            'Camera',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 24.0,
                    ),
                    InkWell(
                      onTap: () async {
                        await ref
                            .read(userDetailsControllerProvider.notifier)
                            .setImageFromGallery(context);

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              border: Border.all(
                                width: 1.0,
                                color: colorTheme.greyColor,
                              ),
                            ),
                            child: Icon(
                              Icons.photo_size_select_actual,
                              color: colorTheme.greenColor,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            'Gallery',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userImg = ref.watch(userDetailsControllerProvider);
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Profile info',
          style: TextStyle(color: colorTheme.textColor1),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorTheme.statusBarColor,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarColor: colorTheme.navigationBarColor,
          systemNavigationBarDividerColor: colorTheme.navigationBarColor,
        ),
        actions: [
          Icon(
            Icons.more_vert_rounded,
            color: colorTheme.greyColor,
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.light
                  ? colorTheme.greyColor
                  : colorTheme.iconColor),
        ),
        child: AvoidBottomInset(
          conditions: [showEmojiPicker],
          offstage: Offstage(
            offstage: !showEmojiPicker,
            child: CustomEmojiPicker(
              textController: ref
                  .read(userDetailsControllerProvider.notifier)
                  .usernameController,
            ),
          ),
          child: Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12.0),
                Text(
                  'Please provide your name and an optional profile photo',
                  style: TextStyle(color: colorTheme.greyColor),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                GestureDetector(
                  onTap: () => showImageSources(context),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        userImg != null ? FileImage(userImg!) : null,
                    backgroundColor: colorTheme.appBarColor,
                    child:
                        userImg == null ? const Icon(Icons.add_a_photo) : null,
                  ),
                ),
                const SizedBox(
                  height: 4.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {},
                          focusNode: _focusNode,
                          controller: ref
                              .read(userDetailsControllerProvider.notifier)
                              .usernameController,
                          autofocus: true,
                          style: TextStyle(
                            color: colorTheme.textColor1,
                          ),
                          cursorColor: colorTheme.greenColor,
                          decoration: InputDecoration(
                            hintText: 'Type your name here',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: colorTheme.greyColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: colorTheme.greenColor,
                                width: 1,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: colorTheme.greenColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: switchKeyboards,
                        child: Icon(
                          !showEmojiPicker
                              ? Icons.emoji_emotions
                              : Icons.keyboard,
                          size: 24.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 130,
                    vertical: 20,
                  ),
                  child: GreenElevatedButton(
                    onPressed: () => ref
                        .read(userDetailsControllerProvider.notifier)
                        .onNextBtnPressed(context, ref, widget.phone),
                    text: 'Next',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
