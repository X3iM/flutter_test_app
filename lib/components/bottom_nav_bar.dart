import 'package:bubbled_navigation_bar/bubbled_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test_app/components/download_screen.dart';
import 'package:flutter_test_app/components/geo_search_screen.dart';

class BottomNavBar extends StatefulWidget {
  final titles = ["Search geo", "Download archive"];
  final colors = [Colors.indigoAccent, Colors.teal];
  final icons = [Icons.search, Icons.download_sharp];

  @override
  State createState() => _BottomNavBar();
}

class _BottomNavBar extends State<BottomNavBar> {
  PageController _pageController;
  MenuPositionController _menuPositionController;
  bool _userPageDragging = false;

  List<Widget> _pageList = [GeoSearchScreen(), DownloadScreen()];

  @override
  void initState() {
    _menuPositionController = MenuPositionController(initPosition: 0);

    _pageController =
        PageController(initialPage: 0, keepPage: false, viewportFraction: 1.0);
    _pageController.addListener(handlePageChange);
    super.initState();
  }

  void handlePageChange() {
    _menuPositionController.absolutePosition = _pageController.page;
  }

  bool checkUserDragging(ScrollNotification scrollNotification) {
    if (scrollNotification is UserScrollNotification &&
        scrollNotification.direction != ScrollDirection.idle)
      _userPageDragging = true;
    else if (scrollNotification is ScrollEndNotification)
      _userPageDragging = false;
    if (_userPageDragging)
      _menuPositionController.findNearestTarget(_pageController.page);

    return _userPageDragging;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(title: Text("Test App")),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) => checkUserDragging(notification),
        child: PageView(
          controller: _pageController,
          children: _pageList,
          onPageChanged: (value) {},
        ),
      ),
      bottomNavigationBar: BubbledNavigationBar(
        controller: _menuPositionController,
        initialIndex: 0,
        itemMargin: EdgeInsets.symmetric(horizontal: 8),
        backgroundColor: Colors.white,
        defaultBubbleColor: Colors.blueAccent,
        onTap: (value) {
          _pageController.animateToPage(value,
              curve: Curves.easeInOutQuad,
              duration: Duration(milliseconds: 500));
        },
        items: widget.titles.map((title) {
          var index = widget.titles.indexOf(title);
          var color = widget.colors[index];
          return BubbledNavigationBarItem(
            icon: getIcon(index, color),
            activeIcon: getIcon(index, Colors.white),
            bubbleColor: color,
            title: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }

  Padding getIcon(int index, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Icon(widget.icons[index], size: 30, color: color),
    );
  }
}
