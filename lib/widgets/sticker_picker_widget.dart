import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_social_keyboard/models/category_sticker.dart';
import 'package:flutter_social_keyboard/models/keyboard_config.dart';
import 'package:flutter_social_keyboard/models/recent_sticker.dart';
import 'package:flutter_social_keyboard/models/sticker.dart';
import 'package:flutter_social_keyboard/utils/sticker_picker_internal_utils.dart';
import 'package:flutter_social_keyboard/widgets/display/sticker_display.dart';

class StickerPickerWidget extends StatefulWidget {
  const StickerPickerWidget({
    Key? key,
    required this.keyboardConfig,
    this.onStickerSelected,
    required this.scrollStream,
    required this.stickers,
  }) : super(key: key);

  final Function(Sticker)? onStickerSelected;
  final KeyboardConfig keyboardConfig;
  final StreamController<String> scrollStream;
  final List<CategorySticker> stickers;

  @override
  State<StickerPickerWidget> createState() => StickerPickerWidgetState();
}

class StickerPickerWidgetState extends State<StickerPickerWidget>
    with SingleTickerProviderStateMixin {
  final int initCategory = 0;
  final double tabBarHeight = 46;

  PageController? _pageController;
  TabController? _tabController;
  final List<String> _tabs = List.empty(growable: true); //[''];

  final List<CategorySticker> _categorySticker = List.empty(growable: true);

  List<RecentSticker> _recentSticker = List.empty(growable: true);

  bool _loaded = false;

  void updateRecentSticker(List<RecentSticker> recentSticker,
      {bool refresh = false}) {
    _recentSticker = recentSticker;
    _categorySticker[0] = _categorySticker[0]
        .copyWith(stickers: _recentSticker.map((e) => e.sticker).toList());
    if (mounted && refresh) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _listAssets();
    if (widget.keyboardConfig.showRecentsTab) {
      _tabs.add('');
    }

    _pageController = PageController(initialPage: initCategory)
      ..addListener((() => widget.scrollStream.add('showNav')));
  }

  Future _listAssets() async {
    // Load from properties

    // Filter by path
    // TODO: Add properties and obtain the list
    // _allStickers = manifestMap.keys
    //     .where((path) => path.startsWith('assets/stickers/'))
    //     .where(
    //       (path) =>
    //           (path.toLowerCase()).endsWith(".webp") ||
    //           (path.toLowerCase()).endsWith(".png") ||
    //           (path.toLowerCase()).endsWith(".jpg") ||
    //           (path.toLowerCase()).endsWith(".gif") ||
    //           (path.toLowerCase()).endsWith(".jpeg"),
    //     )
    //     .toList();

    //  Get folder names from categories and tab titles
    List<String> tabsTitle = [];
    for (var i = 0; i < widget.stickers.length; i++) {
      String s = widget.stickers[i].category;
      if (!tabsTitle.contains(s)) {
        tabsTitle.add(s);
      }
    }

    //Add titles to tab list and create tab controller
    _tabs.addAll(tabsTitle);
    _tabController = TabController(
        initialIndex: initCategory,
        length: _tabs.length + (widget.keyboardConfig.showRecentsTab ? 1 : 0),
        vsync: this)
      ..addListener(() => widget.scrollStream.add('showNav'));

    //Get stickers and group them based on tabs
    _updateStickers();
  }

  Widget _buildCategory(int index, String title) {
    return Tab(
      child: index == 0
          ? const Icon(Icons.access_time)
          : Text(
              title.toUpperCase(),
            ),
    );
  }

  // Initialize sticker data
  Future<void> _updateStickers() async {
    _categorySticker.clear();
    final length =
        _tabs.length + (widget.keyboardConfig.showRecentsTab ? 1 : 0);
    for (var i = 0; i < length; i++) {
      if (i == 0 && widget.keyboardConfig.showRecentsTab) {
        List<Sticker> recents =
            (await StickerPickerInternalUtils().getRecentStickers())
                .map((e) => e.sticker)
                .toList();
        _categorySticker.add(CategorySticker(
          category: "Recents",
          stickers: recents,
        ));
      } else {
        final idx = i - (widget.keyboardConfig.showRecentsTab ? 1 : 0);
        List<Sticker> stickers = [];
        final categoryString = _tabs[idx];

        for (var sticker in widget.stickers) {
          if (sticker.category == categoryString) {
            stickers.addAll(sticker.stickers);
          }
        }

        bool isExist = false;
        for (var categorySticker in _categorySticker) {
          if (categorySticker.category == _tabs[idx]) {
            categorySticker.stickers.addAll(stickers);
            isExist = true;
            break;
          }
        }

        if (isExist) continue;

        _categorySticker.add(CategorySticker(
          category: _tabs[idx],
          stickers: stickers,
        ));
      }
    }

    _loaded = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: widget.keyboardConfig.bgColor,
      child: _loaded
          ? Column(
              children: [
                SizedBox(
                  height: tabBarHeight,
                  child: TabBar(
                    isScrollable: _tabs.length > 4,
                    labelColor: widget.keyboardConfig.iconColorSelected,
                    indicatorColor: widget.keyboardConfig.indicatorColor,
                    unselectedLabelColor: widget.keyboardConfig.iconColor,
                    controller: _tabController,
                    labelPadding: _tabs.length > 4
                        ? const EdgeInsets.symmetric(horizontal: 10)
                        : EdgeInsets.zero,
                    onTap: (index) {
                      _pageController!.jumpToPage(index);
                    },
                    tabs: _tabs
                        .asMap()
                        .entries
                        .map((item) => _buildCategory(item.key, item.value))
                        .toList(),
                  ),
                ),
                Flexible(
                  child: PageView.builder(
                    itemCount: _tabs.length,
                    controller: _pageController,
                    onPageChanged: (index) {
                      _tabController!.animateTo(
                        index,
                        duration:
                            widget.keyboardConfig.tabIndicatorAnimDuration,
                      );
                    },
                    itemBuilder: (context, index) {
                      if (index == 0 && _categorySticker[0].stickers.isEmpty) {
                        return Center(
                          child: widget.keyboardConfig.noRecents,
                        );
                      }

                      return StickerDisplay(
                          stickerModel: _categorySticker[index],
                          keyboardConfig: widget.keyboardConfig,
                          onStickerSelected: widget.onStickerSelected,
                          scrollStream: widget.scrollStream,
                          onUpdateRecent: (recentSticker, refresh) =>
                              updateRecentSticker(
                                recentSticker,
                                refresh: refresh,
                              ));
                    },
                  ),
                ),
              ],
            )
          : const CircularProgressIndicator.adaptive(),
    );
  }
}
