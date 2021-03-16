import 'package:zapytaj/screens/tabs/Categories.dart';
import 'package:zapytaj/screens/tabs/Favorite.dart';
import 'package:zapytaj/screens/tabs/Settings.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'tabs/HomeScreen.dart';

class TabsScreen extends StatefulWidget {
  static String routeName = "/tabs_screen";

  static void setPageIndex(BuildContext context, int index) {
    _TabsScreenState state =
        context.findAncestorStateOfType<_TabsScreenState>();
    state._selectPage(index);
  }

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      {'page': HomeScreen()},
      {'page': CategoriesScreen()},
      {'page': FavoriteScreen()},
      {'page': SettingsScreen()},
    ];
    return Scaffold(
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  _body(BuildContext context) {
    return Stack(
      children: <Widget>[
        _pages[_selectedPageIndex]['page'],
      ],
    );
  }

  _bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      onTap: _selectPage,
      elevation: 5,
      iconSize: SizeConfig.blockSizeHorizontal * 5.5,
      backgroundColor: Colors.white,
      currentIndex: _selectedPageIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: SizeConfig.safeBlockHorizontal * 3.4,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: SizeConfig.safeBlockHorizontal * 3.4,
      ),
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.home_16_regular),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.home_16_regular),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.grid_20_regular),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.grid_20_regular),
          ),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.bookmark_16_regular),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.bookmark_16_regular),
          ),
          label: 'Favorite',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.settings_16_regular),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.settings_16_regular),
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}
