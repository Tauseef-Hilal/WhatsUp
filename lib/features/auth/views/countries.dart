import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:whatsapp_clone/features/auth/controller/login_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class CountryPage extends ConsumerStatefulWidget {
  const CountryPage({super.key});

  @override
  ConsumerState<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends ConsumerState<CountryPage> {
  Widget? _showCross = const Text('');
  int appBarIndex = 0;

  @override
  void initState() {
    ref.read(countryPickerControllerProvider.notifier).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(countryPickerControllerProvider);

    final appBars = [
      AppBar(
        elevation: 0.0,
        title: const Text('Choose a country'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                appBarIndex++;
              });
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      AppBar(
        elevation: 0.0,
        title: TextField(
          onChanged: (value) {
            if (value.isNotEmpty) {
              _showCross = null;
            } else {
              _showCross = const Text('');
            }

            ref
                .read(countryPickerControllerProvider.notifier)
                .updateSearchResults(value);
          },
          autofocus: true,
          controller: ref
              .read(countryPickerControllerProvider.notifier)
              .searchController,
          style: Theme.of(context).textTheme.bodyText2,
          cursorColor: AppColors.tabColor,
          decoration: const InputDecoration(
            hintText: 'Search countries',
            border: InputBorder.none,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            setState(() {
              appBarIndex--;
            });
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          _showCross ??
              IconButton(
                onPressed: () {
                  ref
                      .read(countryPickerControllerProvider.notifier)
                      .onCrossPressed();

                  setState(() {
                    _showCross = const Text('');
                  });
                },
                icon: const Icon(
                  Icons.close,
                  // style: TextStyle(color: AppColors.iconColor),
                ),
              ),
        ],
        centerTitle: false,
      ),
    ];

    return Scaffold(
      appBar: appBars[appBarIndex],
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: ListView.separated(
          itemCount: searchResults.isEmpty ? 1 : searchResults.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              color: AppColors.greyColor,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            final Country country;

            try {
              country = searchResults[index];
            } catch (_) {
              return Column(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No matches found'),
                  ),
                  Divider(
                    color: AppColors.greyColor,
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
