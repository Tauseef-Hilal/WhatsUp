import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controllers/user_details_controller.dart';
import 'package:whatsapp_clone/shared/models/phone.dart';

import 'package:whatsapp_clone/shared/widgets/buttons.dart';
import 'package:whatsapp_clone/shared/widgets/emoji_picker.dart';
import 'package:whatsapp_clone/theme/colors.dart';

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

  @override
  void initState() {
    ref.read(userDetailsControllerProvider.notifier).init();
    super.initState();
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
                        onTap: () => ref
                            .read(userDetailsControllerProvider.notifier)
                            .deleteImage(context),
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
                      onTap: () => ref
                          .read(userDetailsControllerProvider.notifier)
                          .setImageFromCamera(context),
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
                              color: AppColors.greenColor,
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
                      onTap: () => ref
                          .read(userDetailsControllerProvider.notifier)
                          .setImageFromGallery(context),
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
                              color: AppColors.greenColor,
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
    userImg = ref.watch(userDetailsControllerProvider);

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
                        .read(userDetailsControllerProvider.notifier)
                        .usernameController,
                    focusNode: ref
                        .read(emojiPickerControllerProvider.notifier)
                        .fieldFocusNode,
                    autofocus: true,
                    style: const TextStyle(
                      color: AppColors.textColor1,
                    ),
                    cursorColor: AppColors.greenColor,
                    decoration: InputDecoration(
                      hintText: 'Type your name here',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: AppColors.iconColor),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.greenColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.greenColor,
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
              horizontal: 130,
              vertical: 40,
            ),
            child: GreenElevatedButton(
              onPressed: () => ref
                  .read(userDetailsControllerProvider.notifier)
                  .onNextBtnPressed(context, ref, widget.phone),
              text: 'NEXT',
            ),
          ),
          showEmojiPicker ? const Spacer() : const Text(''),
          Offstage(
            offstage: !showEmojiPicker,
            child: SizedBox(
              height: 0.75 * (MediaQuery.of(context).size.height / 2),
              child: CustomEmojiPicker(
                  textController: ref
                      .read(userDetailsControllerProvider.notifier)
                      .usernameController),
            ),
          ),
        ],
      ),
    );
  }
}
