import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_keyboard/models/keyboard_config.dart';

class EmojiPickerWidget extends StatefulWidget {
  final KeyboardConfig keyboardConfig;
  final Function(Category?, Emoji)? onEmojiSelected;
  final Function()? onBackspacePressed;
  const EmojiPickerWidget({
    Key? key,
    required this.keyboardConfig,
    this.onEmojiSelected,
    this.onBackspacePressed,
  }) : super(key: key);

  @override
  State<EmojiPickerWidget> createState() => _EmojiPickerWidgetState();
}

class _EmojiPickerWidgetState extends State<EmojiPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      onEmojiSelected: widget.onEmojiSelected,
      onBackspacePressed: null,
      config: Config(
        // height: widget.keyboardConfig.hei,
        skinToneConfig: const SkinToneConfig(),
        checkPlatformCompatibility: true,
        viewOrderConfig: const ViewOrderConfig(
          top: EmojiPickerItem.categoryBar,
          middle: EmojiPickerItem.emojiView,
          bottom: EmojiPickerItem.searchBar,
        ),
        emojiViewConfig: EmojiViewConfig(
          emojiSizeMax: widget.keyboardConfig.emojiSizeMax,
          backgroundColor: widget.keyboardConfig.bgColor,
        ),
        categoryViewConfig: CategoryViewConfig(
          indicatorColor: widget.keyboardConfig.indicatorColor,
          dividerColor: Colors.transparent,
          backgroundColor: widget.keyboardConfig.bgColor,
          iconColorSelected: widget.keyboardConfig.iconColorSelected,
          categoryIcons: widget.keyboardConfig.categoryIcons,
        ),
        bottomActionBarConfig: BottomActionBarConfig(
          backgroundColor: widget.keyboardConfig.bgColor,
          buttonColor: widget.keyboardConfig.bgColor,
          buttonIconColor: widget.keyboardConfig.iconColor,
        ),
        searchViewConfig: SearchViewConfig(
          backgroundColor: widget.keyboardConfig.bgColor,
          buttonIconColor: widget.keyboardConfig.iconColor,
        ),
      ),
    );
  }
}
