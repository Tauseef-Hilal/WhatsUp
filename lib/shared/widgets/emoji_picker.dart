import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class EmojiWrapper {
  const EmojiWrapper({
    required this.emoji,
    required this.category,
  });

  final Emoji emoji;
  final Category category;
}

class CustomEmojiPicker extends ConsumerStatefulWidget {
  const CustomEmojiPicker({
    super.key,
    required this.textController,
    this.afterEmojiPlaced,
  });

  final TextEditingController textController;
  final void Function(Emoji emoji)? afterEmojiPlaced;

  @override
  ConsumerState<CustomEmojiPicker> createState() => _CustomEmojiPickerState();
}

class _CustomEmojiPickerState extends ConsumerState<CustomEmojiPicker> {
  final _scrollController = ScrollController();
  final Map<Category, double> categoryOffsets = {};
  final Map<Category, String> categoryNames = {
    Category.SMILEYS: 'Smileys & People',
    Category.ANIMALS: 'Animals & Nature',
    Category.FOODS: 'Food & Drinks',
    Category.TRAVEL: 'Travel & Places',
    Category.ACTIVITIES: 'Activity',
    Category.OBJECTS: 'Objects',
    Category.SYMBOLS: 'Symbols',
    Category.FLAGS: 'Flags'
  };
  List<List<EmojiWrapper>?> allEmojiRows = [null];
  Category selectedCategory = Category.SMILEYS;

  double emojiFontSize = 0;
  final columnCount = 8;
  final listPadding = 12.0;
  final headerHeight = 26.0;
  final rowGap = 6.0;

  @override
  void initState() {
    _populateEmojiRows();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCategoryOffsets();
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final offset = _scrollController.offset;
    Category currentCategory = selectedCategory;

    for (var entry in categoryOffsets.entries) {
      if (offset < entry.value) break;
      currentCategory = entry.key;
    }

    if (selectedCategory == currentCategory) return;
    setState(() {
      selectedCategory = currentCategory;
    });
  }

  void _populateEmojiRows() {
    for (var categoryEmoji in defaultEmojiSet) {
      var row = <EmojiWrapper>[];

      for (var emoji in categoryEmoji.emoji) {
        row.add(
          EmojiWrapper(
            emoji: emoji,
            category: categoryEmoji.category,
          ),
        );

        if (row.length == columnCount) {
          allEmojiRows.add(row);
          row = [];
        }
      }

      if (row.isNotEmpty) {
        allEmojiRows.add(row);
      }

      if (categoryEmoji == defaultEmojiSet.last) break;
      allEmojiRows.add(null);
    }
  }

  void _calculateCategoryOffsets() {
    double offsetSum = 0;

    for (var (i, emojiRow) in allEmojiRows.indexed) {
      if (emojiRow == null) {
        categoryOffsets[allEmojiRows[i + 1]!.first.category] = offsetSum;
        offsetSum += headerHeight;
      } else {
        offsetSum += emojiFontSize * 1.2 + rowGap;
      }
    }
  }

  void _handleCategoryIconClick(
    CategoryEmoji categoryEmoji,
    double emojiSize,
  ) {
    _scrollController.jumpTo(categoryOffsets[categoryEmoji.category]!);
    setState(
      () => selectedCategory = categoryEmoji.category,
    );
  }

  void _handleBackspaceClick() {
    final controller = widget.textController;
    final text = controller.value.text;
    var cursorPosition = controller.selection.base.offset;

    // If cursor is not set, then place it at the end of the textfield
    if (cursorPosition < 0) {
      controller.selection = TextSelection(
        baseOffset: controller.text.length,
        extentOffset: controller.text.length,
      );

      cursorPosition = controller.selection.base.offset;
    }

    if (cursorPosition < 0) return;

    final selection = controller.value.selection;
    final newTextBeforeCursor =
        selection.textBefore(text).characters.skipLast(1).toString();
    final newText = newTextBeforeCursor + selection.textAfter(text);

    controller
      ..text = newText
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: newTextBeforeCursor.length),
      );

    ref.read(chatControllerProvider.notifier).onTextChanged(newText);
  }

  @override
  Widget build(BuildContext context) {
    emojiFontSize = (MediaQuery.of(context).size.width - 2 * listPadding) /
        (columnCount + 5);
    final emojiSize = emojiFontSize * 1.2;

    final colorTheme = Theme.of(context).custom.colorTheme;
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? colorTheme.iconColor
        : colorTheme.greyColor;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(124, 60, 82, 96)
        : const Color.fromARGB(195, 226, 234, 234);
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 40, 57, 68)
        : const Color.fromARGB(255, 198, 207, 207);

    return EmojiPicker(
      textEditingController: widget.textController,
      onEmojiSelected: (_, emoji) => widget.afterEmojiPlaced?.call(emoji),
      customWidget: (config, state) {
        return Container(
          color: colorTheme.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.drag_handle_rounded,
                size: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.search_rounded),
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: borderColor,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(100.0),
                              bottomLeft: Radius.circular(100.0),
                            ),
                            child: Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: highlightColor,
                                border: Border(
                                  right: BorderSide(
                                    width: 1,
                                    color: borderColor,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.emoji_emotions_outlined,
                                size: 21,
                                color: colorTheme.textColor1,
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  width: 1,
                                  color: borderColor,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    width: 1.2,
                                    color: iconColor,
                                  ),
                                ),
                                child: Text(
                                  'GIF',
                                  style: TextStyle(
                                    color: iconColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(100.0),
                              bottomRight: Radius.circular(100.0),
                            ),
                            child: Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 4,
                              ),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        width: 1.2,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: iconColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                        onTap: _handleBackspaceClick,
                        child: const Icon(Icons.backspace_outlined)),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: listPadding),
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: allEmojiRows.length,
                  itemBuilder: (context, index) {
                    final emojiWrapperRow = allEmojiRows[index];
                    if (emojiWrapperRow == null) {
                      return Container(
                        margin: const EdgeInsets.only(left: 4),
                        height: headerHeight,
                        child: Text(
                          categoryNames[
                              allEmojiRows[index + 1]!.first.category]!,
                          style: TextStyle(
                            color: colorTheme.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    final emojiRow = <Widget>[];
                    for (final emojiWrapper in emojiWrapperRow) {
                      emojiRow.add(
                        SizedBox(
                          width: emojiSize,
                          child: EmojiCell.fromConfig(
                            emoji: emojiWrapper.emoji,
                            emojiSize: emojiFontSize,
                            config: config,
                            onEmojiSelected: (category, emoji) {
                              state.onEmojiSelected(category, emoji);
                            },
                          ),
                        ),
                      );
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: rowGap),
                      height: emojiSize,
                      child: Row(
                        mainAxisAlignment: emojiRow.length < config.columns
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.spaceBetween,
                        children: emojiRow,
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                color: Theme.of(context).brightness == Brightness.dark
                    ? colorTheme.appBarColor
                    : colorTheme.backgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...state.categoryEmoji.map(
                      (categoryEmoji) =>
                          categoryEmoji.category == Category.RECENT
                              ? Container()
                              : InkWell(
                                  onTap: () {
                                    _handleCategoryIconClick(
                                      categoryEmoji,
                                      emojiFontSize,
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: selectedCategory ==
                                            categoryEmoji.category
                                        ? highlightColor
                                        : Colors.transparent,
                                    foregroundColor: iconColor,
                                    radius: 16,
                                    child: Icon(
                                      config.getIconForCategory(
                                        categoryEmoji.category,
                                      ),
                                      size: 20,
                                    ),
                                  ),
                                ),
                    ),
                    Container()
                  ],
                ),
              ),
              if (Platform.isIOS) const SizedBox(height: 24),
            ],
          ),
        );
      },
      config: Config(
        columns: columnCount,
        emojiSizeMax: emojiFontSize,
      ),
    );
  }
}
