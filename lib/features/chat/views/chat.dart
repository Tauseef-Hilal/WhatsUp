import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/home/views/base.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class ChatPage extends StatefulWidget {
  final User sender;
  final User receiver;

  const ChatPage({
    super.key,
    required this.sender,
    required this.receiver,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  bool _hideElements = false;

  @override
  Widget build(BuildContext context) {
    final sender = widget.sender;
    final receiver = widget.receiver;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(receiver.avatarUrl),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiver.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontSize: 17.0),
                ),
                Text(
                  'Online',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ],
        ),
        leadingWidth: 34.0,
        leading: IconButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(userId: sender.id)),
              (route) => false),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.videocam_rounded,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: AppColors.senderMessageColor,
                      ),
                      margin: const EdgeInsets.only(bottom: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Hello' * 20,
                        softWrap: true,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: AppColors.messageColor,
                      ),
                      margin: const EdgeInsets.only(bottom: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('Wansai'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: AppColors.senderMessageColor,
                      ),
                      margin: const EdgeInsets.only(bottom: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('College ikha Monday?'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: AppColors.messageColor,
                      ),
                      margin: const EdgeInsets.only(bottom: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('Pareshaan kurhas be'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: AppColors.messageColor,
                      ),
                      margin: const EdgeInsets.only(bottom: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('Adkya kar'),
                    ),
                  )
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
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                        color: AppColors.appBarColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 9.0),
                              child: GestureDetector(
                                onTap: () {},
                                child: const Icon(
                                  Icons.emoji_emotions,
                                  size: 28.0,
                                  color: AppColors.iconColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    _hideElements = false;
                                  } else if (value != ' ') {
                                    _hideElements = true;
                                  } else {
                                    _messageController.text = '';
                                  }

                                  setState(() {});
                                },
                                controller: _messageController,
                                maxLines: 6,
                                minLines: 1,
                                cursorColor: AppColors.tabColor,
                                decoration: const InputDecoration(
                                  hintText: 'Message',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8.0,
                                    right: 8.0,
                                  ),
                                  child: InkWell(
                                    onTap: () {},
                                    child: const Icon(
                                      Icons.link,
                                      size: 28.0,
                                      color: AppColors.iconColor,
                                    ),
                                  ),
                                ),
                                if (!_hideElements) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8.0,
                                      right: 8.0,
                                    ),
                                    child: InkWell(
                                      onTap: () {},
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: AppColors.iconColor,
                                        child: Icon(
                                          Icons.currency_rupee_sharp,
                                          size: 16,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8.0,
                                    ),
                                    child: InkWell(
                                      onTap: () {},
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 22.0,
                                        color: AppColors.iconColor,
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  _hideElements
                      ? CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.tabColor,
                          child: GestureDetector(
                            onTap: () {
                              // final text = _messageController.text.trim();

                            },
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.tabColor,
                          child: GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }
}
