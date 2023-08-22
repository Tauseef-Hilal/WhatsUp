import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../models/attachement.dart';
import '../attachment_viewer.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({
    super.key,
    required this.message,
    required this.currentUserId,
    this.special = false,
  });

  final Message message;
  final bool special;
  final String currentUserId;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard>
    with AutomaticKeepAliveClientMixin {
  bool shouldHaveBiggerFont(String text) {
    final x = EmojiParser().parseEmojis(text);
    return text.runes.length == x.length;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorTheme = Theme.of(context).custom.colorTheme;
    final size = MediaQuery.of(context).size;
    final hasAttachment = widget.message.attachment != null;
    final attachmentType = widget.message.attachment?.type;
    final isSentMessageCard = widget.currentUserId == widget.message.senderId;
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
            ? (widget.special ? 13 : 12)
            : (widget.special ? 17 : 16);
      } else {
        padding = Platform.isAndroid ? 8 : 12;
      }
    }

    final textPadding = '\u00A0' * padding;
    final hasImageOrVideo = attachmentType == AttachmentType.image ||
        attachmentType == AttachmentType.video;
    final maxWidth = MediaQuery.of(context).size.width * 0.80;
    final maxHeight = MediaQuery.of(context).size.height * 0.40;
    final minWidth = 0.8 * maxWidth;
    final imgWidth = widget.message.attachment?.width ?? 1;
    final imgHeight = widget.message.attachment?.height ?? 1;
    final aspectRatio = imgWidth / imgHeight;

    double width, height;
    if (imgHeight > imgWidth) {
      height = min(imgHeight, maxHeight);
      width = max(aspectRatio * height, minWidth);
    } else {
      width = min(imgWidth, maxWidth);
      height = width / aspectRatio;
    }

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
            maxWidth: hasImageOrVideo
                ? width
                : size.width * 0.80 + (widget.special ? 10 : 0),
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
              : EdgeInsets.only(
                  left: 10,
                  right: widget.special && isSentMessageCard ? 16 : 10,
                  top: 4,
                  bottom: 6,
                ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasAttachment) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            height < width ? 0.65 * width : double.infinity,
                      ),
                      child: AttachmentPreview(
                        message: widget.message,
                        width: width,
                        height: height,
                      ),
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
                        '${widget.message.content} $textPadding',
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: Theme.of(context)
                            .custom
                            .textTheme
                            .bodyText1
                            .copyWith(
                              fontSize: biggerFont ? 40 : 16,
                              color: colorTheme.textColor1,
                            ),
                        softWrap: true,
                      ),
                    )
                  ],
                ],
              ),
              Positioned(
                right: widget.special && isSentMessageCard && messageHasText
                    ? -6
                    : 0,
                bottom: -1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      if (!messageHasText &&
                          (attachmentType != AttachmentType.document &&
                              attachmentType != AttachmentType.audio &&
                              attachmentType != AttachmentType.voice)) ...[
                        const BoxShadow(
                          color: Color.fromARGB(174, 1, 4, 21),
                          blurRadius: 20,
                        )
                      ],
                    ],
                  ),
                  margin: !messageHasText &&
                          hasAttachment &&
                          attachmentType != AttachmentType.audio
                      ? const EdgeInsets.all(4.0)
                      : null,
                  padding: !messageHasText &&
                          hasAttachment &&
                          attachmentType != AttachmentType.audio
                      ? const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        )
                      : null,
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
                                        .withBlue(
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? 255
                                              : 100,
                                        )
                                    : Colors.white,
                              ),
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
                                      .withBlue(Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 255
                                          : 150)
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : colorTheme.textColor1
                                          .withOpacity(0.7)
                                          .withBlue(
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? 255
                                                : 100,
                                          )
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
