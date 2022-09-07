import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/theme/colors.dart';
import 'package:whatsapp_clone/shared/widgets/buttons.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  String countryCode = '';

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
  }

  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      onSelect: (country) {
        setState(() {
          countryCode = '+${country.phoneCode}';
        });
      },
    );
  }

  Future<void> _sendVerificationCode(BuildContext context) async {
    String phoneNumber = countryCode + _phoneController.text.trim();
    if (phoneNumber.isEmpty || countryCode.isEmpty) {
      return;
    }

    final authController = ref.read(authControllerProvider);
    await authController.signInWithPhone(context, phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your phone number'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          const Text('WhatsApp will need to verify your phone number.'),
          TextButton(
            onPressed: () => _showCountryPicker(context),
            child: const Text('Pick country'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(countryCode),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: TextField(
                    onChanged: (value) {},
                    keyboardType: TextInputType.phone,
                    cursorColor: AppColors.tabColor,
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.tabColor),
                      ),
                    ),
                  ),
                ),
              ],
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
              onPressed: () async => await _sendVerificationCode(context),
              text: 'NEXT',
            ),
          ),
        ],
      ),
    );
  }
}
