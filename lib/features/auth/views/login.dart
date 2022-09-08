import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/auth/controller/login_controller.dart';
import 'package:whatsapp_clone/features/auth/views/countries.dart';
import 'package:whatsapp_clone/theme/colors.dart';
import 'package:whatsapp_clone/shared/widgets/buttons.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _countries = CountryService().getAll();

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
  }

  void _showCountryPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => const CountryPage()),
      ),
    );
  }

  Future<void> _sendVerificationCode(BuildContext context) async {
    final countryPickerController = ref.read(countryPickerControllerProvider);
    final country = countryPickerController.selectedCountry;
    final phoneNumber = '+${country.phoneCode}${_phoneController.text.trim()}';

    if (phoneNumber.isEmpty || country.phoneCode.isEmpty) {
      return;
    }

    countryPickerController.phoneCodeController.dispose();

    final authController = ref.read(authControllerProvider);
    await authController.signInWithPhone(context, phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final countryPickerController = ref.watch(countryPickerControllerProvider);
    final selectedCountry = countryPickerController.selectedCountry;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your phone number'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
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
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.textColor),
                children: const [
                  TextSpan(
                    text: 'WhatsApp will need to verify your phone number. ',
                  ),
                  TextSpan(
                    text: 'What\'s my number?',
                    style: TextStyle(color: AppColors.linkColor),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showCountryPage(context),
            child: Container(
              padding: const EdgeInsets.only(top: 18.0),
              width: 0.60 * screenWidth,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.tabColor,
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
                    onTap: () => _showCountryPage(context),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.tabColor,
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
                    onChanged: _onPhoneCodeChanged,
                    style: Theme.of(context).textTheme.bodyText2,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    cursorColor: AppColors.tabColor,
                    controller: countryPickerController.phoneCodeController,
                    decoration: const InputDecoration(
                      prefixText: '+ ',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.tabColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.tabColor,
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
                    onChanged: (value) {},
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyText2,
                    keyboardType: TextInputType.phone,
                    cursorColor: AppColors.tabColor,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Phone number',
                      hintStyle: Theme.of(context).textTheme.bodySmall,
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Carrier charges may apply.',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          const Expanded(
            child: SizedBox(
              height: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 55),
            child: GreenElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppColors.appBarColor,
                      content: SizedBox(
                        height: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You entered the phone number:',
                              style: Theme.of(context).textTheme.bodySmall!,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              _phoneController.text.length > 5
                                  ? ('+${selectedCountry.phoneCode} '
                                      '${_phoneController.text.substring(0, 5)} '
                                      '${_phoneController.text.substring(5)}')
                                  : '+${selectedCountry.phoneCode} '
                                      '${_phoneController.text}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Is this OK, or would you like too edit '
                              'the number?',
                              style: Theme.of(context).textTheme.bodySmall!,
                            ),
                          ],
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'EDIT',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: AppColors.tabColor),
                          ),
                        ),
                        TextButton(
                          onPressed: () async =>
                              await _sendVerificationCode(context),
                          child: Text(
                            'OK',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: AppColors.tabColor),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              text: 'NEXT',
            ),
          ),
        ],
      ),
    );
  }

  void _onPhoneCodeChanged(value) {
    if (value.isEmpty) {
      return ref.read(countryPickerControllerProvider.notifier).update(
            country: Country(
              phoneCode: value,
              countryCode: '',
              e164Sc: -1,
              geographic: false,
              level: -1,
              name: '',
              example: '',
              displayName: '',
              displayNameNoCountryCode: 'No such country',
              e164Key: '',
            ),
          );
    }

    List results =
        _countries.where((country) => country.phoneCode == value).toList();

    if (results.isNotEmpty) {
      ref
          .read(countryPickerControllerProvider.notifier)
          .update(country: results[0]);
    } else {
      ref.read(countryPickerControllerProvider.notifier).update(
            country: Country(
              phoneCode: value,
              countryCode: '',
              e164Sc: -1,
              geographic: false,
              level: -1,
              name: '',
              example: '',
              displayName: '',
              displayNameNoCountryCode: 'No such country',
              e164Key: '',
            ),
          );
    }
  }
}
