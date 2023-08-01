import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ScrollButton extends ConsumerStatefulWidget {
  const ScrollButton({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  ConsumerState<ScrollButton> createState() => _ScrollButtonState();
}

class _ScrollButtonState extends ConsumerState<ScrollButton> {
  @override
  void initState() {
    widget.scrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() {
    final position = widget.scrollController.position;
    final diff = position.pixels - position.minScrollExtent;
    final showScrollBtn = ref.read(chatControllerProvider).showScrollBtn;

    if (showScrollBtn && diff > 80) {
      return;
    }

    if (showScrollBtn && diff <= 80) {
      ref.read(chatControllerProvider.notifier).toggleScrollBtnVisibility();
      return;
    }

    if (showScrollBtn || diff <= 80) return;
    ref.read(chatControllerProvider.notifier).toggleScrollBtnVisibility();
  }

  void handleScrollBtnClick() {
    widget.scrollController.animateTo(
      widget.scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );

    ref.read(chatControllerProvider.notifier).toggleScrollBtnVisibility();
  }

  @override
  Widget build(BuildContext context) {
    final showScrollBtn = ref.watch(chatControllerProvider).showScrollBtn;
    final unreadCount = ref.watch(chatControllerProvider).unreadCount;

    return showScrollBtn
        ? GestureDetector(
            onTap: handleScrollBtnClick,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                if (unreadCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).custom.colorTheme.greenColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        : Container();
  }
}
