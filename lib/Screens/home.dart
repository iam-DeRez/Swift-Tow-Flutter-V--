import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:swifttow/Screens/activity.dart';
import 'package:swifttow/Screens/navDrawer.dart';
import 'package:swifttow/Screens/profile.dart';
import 'package:swifttow/modules/colors.dart';
import 'package:swifttow/Screens/mainscreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  final screens = [
    const MainScreen(),
    const Activity(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],

      //bottom Nav
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
          height: 95,
          labelTextStyle: MaterialStatePropertyAll(TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
          backgroundColor: nav,
          indicatorColor: primary,
        ),
        child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                  selectedIcon: Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  icon: Icon(
                    Icons.home,
                    color: subtext,
                  ),
                  label: "Home"),
              NavigationDestination(
                  selectedIcon: Icon(
                    Icons.receipt,
                    color: Colors.white,
                  ),
                  icon: Icon(
                    Icons.receipt,
                    color: subtext,
                  ),
                  label: "Activity"),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                icon: Icon(
                  Icons.person,
                  color: subtext,
                ),
                label: "Profile",
              ),
            ]),
      ),
    );
  }
}
