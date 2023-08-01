import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/attachment_renderers.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/utils/storage_paths.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/emoji_picker.dart';
import '../../controllers/chat_controller.dart';
import '../../models/attachement.dart';
import '../../models/message.dart';

class AttachmentMessageSender extends ConsumerStatefulWidget {
  const AttachmentMessageSender({
    super.key,
    required this.attachments,
    required this.attachmentTypes,
  });

  final List<File> attachments;
  final List<AttachmentType> attachmentTypes;

  @override
  ConsumerState<AttachmentMessageSender> createState() =>
      _AttachmentMessageSenderState();
}

class _AttachmentMessageSenderState
    extends ConsumerState<AttachmentMessageSender> {
  late User self;
  late User other;
  late File current;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    self = ref.read(chatControllerProvider.notifier).self;
    other = ref.read(chatControllerProvider.notifier).other;
    controllers =
        widget.attachments.map((_) => TextEditingController()).toList();
    current = widget.attachments[0];

    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final currentType =
        widget.attachmentTypes[widget.attachments.indexOf(current)];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? colorTheme.backgroundColor
          : const Color.fromARGB(236, 225, 233, 235),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Color.fromARGB(100, 0, 0, 0),
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.close,
                    ),
                  ),
                ),
                trailing: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(100, 0, 0, 0),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.crop),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(100, 0, 0, 0),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.sticky_note_2),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(100, 0, 0, 0),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.text_format_outlined),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(100, 0, 0, 0),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.draw),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: AttachmentRenderer(
                  attachment: current,
                  attachmentType: currentType,
                  fit: BoxFit.contain,
                  controllable: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  children: [
                    GestureDetector(
                      child: const Icon(Icons.arrow_back_ios),
                      onTap: () {
                        final index = widget.attachments.indexOf(current);
                        if (index == 0) return;
                        setState(() {
                          current = widget.attachments[index - 1];
                        });
                      },
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.attachments.length,
                          itemBuilder: (context, idx) {
                            final file = widget.attachments[idx];
                            final fileType = widget.attachmentTypes[idx];

                            return Center(
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      current = file;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: current == file
                                          ? Border.all(
                                              color: Colors.blue,
                                              width: 4,
                                            )
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: AttachmentRenderer(
                                          attachment: file,
                                          attachmentType: fileType,
                                          fit: BoxFit.cover,
                                          compact: true,
                                        ),
                                      ),
                                    ),
                                  )),
                            );
                          },
                          separatorBuilder: (context, idx) {
                            return const SizedBox(width: 10);
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        final index = widget.attachments.indexOf(current);
                        if (index == widget.attachments.length - 1) return;
                        setState(() {
                          current = widget.attachments[index + 1];
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colorTheme.appBarColor
                              : const Color.fromARGB(255, 242, 251, 254),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GestureDetector(
                                  onTap: ref
                                      .read(emojiPickerControllerProvider
                                          .notifier)
                                      .toggleEmojiPicker,
                                  child: Icon(
                                    Icons.add,
                                    size: 24.0,
                                    color: colorTheme.greyColor,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8.0,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: controllers[
                                      widget.attachments.indexOf(current)],
                                  maxLines: 6,
                                  minLines: 1,
                                  cursorColor: colorTheme.greenColor,
                                  cursorHeight: 20,
                                  style: Theme.of(context)
                                      .custom
                                      .textTheme
                                      .bodyText1,
                                  decoration: InputDecoration(
                                    hintText: 'Message',
                                    hintStyle: Theme.of(context)
                                        .custom
                                        .textTheme
                                        .bodyText1
                                        .copyWith(),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    InkWell(
                      onTap: () async {
                        for (var i = 0; i < controllers.length; i++) {
                          final attachedFile = widget.attachments[i];
                          final attachmentType = widget.attachmentTypes[i];

                          double? width, height;
                          if (attachmentType == AttachmentType.image) {
                            (width, height) =
                                await getImageDimensions(attachedFile);
                          } else if (attachmentType == AttachmentType.video) {
                            (width, height) =
                                await getVideoDimensions(attachedFile);
                          }

                          String messageId = const Uuid().v4();
                          String fileName = attachedFile.path.split("/").last;
                          String msgContent = controllers[i].text.trim();
                          if (msgContent.isEmpty &&
                              attachmentType == AttachmentType.document) {
                            msgContent = "\u00A0";
                          }

                          attachedFile.rename(
                            DeviceStorage.getMediaFilePath(
                                "${messageId}__$fileName"),
                          );

                          ref
                              .read(chatControllerProvider.notifier)
                              .sendMessageWithAttachments(
                                Message(
                                  id: messageId,
                                  content: msgContent,
                                  status: MessageStatus.pending,
                                  senderId: self.id,
                                  receiverId: other.id,
                                  timestamp: Timestamp.now(),
                                  attachment: Attachment(
                                    type: attachmentType,
                                    url: "",
                                    fileName: fileName,
                                    fileSize: attachedFile.lengthSync(),
                                    fileExtension: fileName.split(".").last,
                                    file: attachedFile,
                                    width: width,
                                    height: height,
                                  ),
                                ),
                              );
                        }

                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: colorTheme.greenColor,
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
