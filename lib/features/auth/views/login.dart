import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/domain/auth_service.dart';

import 'package:whatsapp_clone/features/auth/controllers/login_controller.dart';
import 'package:whatsapp_clone/features/auth/views/verification.dart';

import 'package:whatsapp_clone/shared/utils/shared_pref.dart';
import 'package:whatsapp_clone/shared/utils/snackbars.dart';
import 'package:whatsapp_clone/shared/widgets/buttons.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../shared/models/user.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool gotKeyboardHeight = false;

  @override
  void initState() {
    ref.read(loginControllerProvider.notifier).init(() async {
      if (gotKeyboardHeight) return;

      double keyboardSize = MediaQuery.of(context).viewInsets.bottom;

      SharedPref.instance.setDouble('keyboardHeight', keyboardSize);

      if (keyboardSize < 300) return;
      gotKeyboardHeight = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(verificationCodeProvider, (previous, next) {
      final formattedPhoneNumber =
          '+${ref.read(loginControllerProvider).phoneCode.trim()} ${ref.read(loginControllerProvider.notifier).phoneNumberController.text.trim()}';
      final phone = Phone(
        code: '+${ref.read(loginControllerProvider).phoneCode.trim()}',
        number: ref
            .read(loginControllerProvider.notifier)
            .phoneNumberController
            .text
            .replaceAll(' ', '')
            .replaceAll('-', '')
            .replaceAll('(', '')
            .replaceAll(')', ''),
        formattedNumber: formattedPhoneNumber,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => VerificationPage(phone: phone),
        ),
        (route) => false,
      );

      showSnackBar(
        context: context,
        content: "OTP Sent!",
        type: SnacBarType.info,
      );
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final selectedCountry = ref.watch(loginControllerProvider);
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorTheme.statusBarColor,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarColor: colorTheme.navigationBarColor,
          systemNavigationBarDividerColor: colorTheme.navigationBarColor,
        ),
        backgroundColor: colorTheme.backgroundColor,
        title: Text(
          'Enter your phone number',
          style: TextStyle(color: colorTheme.textColor1),
        ),
        centerTitle: true,
        actions: [
          Icon(
            Icons.more_vert_rounded,
            color: colorTheme.greyColor,
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: colorTheme.textColor1),
                children: [
                  const TextSpan(
                    text: 'WhatsApp will need to verify your phone number. ',
                  ),
                  TextSpan(
                    text: 'What\'s my number?',
                    style: TextStyle(color: colorTheme.blueColor),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ref
                .read(loginControllerProvider.notifier)
                .showCountryPage(context),
            child: Container(
              padding: const EdgeInsets.only(top: 18.0),
              width: 0.60 * screenWidth,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorTheme.greenColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedCountry.displayNameNoCountryCode,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref
                        .read(loginControllerProvider.notifier)
                        .showCountryPage(context),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: colorTheme.greenColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 0.75 * screenWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 0.25 * (screenWidth * 0.60),
                  child: TextField(
                    onChanged: (value) {
                      ref
                          .read(loginControllerProvider.notifier)
                          .onPhoneCodeChanged(value);
                    },
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    cursorColor: colorTheme.greenColor,
                    controller: ref
                        .read(loginControllerProvider.notifier)
                        .phoneCodeController,
                    decoration: InputDecoration(
                      prefixText: '+ ',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: colorTheme.greenColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: colorTheme.greenColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 0.05 * (screenWidth * 0.60),
                ),
                SizedBox(
                  width: 0.70 * (screenWidth * 0.60),
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    cursorColor: colorTheme.greenColor,
                    controller: ref
                        .read(loginControllerProvider.notifier)
                        .phoneNumberController,
                    decoration: InputDecoration(
                      hintText: 'Phone number',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: colorTheme.greenColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: colorTheme.greenColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Carrier charges may apply.',
              style: TextStyle(color: colorTheme.textColor2),
            ),
          ),
          const Expanded(
            child: SizedBox(
              height: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 12),
            child: GreenElevatedButton(
              onPressed: () => ref
                  .read(loginControllerProvider.notifier)
                  .onNextBtnPressed(context),
              text: 'Next',
            ),
          ),
        ],
      ),
    );
  }
}
