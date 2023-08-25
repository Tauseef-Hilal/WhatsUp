import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../utils/abc.dart';

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
  final Map<Category, List<int>> categoryIndices = {};
  List<List<EmojiWrapper>?> allEmojiRows = [null];
  Category? selectedCategory;

  @override
  void initState() {
    for (var categoryEmoji in defaultEmojiSet) {
      var row = <EmojiWrapper>[];
      int rowCount = 0;

      for (var emoji in categoryEmoji.emoji) {
        row.add(
          EmojiWrapper(
            emoji: emoji,
            category: categoryEmoji.category,
          ),
        );

        if (row.length == 8) {
          allEmojiRows.add(row);
          row = [];
          rowCount++;
        }
      }

      if (row.isNotEmpty) {
        allEmojiRows.add(row);
        rowCount++;
      }

      if (categoryEmoji == defaultEmojiSet.last) {
        categoryIndices[categoryEmoji.category] = [
          allEmojiRows.length - rowCount - 1,
          categoryIndices.keys.length
        ];
        break;
      }

      allEmojiRows.add(null);
      categoryIndices[categoryEmoji.category] = [
        allEmojiRows.length - rowCount - 2,
        categoryIndices.keys.length
      ];
    }

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onBackspacePressed() {
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

    controller
      ..text = newTextBeforeCursor + selection.textAfter(text)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: newTextBeforeCursor.length),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final emojiSize = MediaQuery.of(context).size.width / 14;

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
                          color: const Color.fromARGB(255, 40, 57, 68),
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
                                // vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorTheme.appBarColor,
                                border: const Border(
                                  right: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 40, 57, 68),
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.emoji_emotions_outlined,
                                size: 21,
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  width: 1,
                                  color: Color.fromARGB(255, 40, 57, 68),
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
                                    color: colorTheme.iconColor,
                                  ),
                                ),
                                child: Text(
                                  'GIF',
                                  style: TextStyle(
                                    color: colorTheme.iconColor,
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
                                        color: colorTheme.iconColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: colorTheme.iconColor,
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
                        onTap: _onBackspacePressed,
                        child: const Icon(Icons.backspace_outlined)),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  padding: config.gridPadding,
                  itemCount: allEmojiRows.length,
                  itemBuilder: (context, index) {
                    final emojiWrapperRow = allEmojiRows[index];
                    if (emojiWrapperRow == null) {
                      return Container(
                        margin: const EdgeInsets.only(left: 12),
                        height: emojiSize,
                        child: Text(
                          titleCased(
                            allEmojiRows[index + 1]!.first.category.name,
                          ),
                          style: TextStyle(
                            color: colorTheme.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    final emojiRow = <EmojiCell>[];
                    for (final emojiWrapper in emojiWrapperRow) {
                      emojiRow.add(
                        EmojiCell.fromConfig(
                          emoji: emojiWrapper.emoji,
                          emojiSize: config.emojiSizeMax,
                          index: index,
                          config: config,
                          onEmojiSelected: (category, emoji) {
                            state.onEmojiSelected(category, emoji);
                          },
                        ),
                      );
                    }

                    return SizedBox(
                      height: emojiSize * 1.6,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12.0,
                          left: 12.0,
                          right: 12.0,
                        ),
                        child: Row(
                          mainAxisAlignment: emojiRow.length < config.columns
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.spaceBetween,
                          children: emojiRow,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                color: colorTheme.appBarColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...state.categoryEmoji
                        .map(
                          (categoryEmoji) => categoryEmoji.category ==
                                  Category.RECENT
                              ? Container()
                              : InkWell(
                                  onTap: () {
                                    handleCategoryIconClick(
                                      categoryEmoji,
                                      emojiSize,
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: selectedCategory ==
                                            categoryEmoji.category
                                        ? const Color.fromARGB(124, 60, 82, 96)
                                        : Colors.transparent,
                                    foregroundColor: colorTheme.iconColor,
                                    radius: 16,
                                    child: Icon(
                                      config.getIconForCategory(
                                        categoryEmoji.category,
                                      ),
                                      size: 20,
                                    ),
                                  ),
                                ),
                        )
                        .toList(),
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
        columns: 8,
        emojiSizeMax: emojiSize,
      ),
    );
  }

  void handleCategoryIconClick(CategoryEmoji categoryEmoji, double emojiSize) {
    final [categoryIndex, seenCategoryCount] =
        categoryIndices[categoryEmoji.category]!;
    final offset = (categoryIndex * emojiSize * 1.6) -
        (seenCategoryCount * emojiSize / 1.6);

    _scrollController.jumpTo(offset);
    setState(
      () => selectedCategory = categoryEmoji.category,
    );
  }
}
