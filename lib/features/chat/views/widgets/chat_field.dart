import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ChatField extends StatelessWidget {
  const ChatField({
    super.key,
    required this.leading,
    this.actions,
    required this.textController,
    this.onTextChanged,
    this.focusNode,
  });

  final Widget leading;
  final List<Widget>? actions;
  final TextEditingController textController;
  final Function(String)? onTextChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: Theme.of(context).brightness == Brightness.dark
            ? colorTheme.appBarColor
            : colorTheme.backgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: leading,
          ),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: TextField(
              onChanged: onTextChanged,
              controller: textController,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 6,
              minLines: 1,
              cursorColor: colorTheme.greenColor,
              cursorHeight: 20,
              decoration: const InputDecoration(
                hintText: 'Message',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          if (actions != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: e,
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
