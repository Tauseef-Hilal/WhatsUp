import 'package:flutter/material.dart';

import 'package:whatsapp_clone/features/auth/views/last.dart';
import 'package:whatsapp_clone/shared/widgets/buttons.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class UserProfileCreationPage extends StatelessWidget {
  const UserProfileCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile info'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            Text(
              'Please provide your name and an optional profile photo',
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 32.0),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(150),
                color: AppColors.appBarColor,
              ),
              child: const Icon(
                Icons.add_a_photo,
                color: AppColors.iconColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 32.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {},
                      autofocus: true,
                      style: Theme.of(context).textTheme.bodyText1,
                      cursorColor: AppColors.tabColor,
                      decoration: InputDecoration(
                        hintText: 'Type your name here',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: AppColors.iconColor),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.tabColor,
                            width: 1,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.tabColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.emoji_emotions,
                      color: AppColors.iconColor,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: SizedBox(
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 150,
                vertical: 55,
              ),
              child: GreenElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const AuthCompletePage(),
                      ),
                      (route) => false);
                },
                text: 'NEXT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
