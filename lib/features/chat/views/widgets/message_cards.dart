import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_storage.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ReceivedMessageCard extends ConsumerStatefulWidget {
  const ReceivedMessageCard({
    Key? key,
    required this.message,
    this.special = false,
  }) : super(key: key);

  final Message message;
  final bool special;

  @override
  ConsumerState<ReceivedMessageCard> createState() =>
      _ReceivedMessageCardState();
}

class _ReceivedMessageCardState extends ConsumerState<ReceivedMessageCard> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final hasAttachment = widget.message.attachment != null;
    final size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 36,
          minWidth: 80,
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hasAttachment ? 4.0 : 10.0),
          color: colorTheme.incomingMessageBubbleColor,
        ),
        margin: EdgeInsets.only(bottom: 2.0, top: widget.special ? 6.0 : 0),
        padding: EdgeInsets.symmetric(
          horizontal: hasAttachment ? 4.0 : 8.0,
          vertical: hasAttachment ? 4.0 : 4.0,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasAttachment) ...[
                  SizedBox(
                    width: size.width * 0.60,
                    height: size.height * 0.30,
                    child: AttachmentViewer(message: widget.message),
                  )
                ],
                Padding(
                  padding: EdgeInsets.only(left: hasAttachment ? 4.0 : 0),
                  child: Text(
                    widget.message.content + ' ' * 12,
                    style: Theme.of(context).custom.textTheme.bodyText1,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 1,
              child: Row(
                children: [
                  Text(
                    formattedTimestamp(
                      widget.message.timestamp,
                      true,
                    ),
                    style: Theme.of(context)
                        .custom
                        .textTheme
                        .caption
                        .copyWith(fontSize: 11, color: colorTheme.textColor2),
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

class AttachmentViewer extends ConsumerStatefulWidget {
  const AttachmentViewer({super.key, required this.message});
  final Message message;

  @override
  ConsumerState<AttachmentViewer> createState() => _AttachmentViewerState();
}

class _AttachmentViewerState extends ConsumerState<AttachmentViewer> {
  bool isAttachmentDownloading = false;

  Future<bool> attachmentExists() async {
    final appDir = await getApplicationDocumentsDirectory();

    // final metaData = await ref
    //     .read(firebaseStorageRepoProvider)
    //     .getFileMetadata(widget.message.attachment!.url);
    // final ext = metaData.contentType!.split("/").last;
    final file =
        File("${appDir.path}/media/${widget.message.attachment!.fileName}");
    if (await file.exists()) {
      widget.message.attachment!.file = file;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: attachmentExists(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          return snap.data!
              ? Image.file(
                  widget.message.attachment!.file!,
                  fit: BoxFit.fill,
                )
              : isAttachmentDownloading
                  ? DownloadingImage(message: widget.message)
                  : Center(
                      child: IconButton(
                        onPressed: () =>
                            setState(() => isAttachmentDownloading = true),
                        icon: const Icon(Icons.download),
                      ),
                    );
        });
  }
}

class DownloadingImage extends ConsumerStatefulWidget {
  const DownloadingImage({super.key, required this.message});
  final Message message;

  @override
  ConsumerState<DownloadingImage> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends ConsumerState<DownloadingImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(firebaseStorageRepoProvider).downloadFileFromFirebase(
            widget.message.attachment!.url,
            widget.message.id,
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final (file, downloadTask) = snapshot.data!;

        return StreamBuilder(
          stream: downloadTask.snapshotEvents,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            switch (snapshot.data!.state) {
              case TaskState.success:
                return Image.file(file, fit: BoxFit.fill);
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}

class SentMessageCard extends StatefulWidget {
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
  State<SentMessageCard> createState() => _SentMessageCardState();
}

class _SentMessageCardState extends State<SentMessageCard> {
  bool showImage = false;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 36,
          minWidth: 80,
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(showImage ? 4.0 : 10.0),
          color: colorTheme.outgoingMessageBubbleColor,
        ),
        margin: EdgeInsets.only(bottom: 2.0, top: widget.special ? 6.0 : 0),
        padding: EdgeInsets.symmetric(
          horizontal: showImage ? 4.0 : 8.0,
          vertical: showImage ? 4.0 : 4.0,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.message.attachment != null) ...[
                  SizedBox(
                    width: size.width * 0.60,
                    height: size.height * 0.30,
                    child: showImage
                        ? CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: widget.message.attachment!.url,
                          )
                        : Center(
                            child: IconButton(
                              onPressed: () => setState(() => showImage = true),
                              icon: const Icon(Icons.download),
                            ),
                          ),
                  )
                ],
                Padding(
                  padding: EdgeInsets.only(right: showImage ? 4.0 : 0),
                  child: Text(
                    widget.message.content + ' ' * 16,
                    style: Theme.of(context).custom.textTheme.bodyText1,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedTimestamp(
                      widget.message.timestamp,
                      true,
                    ),
                    style: Theme.of(context)
                        .custom
                        .textTheme
                        .caption
                        .copyWith(fontSize: 11, color: colorTheme.textColor2),
                  ),
                  const SizedBox(
                    width: 2.0,
                  ),
                  Image.asset(
                    'assets/images/${widget.msgStatus}.png',
                    color: widget.msgStatus != 'SEEN'
                        ? colorTheme.textColor1
                        : null,
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
