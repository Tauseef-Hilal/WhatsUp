import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../models/attachement.dart';
import 'attachment_viewer.dart';

enum MessageCardType { sentMessageCard, receivedMessageCard }

class MessageCard extends StatefulWidget {
  MessageCard({
    required this.message,
    required this.type,
    this.special = false,
  }) : super(key: ValueKey(message.id));

  final Message message;
  final bool special;
  final MessageCardType type;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool shouldHaveBiggerFont(String text) {
    final x = EmojiParser().parseEmojis(text);
    return text.runes.length == x.length;
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final size = MediaQuery.of(context).size;
    final hasAttachment = widget.message.attachment != null;
    final attachmentType = widget.message.attachment?.type;
    final isSentMessageCard = widget.type == MessageCardType.sentMessageCard;
    final messageHasText = widget.message.content.isNotEmpty;

    final showTimeStamp = !hasAttachment ||
        (hasAttachment &&
            attachmentType == AttachmentType.audio &&
            messageHasText) ||
        ((hasAttachment && attachmentType != AttachmentType.audio) &&
            (hasAttachment && attachmentType != AttachmentType.voice));

    final biggerFont = shouldHaveBiggerFont(widget.message.content);
    int padding = 2;

    if (!biggerFont) {
      if (isSentMessageCard) {
        padding = Platform.isAndroid
            ? (widget.special ? 17 : 14)
            : (widget.special ? 19 : 17);
      } else {
        padding = Platform.isAndroid ? 10 : 13;
      }
    }

    if (widget.message.content.length % 30 == 0) {
      padding = 0;
    }

    final textPadding = '\u00A0' * padding;

    return Align(
      alignment:
          isSentMessageCard ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipPath(
        clipper: widget.special
            ? TriangleClipper(isSender: isSentMessageCard)
            : null,
        child: Container(
          constraints: BoxConstraints(
            minHeight: 34,
            minWidth: widget.special ? (isSentMessageCard ? 98 : 76) : 60,
            maxWidth: size.width * 0.75 + (widget.special ? 10 : 0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: widget.special && !isSentMessageCard
                  ? const Radius.circular(4)
                  : const Radius.circular(12.0),
              topRight: widget.special && isSentMessageCard
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
            top: widget.special ? 6.0 : 0,
            left: widget.special ? 6 : 16.0,
            right: widget.special ? 6 : 16.0,
          ),
          padding: hasAttachment
              ? attachmentType == AttachmentType.audio && !messageHasText
                  ? EdgeInsets.only(
                      left: isSentMessageCard ? 8 : (widget.special ? 18 : 8),
                      right: isSentMessageCard ? (widget.special ? 10 : 0) : 0,
                    )
                  : EdgeInsets.only(
                      top: 4.0,
                      bottom: 4.0,
                      left: widget.special && !isSentMessageCard ? 14.0 : 4.0,
                      right: widget.special && isSentMessageCard ? 14.0 : 4.0,
                    )
              : const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 0,
                  bottom: 4,
                ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasAttachment) ...[
                    AttachmentPreview(
                      message: widget.message,
                    ),
                  ],
                  if (messageHasText) ...[
                    Padding(
                      padding: hasAttachment
                          ? const EdgeInsets.only(left: 4.0, top: 4.0)
                          : widget.special && !isSentMessageCard
                              ? EdgeInsets.only(
                                  left: 10,
                                  top: 4,
                                  bottom: biggerFont
                                      ? 12
                                      : padding == 0
                                          ? 14.0
                                          : 0,
                                )
                              : EdgeInsets.only(
                                  top: 2.0,
                                  bottom: biggerFont
                                      ? (Platform.isAndroid ? 16.0 : 12.0)
                                      : padding == 0
                                          ? 14.0
                                          : 0,
                                ),
                      child: Text(
                        '${widget.message.content}$textPadding',
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: Theme.of(context)
                            .custom
                            .textTheme
                            .bodyText1
                            .copyWith(
                              fontSize: biggerFont ? 40 : 16,
                              color: Colors.white,
                            ),
                        softWrap: true,
                      ),
                    )
                  ],
                ],
              ),
              Positioned(
                right: 0,
                bottom: -1,
                child: Container(
                  padding: !messageHasText &&
                          hasAttachment &&
                          attachmentType != AttachmentType.audio
                      ? const EdgeInsets.all(4.0)
                      : null,
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (!messageHasText &&
                          (attachmentType != AttachmentType.document &&
                              attachmentType != AttachmentType.audio &&
                              attachmentType != AttachmentType.voice)) ...[
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
                            widget.message.timestamp,
                            true,
                            Platform.isIOS,
                          ),
                          style: Theme.of(context)
                              .custom
                              .textTheme
                              .caption
                              .copyWith(
                                  fontSize: 11,
                                  color: messageHasText
                                      ? colorTheme.textColor1
                                          .withOpacity(0.9)
                                          .withBlue(255)
                                      : Colors.white),
                        )
                      ],
                      if (isSentMessageCard) ...[
                        const SizedBox(
                          width: 2.0,
                        ),
                        Image.asset(
                          'assets/images/${widget.message.status.value}.png',
                          color: widget.message.status.value != 'SEEN'
                              ? messageHasText
                                  ? colorTheme.textColor1
                                      .withOpacity(0.65)
                                      .withBlue(255)
                                  : Colors.white
                              : null,
                          width: 16.0,
                        ),
                      ],
                      if (widget.special &&
                          isSentMessageCard &&
                          messageHasText) ...[const SizedBox(width: 9)],
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
