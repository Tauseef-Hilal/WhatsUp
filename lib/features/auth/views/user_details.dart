import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/user_details_controller.dart';

import 'package:whatsapp_clone/features/auth/views/last.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/buttons.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class UserProfileCreationPage extends ConsumerStatefulWidget {
  const UserProfileCreationPage({super.key});

  @override
  ConsumerState<UserProfileCreationPage> createState() =>
      _UserProfileCreationPageState();
}

class _UserProfileCreationPageState
    extends ConsumerState<UserProfileCreationPage> {
  File? userImg;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    ref.read(emojiPickerControllerProvider.notifier).init();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void showImageSources(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBarColor,
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
                        onTap: () {
                          userImg = null;
                          // setState(() {});
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.delete,
                          color: AppColors.iconColor,
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
                      onTap: () async {
                        userImg = await capturePhoto();
                        if (!mounted) return;
                        Navigator.of(context).pop();
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
                                color: AppColors.greyColor,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.tabColor,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            'Camera',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 24.0,
                    ),
                    InkWell(
                      onTap: () async {
                        userImg = await pickImageFromGallery();
                        if (!mounted) return;
                        Navigator.of(context).pop();
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
                                color: AppColors.greyColor,
                              ),
                            ),
                            child: const Icon(
                              Icons.photo_size_select_actual,
                              color: AppColors.tabColor,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            'Gallery',
                            style: Theme.of(context).textTheme.caption,
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
  Widget build(BuildContext context) {
    final showEmojiPicker = ref.watch(emojiPickerControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Profile info'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Column(
        children: [
          Text(
            'Please provide your name and an optional profile photo',
            style: Theme.of(context).textTheme.caption,
          ),
          const SizedBox(
            height: 16.0,
          ),
          GestureDetector(
            onTap: () => showImageSources(context),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: userImg != null ? FileImage(userImg!) : null,
              backgroundColor: AppColors.appBarColor,
              child: userImg == null ? const Icon(Icons.add_a_photo) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {},
                    controller: ref
                        .read(emojiPickerControllerProvider.notifier)
                        .usernameController,
                    focusNode: ref
                        .read(emojiPickerControllerProvider.notifier)
                        .fieldFocusNode,
                    autofocus: true,
                    style: const TextStyle(
                      color: AppColors.textColor,
                    ),
                    cursorColor: AppColors.tabColor,
                    decoration: InputDecoration(
                      hintText: 'Type your name here',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: AppColors.iconColor),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.tabColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.tabColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref
                      .read(emojiPickerControllerProvider.notifier)
                      .toggleEmojiPicker(),
                  child: Icon(
                    showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                    color: AppColors.iconColor,
                  ),
                ),
              ],
            ),
          ),
          showEmojiPicker ||
                  ref
                      .read(emojiPickerControllerProvider.notifier)
                      .keyboardVisible
              ? const Text('')
              : const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 150,
              vertical: 40,
            ),
            child: GreenElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const AuthCompletePage(),
                    ),
                    (route) => false);
              },
              text: 'NEXT',
            ),
          ),
          showEmojiPicker ? const Spacer() : const Text(''),
          Offstage(
            offstage: !showEmojiPicker,
            child: SizedBox(
              height: 0.75 * (MediaQuery.of(context).size.height / 2),
              child: EmojiPicker(
                textEditingController: ref
                    .read(emojiPickerControllerProvider.notifier)
                    .usernameController,
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
            ),
          ),
        ],
      ),
    );
  }
}
