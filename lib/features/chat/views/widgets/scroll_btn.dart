import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ScrollButton extends StatefulWidget {
  const ScrollButton({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  State<ScrollButton> createState() => _ScrollButtonState();
}

class _ScrollButtonState extends State<ScrollButton> {
  bool showScrollBtn = false;

  @override
  void initState() {
    widget.scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollPosition = widget.scrollController.position;
      setState(() {
        showScrollBtn = scrollPosition.pixels < scrollPosition.maxScrollExtent;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() {
    final position = widget.scrollController.position;
    final diff = position.maxScrollExtent - position.pixels;

    if (showScrollBtn && diff > 500) {
      return;
    }

    if (showScrollBtn && diff <= 500) {
      setState(() => showScrollBtn = false);
      return;
    }

    if (showScrollBtn || diff <= 500) return;
    setState(() => showScrollBtn = true);
  }

  void handleScrollBtnClick() {
    widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );

    setState(() => showScrollBtn = false);
  }

  @override
  Widget build(BuildContext context) {
    return showScrollBtn
        ? GestureDetector(
            onTap: handleScrollBtnClick,
            child: Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).custom.colorTheme.appBarColor,
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black38,
                  )
                ],
              ),
              child: const Icon(Icons.keyboard_double_arrow_down),
            ),
          )
        : Container();
  }
}
