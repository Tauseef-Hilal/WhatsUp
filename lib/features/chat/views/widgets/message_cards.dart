import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../models/attachement.dart';
import 'attachment_viewer.dart';

enum MessageCardType { sentMessageCard, receivedMessageCard }

class MessageCard extends StatelessWidget {
  MessageCard({
    required this.message,
    required this.type,
    this.special = false,
  }) : super(key: ValueKey(message.id));

  final Message message;
  final bool special;
  final MessageCardType type;

  bool containsSingleEmoji(String text) {
    return EmojiParser().parseEmojis(text).length == 1 &&
        text.runes.length == 1;
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final size = MediaQuery.of(context).size;
    final hasAttachment = message.attachment != null;
    final attachmentType = message.attachment?.type;
    final isSentMessageCard = type == MessageCardType.sentMessageCard;
    final messageHasText = message.content.isNotEmpty;
    final hasSingleEmoji = containsSingleEmoji(message.content);
    int padding = 2;
    if (!hasSingleEmoji) {
      if (isSentMessageCard) {
        padding = 11;
      } else {
        padding = 7;
      }
    }
    final textPadding = '\u00A0' * padding;

    final showTimeStamp = !hasAttachment ||
        (hasAttachment &&
            attachmentType == AttachmentType.audio &&
            messageHasText) ||
        (hasAttachment && attachmentType != AttachmentType.audio);

    return Align(
      alignment:
          isSentMessageCard ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipPath(
        clipper: special ? TriangleClipper(isSender: isSentMessageCard) : null,
        child: Container(
          constraints: BoxConstraints(
            minHeight: 30,
            minWidth: special ? (isSentMessageCard ? 98 : 76) : 60,
            maxWidth: size.width * 0.75,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: special && !isSentMessageCard
                  ? const Radius.circular(4)
                  : const Radius.circular(12.0),
              topRight: special && isSentMessageCard
                  ? const Radius.circular(4)
                  : const Radius.circular(12.0),
              bottomLeft: const Radius.circular(12.0),
              bottomRight: const Radius.circular(12.0),
            ),
            color: isSentMessageCard
                ? colorTheme.outgoingMessageBubbleColor
                : colorTheme.incomingMessageBubbleColor,
          ),
          margin: EdgeInsets.only(
            bottom: 3.0,
            top: special ? 6.0 : 0,
            left: special ? 6 : 16.0,
            right: special ? 6 : 16.0,
          ),
          padding: hasAttachment
              ? attachmentType == AttachmentType.audio && !messageHasText
                  ? null
                  : const EdgeInsets.all(4.0)
              : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasAttachment) ...[
                    AttachmentPreview(
                      message: message,
                    ),
                  ],
                  if (messageHasText) ...[
                    Padding(
                      padding: hasAttachment
                          ? const EdgeInsets.only(left: 4.0, top: 4.0)
                          : special && !isSentMessageCard
                              ? EdgeInsets.only(
                                  left: 10,
                                  bottom: hasSingleEmoji ? 10.0 : 0,
                                )
                              : EdgeInsets.only(
                                  bottom: hasSingleEmoji ? 10.0 : 0,
                                ),
                      child: Text(
                        '${message.content} $textPadding',
                        style: Theme.of(context)
                            .custom
                            .textTheme
                            .bodyText1
                            .copyWith(
                              fontSize: hasSingleEmoji ? 40 : 16,
                              height: 1,
                              color: colorTheme.textColor1,
                            ),
                        softWrap: true,
                      ),
                    )
                  ],
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: !messageHasText && hasAttachment
                      ? const EdgeInsets.all(4.0)
                      : null,
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (!messageHasText &&
                          (attachmentType != AttachmentType.document &&
                              attachmentType != AttachmentType.audio)) ...[
                        const BoxShadow(
                          offset: Offset(-2, -2),
                          color: Color.fromARGB(225, 0, 0, 0),
                          blurRadius: 12,
                        )
                      ]
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (showTimeStamp) ...[
                        Text(
                          formattedTimestamp(
                            message.timestamp,
                            true,
                          ),
                          style: Theme.of(context)
                              .custom
                              .textTheme
                              .caption
                              .copyWith(
                                  fontSize: 11,
                                  color: messageHasText
                                      ? colorTheme.textColor2
                                      : Colors.white),
                        )
                      ],
                      if (isSentMessageCard) ...[
                        const SizedBox(
                          width: 2.0,
                        ),
                        Image.asset(
                          'assets/images/${message.status.value}.png',
                          color: message.status.value != 'SEEN'
                              ? messageHasText
                                  ? colorTheme.textColor2
                                  : Colors.white
                              : null,
                          width: 16.0,
                        ),
                      ],
                      if (special && isSentMessageCard) ...[
                        const SizedBox(width: 10)
                      ],
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  final bool isSender;

  TriangleClipper({required this.isSender});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (isSender) {
      path.lineTo(size.width, 0);
      path.lineTo(size.width, 4);
      path.lineTo(size.width - 16, 16);
      path.lineTo(size.width - 16, size.height - 10);
      path.quadraticBezierTo(
          size.width - 16, size.height - 2, size.width - 36, size.height);
      path.lineTo(0, size.height);
    } else {
      path.lineTo(0, 4);
      path.lineTo(16, 16);
      path.lineTo(16, size.height - 10);
      path.quadraticBezierTo(16, size.height - 2, 36, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
