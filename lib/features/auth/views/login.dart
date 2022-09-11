import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_number/phone_number.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/auth/controller/login_controller.dart';
import 'package:whatsapp_clone/features/auth/views/countries.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/dialogs.dart';
import 'package:whatsapp_clone/theme/colors.dart';
import 'package:whatsapp_clone/shared/widgets/buttons.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String phoneNumber = '';
  final _phoneCodeController = TextEditingController(text: '91');
  var _phoneNumberController = PhoneNumberEditingController(
    PhoneNumberUtil(),
    regionCode: 'IN',
    behavior: PhoneInputBehavior.strict,
  );

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(_phoneNumberListener);
  }

  void _phoneNumberListener() async {
    phoneNumber = ref
        .read(phoneNumberControllerProvider.notifier)
        .update(_phoneNumberController.text);
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _phoneCodeController.dispose();
    super.dispose();
  }

  void _showCountryPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => const CountryPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(phoneCodeControllerProvider, (previous, next) {
      _phoneCodeController.text = next;
      _onPhoneCodeChanged(_phoneCodeController.text);
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final selectedCountry = ref.watch(countryPickerControllerProvider);
    phoneNumber = ref.read(phoneNumberControllerProvider);

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
                    onChanged: (value) {
                      _onPhoneCodeChanged(value);
                    },
                    style: Theme.of(context).textTheme.bodyText2,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    cursorColor: AppColors.tabColor,
                    controller: _phoneCodeController,
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
                    controller: _phoneNumberController,
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
                String phoneNumberWithCode =
                    '+${selectedCountry.phoneCode} $phoneNumber';

                bool isValidPhoneNumber =
                    await PhoneNumberUtil().validate(phoneNumberWithCode);

                String errorMsg = '';
                if (selectedCountry.name == 'No such country') {
                  errorMsg = 'Invalid country code.';

                  if (isValidPhoneNumber) {
                    isValidPhoneNumber = !isValidPhoneNumber;
                  }
                }

                if (!isValidPhoneNumber) {
                  if (errorMsg.isEmpty) {
                    errorMsg = _phoneNumberController.text.isEmpty
                        ? 'Please enter your phone number.'
                        : 'The phone number your entered is invalid '
                            'for the country: ${selectedCountry.name}';
                  }

                  return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actionsPadding: const EdgeInsets.all(0),
                        backgroundColor: AppColors.appBarColor,
                        content: Text(
                          errorMsg,
                          style: Theme.of(context).textTheme.bodySmall!,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
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
                }

                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationDialog(
                      backgroundColor: AppColors.appBarColor,
                      actionButtonTextColor: AppColors.tabColor,
                      actionCallbacks: {
                        'EDIT': () => Navigator.of(context).pop(),
                        'OK': () async {
                          final authController = ref.read(
                            authControllerProvider,
                          );

                          await authController.initiateAuthenticationProcess(
                            context,
                            phoneNumberWithCode,
                          );
                        },
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You entered the phone number:',
                            style: Theme.of(context).textTheme.bodySmall!,
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            phoneNumberWithCode,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Is this OK, or would you like to edit '
                            'the number?',
                            style: Theme.of(context).textTheme.bodySmall!,
                          ),
                        ],
                      ),
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

  void _onPhoneCodeChanged(String value) async {
    Country country;
    if (value.isEmpty) {
      country = Country(
        phoneCode: '',
        countryCode: '',
        e164Sc: -1,
        geographic: false,
        level: -1,
        name: 'No such country',
        example: '',
        displayName: 'No such country',
        fullExampleWithPlusSign: '',
        displayNameNoCountryCode: 'No such country',
        e164Key: '',
      );
    } else {
      List results = countriesList
          .where(
            (country) => country.phoneCode == value,
          )
          .toList();

      if (results.isEmpty) {
        country = Country(
          phoneCode: value,
          countryCode: '',
          e164Sc: -1,
          geographic: false,
          level: -1,
          name: 'No such country',
          example: '',
          displayName: 'No such country',
          fullExampleWithPlusSign: '',
          displayNameNoCountryCode: 'No such country',
          e164Key: '',
        );
      } else {
        country = results[0];
      }
    }

    await ref.read(countryPickerControllerProvider.notifier).update(country);

    _phoneNumberController.dispose();
    _phoneNumberController = PhoneNumberEditingController(
      PhoneNumberUtil(),
      text: ref.read(phoneNumberControllerProvider),
      regionCode: country.countryCode,
      behavior: PhoneInputBehavior.strict,
    )..addListener(_phoneNumberListener);
  }
}
