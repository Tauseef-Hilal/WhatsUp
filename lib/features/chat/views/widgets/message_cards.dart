import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/colors.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ReceivedMessageCard extends StatelessWidget {
  const ReceivedMessageCard({
    Key? key,
    required this.message,
    this.special = false,
  }) : super(key: key);

  final Message message;
  final bool special;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 36,
          minWidth: 80,
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: AppColors.incomingMessageBubbleColor,
        ),
        margin: EdgeInsets.only(bottom: 2.0, top: special ? 6.0 : 0),
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Stack(
          children: [
            Text(
              message.content + ' ' * 12,
              style: Theme.of(context).custom.textTheme.bodyText1,
              softWrap: true,
            ),
            Positioned(
              right: 0,
              bottom: 1,
              child: Row(
                children: [
                  Text(
                    formattedTimestamp(
                      message.timestamp,
                      true,
                    ),
                    style: Theme.of(context)
                        .custom
                        .textTheme
                        .caption
                        .copyWith(fontSize: 11, color: AppColors.textColor2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SentMessageCard extends StatelessWidget {
  const SentMessageCard({
    Key? key,
    required this.message,
    required this.msgStatus,
    this.special = false,
  }) : super(key: key);

  final Message message;
  final String msgStatus;
  final bool special;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 36,
          minWidth: 80,
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: AppColors.outgoingMessageBubbleColor,
        ),
        margin: EdgeInsets.only(bottom: 2.0, top: special ? 6.0 : 0.0),
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Stack(
          children: [
            Text(
              message.content + ' ' * 16,
              style: Theme.of(context).custom.textTheme.bodyText1,
              softWrap: true,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedTimestamp(
                      message.timestamp,
                      true,
                    ),
                    style: Theme.of(context)
                        .custom
                        .textTheme
                        .caption
                        .copyWith(fontSize: 11, color: AppColors.textColor2),
                  ),
                  const SizedBox(
                    width: 2.0,
                  ),
                  Image.asset(
                    'assets/images/$msgStatus.png',
                    color: msgStatus != 'SEEN' ? Colors.white : null,
                    width: 15.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
