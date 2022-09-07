import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  bool _hideElements = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(),
            const SizedBox(
              width: 10.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Abuji'),
                Text(
                  'Online',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ],
        ),
        leadingWidth: 35.0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_rounded),
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: AppColors.messageColor,
                      ),
                      margin: const EdgeInsets.only(bottom: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('Hello'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
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
                        borderRadius: BorderRadius.circular(4.0),
                        color: AppColors.messageColor,
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
                        borderRadius: BorderRadius.circular(4.0),
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
                        borderRadius: BorderRadius.circular(4.0),
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: AppColors.appBarColor,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    margin: const EdgeInsets.only(bottom: 24.0, right: 4.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.emoji_emotions,
                            color: AppColors.iconColor,
                          ),
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty) {
                                  _hideElements = true;
                                } else {
                                  _hideElements = false;
                                }
                              });
                            },
                            maxLines: 100,
                            minLines: 1,
                            cursorColor: AppColors.tabColor,
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Message',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.attach_file_sharp,
                                color: AppColors.iconColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.attach_money,
                                color: AppColors.iconColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.iconColor,
                              ),
                            ),
                          ].sublist(0, _hideElements ? 1 : 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: AppColors.tabColor,
                  ),
                  margin: const EdgeInsets.only(bottom: 24.0),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
