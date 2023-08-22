import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/attachment_renderers.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/chat_field.dart';
import 'package:whatsapp_clone/shared/widgets/bottom_inset.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../shared/models/user.dart';
import '../../../shared/utils/storage_paths.dart';
import '../controllers/chat_controller.dart';
import '../models/attachement.dart';
import '../models/message.dart';

class AttachmentMessageSender extends ConsumerStatefulWidget {
  const AttachmentMessageSender({
    super.key,
    required this.attachments,
    this.tags,
  });

  final List<Attachment> attachments;
  final List<String>? tags;

  @override
  ConsumerState<AttachmentMessageSender> createState() =>
      _AttachmentMessageSenderState();
}

class _AttachmentMessageSenderState
    extends ConsumerState<AttachmentMessageSender> {
  late User self;
  late User other;
  late Attachment current;
  late List<TextEditingController> controllers;
  bool isKeyboardVisible = false;
  late List<Attachment> attachments = widget.attachments;
  late StreamSubscription<bool> keyboardListener;

  @override
  void initState() {
    self = ref.read(chatControllerProvider.notifier).self;
    other = ref.read(chatControllerProvider.notifier).other;
    current = attachments[0];
    controllers = attachments.map((_) => TextEditingController()).toList();

    keyboardListener = KeyboardVisibilityController().onChange.listen(
      (event) {
        if (!mounted) return;
        setState(() {
          isKeyboardVisible = event;
        });
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    keyboardListener.cancel();
    for (var controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> addNewAttachments() async {
    List<Attachment>? newAttachments;
    if (current.type == AttachmentType.document) {
      newAttachments =
          await ref.read(chatControllerProvider.notifier).pickDocuments(
                context,
                returnAttachments: true,
              );
    } else {
      if (Platform.isAndroid) {
        Navigator.pop(context, attachments);
        return;
      }
      newAttachments = await ref
          .read(chatControllerProvider.notifier)
          .pickAttachmentsFromGallery(
            context,
            returnAttachments: true,
          );
    }

    if (newAttachments == null) return;
    setState(() {
      attachments.addAll(newAttachments!);
      controllers.addAll(
        List.generate(
          newAttachments.length,
          (_) => TextEditingController(),
        ),
      );
    });
  }

  Future<void> sendAttachments() async {
    for (var i = 0; i < controllers.length; i++) {
      final attachment = attachments[i];

      String messageId = const Uuid().v4();
      String msgContent = controllers[i].text.trim();
      if (msgContent.isEmpty && attachment.type == AttachmentType.document) {
        msgContent = "\u00A0";
      }

      await attachment.file!.copy(
        DeviceStorage.getMediaFilePath(
          attachment.fileName,
        ),
      );

      ref.read(chatControllerProvider.notifier).sendMessageWithAttachments(
            Message(
              id: messageId,
              content: msgContent,
              status: MessageStatus.pending,
              senderId: self.id,
              receiverId: other.id,
              timestamp: Timestamp.now(),
              attachment: attachment..uploadStatus = UploadStatus.uploading,
            ),
          );
    }

    if (!mounted) return;
    // Navigator.pop(context);
    Navigator.of(context).popUntil((route) => route.settings.name == 'chat');
  }

  void removeSelectedAttachment() {
    if (attachments.length == 1) {
      Navigator.pop(context, []);
      return;
    }
    setState(() {
      final idx = attachments.indexOf(current);
      attachments.removeAt(idx);
      controllers[idx].dispose();
      controllers.removeAt(idx);

      if (widget.tags != null) {
        widget.tags!.removeAt(idx);
      }

      current = attachments.first;
    });
  }

  void selectAttachment(Attachment attachment) {
    setState(() {
      current = attachment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final currentType = current.type;
    final currentImageRenderer = AttachmentRenderer(
      attachment: current.file!,
      attachmentType: currentType,
      fit: BoxFit.contain,
      controllable: true,
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(attachments);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? colorTheme.backgroundColor
            : const Color.fromARGB(236, 225, 233, 235),
        body: Stack(
          children: [
            Center(
              child: KeyboardDismissOnTap(
                child: widget.tags != null
                    ? Hero(
                        tag: widget.tags![attachments.indexOf(current)],
                        child: currentImageRenderer,
                      )
                    : currentImageRenderer,
              ),
            ),
            AvoidBottomInset(
              conditions: const [false],
              child: Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        leading: GestureDetector(
                          onTap: () => Navigator.of(context).pop(attachments),
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
                      const Spacer(),
                      Offstage(
                        offstage: isKeyboardVisible,
                        child: Preview(
                          attachments: attachments,
                          current: current,
                          onAttachmentClicked: selectAttachment,
                          onDeleteClicked: removeSelectedAttachment,
                        ),
                      ),
                      Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ChatField(
                            textController:
                                controllers[attachments.indexOf(current)],
                            leading: GestureDetector(
                              onTap: addNewAttachments,
                              child: Icon(
                                Icons.add_box_rounded,
                                size: 24.0,
                                color: colorTheme.greyColor,
                              ),
                            ),
                            actions: [
                              GestureDetector(
                                child: const Icon(Icons.hide_source_rounded),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          color: const Color.fromARGB(152, 0, 0, 0),
                          padding: const EdgeInsets.only(
                            top: 12.0,
                            bottom: 32,
                            left: 12,
                            right: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? colorTheme.appBarColor
                                        : const Color.fromARGB(
                                            255, 242, 251, 254),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Text(other.name),
                                ),
                              ),
                              InkWell(
                                onTap: sendAttachments,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorTheme.greenColor),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Preview extends StatelessWidget {
  const Preview({
    super.key,
    required this.attachments,
    required this.current,
    required this.onDeleteClicked,
    required this.onAttachmentClicked,
  });

  final List<Attachment> attachments;
  final Attachment current;
  final VoidCallback onDeleteClicked;
  final Function(Attachment) onAttachmentClicked;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: SizedBox(
          height: 60,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            itemBuilder: (context, idx) {
              final attachment = attachments[idx];
              final attachmentType = attachment.type;

              return Center(
                child: GestureDetector(
                    onTap: () => onAttachmentClicked(attachment),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: current == attachment
                            ? Border.all(
                                color: Colors.white,
                                width: 2,
                              )
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: AttachmentRenderer(
                                  attachment: attachment.file!,
                                  attachmentType: attachmentType,
                                  fit: BoxFit.cover,
                                  compact: true,
                                ),
                              ),
                            ),
                            if (current == attachment) ...[
                              Container(
                                width: 50,
                                height: 50,
                                color: Colors.black38,
                                child: GestureDetector(
                                  onTap: onDeleteClicked,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )),
              );
            },
            separatorBuilder: (context, idx) {
              return const SizedBox(width: 6);
            },
          ),
        ),
      ),
    );
  }
}
