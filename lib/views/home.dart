import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WhatsApp'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.tabColor,
            indicatorWeight: 3.0,
            labelColor: AppColors.tabColor,
            unselectedLabelColor: AppColors.textColor,
            tabs: [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(),
                  title: const Text('Basit Bai'),
                  subtitle: Text(
                    'WhatsApp is under construction.',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  trailing: Text(
                    '15:41',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(),
                  title: const Text('Aqib Bai'),
                  subtitle: Text(
                    'Where are you?',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  trailing: Text(
                    '15:01',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(),
                  title: const Text('Saqib Bai'),
                  subtitle: Text(
                    'College chukha az',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  trailing: Text(
                    '14:41',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),
            ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(),
                  title: const Text('My status'),
                  subtitle: Text(
                    'Tap to add status update',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Recent Updates',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                ...[
                  ListTile(
                    leading: const CircleAvatar(),
                    title: const Text('Zubair'),
                    subtitle: Text(
                      'Today, 11:34 AM',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  )
                ],
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Viewed Updates',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                ...[
                  ListTile(
                    leading: const CircleAvatar(),
                    title: const Text('Umar Jr'),
                    subtitle: Text(
                      'Today, 10:34 AM',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  ListTile(
                    leading: const CircleAvatar(),
                    title: const Text('Sahil'),
                    subtitle: Text(
                      'Today, 02:34 PM AM',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ],
              ],
            ),
            ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(),
                  title: const Text('Aqib Bai'),
                  subtitle: Row(
                    children: [
                      const Text(
                        '↙',
                        style: TextStyle(color: Colors.green),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        'Yesterday, 08:34 PM',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.videocam,
                    color: AppColors.tabColor,
                    size: 25,
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(),
                  title: const Text('Basit Bai'),
                  subtitle: Row(
                    children: [
                      const Text(
                        '↗',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        'Today, 02:34 PM',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.call,
                    color: AppColors.tabColor,
                    size: 25,
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(),
                  title: const Text('Aqib Bai'),
                  subtitle: Row(
                    children: [
                      const Text(
                        '↙',
                        style: TextStyle(color: Colors.green),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        'Yesterday, 08:34 PM',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.videocam,
                    color: AppColors.tabColor,
                    size: 25,
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
