import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:whatsapp_clone/features/auth/controllers/login_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/widgets/search.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class CountryPage extends ConsumerStatefulWidget {
  const CountryPage({super.key});

  @override
  ConsumerState<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends ConsumerState<CountryPage> {
  @override
  void initState() {
    ref.read(countryPickerControllerProvider.notifier).init();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(countryPickerControllerProvider.notifier).initialUpdate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(countryPickerControllerProvider);
    final colorTheme = Theme.of(context).custom.colorTheme;

    return ScaffoldWithSearch(
      searchIconActionIndex: 0,
      hintText: 'Search for a country',
      searchController:
          ref.read(countryPickerControllerProvider.notifier).searchController,
      onChanged: (value) => ref
          .read(countryPickerControllerProvider.notifier)
          .updateSearchResults(value),
      onCloseBtnPressed:
          ref.read(countryPickerControllerProvider.notifier).onCrossPressed,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Choose a country'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: ListView.separated(
          itemCount: searchResults.isEmpty ? 1 : searchResults.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: colorTheme.greyColor,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            final Country country;

            try {
              country = searchResults[index];
            } catch (_) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No matches found'),
                  ),
                  Divider(
                    color: colorTheme.greyColor,
                  ),
                ],
              );
            }

            return InkWell(
              onTap: () => ref
                  .read(countryPickerControllerProvider.notifier)
                  .setCountry(context, country),
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
                              ref.read(loginControllerProvider).name ==
                                      country.name
                                  ? Icon(
                                      Icons.check,
                                      color: colorTheme.greenColor,
                                    )
                                  : Icon(
                                      Icons.check,
                                      color: colorTheme.backgroundColor,
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
