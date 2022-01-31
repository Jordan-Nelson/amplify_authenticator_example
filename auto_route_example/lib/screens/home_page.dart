import 'package:auto_route/auto_route.dart';
import 'package:auto_route_example/router/router.gr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class RouteDestination {
  final PageRouteInfo route;
  final IconData icon;
  final String label;

  const RouteDestination({
    required this.route,
    required this.icon,
    required this.label,
  });
}

class HomePageState extends State<HomePage> {
  final destinations = [
    RouteDestination(
      route: BooksTab(),
      icon: Icons.source,
      label: 'Books',
    ),
    RouteDestination(
      route: ProfileTab(),
      icon: Icons.person,
      label: 'Profile',
    ),
    RouteDestination(
      route: SettingsTab(tab: 'default'),
      icon: Icons.settings,
      label: 'Settings',
    ),
  ];

  void toggleSettingsTap() => setState(() {
        _showSettingsTap = !_showSettingsTap;
      });

  bool _showSettingsTap = true;

  @override
  Widget build(context) {
    // builder will rebuild everytime this router's stack
    // updates
    // we need it to indicate which NavigationRailDestination is active
    return AutoTabsScaffold(
      homeIndex: 0,
      appBarBuilder: (context, tabsRouter) {
        return AppBar(
          title: Text(tabsRouter.topRoute.name),
          leading: AutoBackButton(),
        );
      },
      routes: [
        BooksTab(),
        ProfileTab(),
        if (_showSettingsTap) SettingsTab(tab: 'default'),
      ],
      bottomNavigationBuilder: buildBottomNav,
    );
  }

  Widget buildBottomNav(BuildContext context, TabsRouter tabsRouter) {
    final hideBottomNav = tabsRouter.topMatch.meta['hideBottomNavf'] == true;
    return hideBottomNav
        ? SizedBox.shrink()
        : BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.source),
                label: 'Books',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              if (_showSettingsTap)
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
            ],
          );
  }
}
