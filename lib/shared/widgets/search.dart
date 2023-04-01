import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ScaffoldWithSearch extends StatefulWidget {
  final AppBar appBar;
  final int searchIconActionIndex;
  final String hintText;
  final TextEditingController searchController;
  final Function(String value) onChanged;
  final Function() onCloseBtnPressed;
  final Widget child;

  const ScaffoldWithSearch({
    super.key,
    required this.appBar,
    this.hintText = 'Search...',
    this.searchIconActionIndex = 0,
    required this.searchController,
    required this.onChanged,
    required this.onCloseBtnPressed,
    required this.child,
  });

  @override
  State<ScaffoldWithSearch> createState() => _ScaffoldWithSearchState();
}

class _ScaffoldWithSearchState extends State<ScaffoldWithSearch> {
  int appBarIndex = 0;
  Widget? _showCross = const Text('');

  @override
  Widget build(BuildContext context) {
    final appBars = [
      widget.appBar
        ..actions!.insert(
          widget.searchIconActionIndex,
          IconButton(
            onPressed: () {
              setState(() {
                appBarIndex++;
              });
            },
            icon: const Icon(Icons.search),
          ),
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

            widget.onChanged(value);
          },
          autofocus: true,
          controller: widget.searchController,
          style: Theme.of(context)
              .custom
              .textTheme
              .subtitle1
              .copyWith(color: Colors.white),
          cursorColor: Theme.of(context).custom.colorTheme.greenColor,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(context)
                .custom
                .textTheme
                .subtitle1
                .copyWith(color: Colors.white),
            border: InputBorder.none,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            appBarIndex--;

            widget.onChanged('');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          _showCross ??
              IconButton(
                onPressed: () {
                  widget.onCloseBtnPressed();

                  setState(() {
                    _showCross = const Text('');
                  });
                },
                icon: const Icon(
                  Icons.close,
                ),
              ),
        ],
        centerTitle: false,
      ),
    ];

    return Scaffold(
      appBar: appBars[appBarIndex],
      body: widget.child,
    );
  }
}
