import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/auth/controller/country_picker_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class CountryPage extends ConsumerStatefulWidget {
  const CountryPage({super.key});

  @override
  ConsumerState<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends ConsumerState<CountryPage> {
  final List<Country> _countries = CountryService().getAll();

  void _setCountry(Country country) {
    ref.read(countryPickerControllerProvider.notifier).update(country);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final countryPickerController = ref.watch(countryPickerControllerProvider);
    final selectedCountry = countryPickerController.selectedCountry;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a country'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: ListView.separated(
          itemCount: _countries.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
          itemBuilder: (BuildContext context, int index) {
            final Country country = _countries[index];

            return InkWell(
              onTap: () => _setCountry(country),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      country.flagEmoji,
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    const SizedBox(
                      width: 18.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        Text(
                          country.displayName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                '+${country.phoneCode}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0),
                              ),
                              selectedCountry.name == country.name
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.tabColor,
                                    )
                                  : const Icon(
                                      Icons.check,
                                      color: AppColors.backgroundColor,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
