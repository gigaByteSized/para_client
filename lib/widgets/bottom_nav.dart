import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// ignore: must_be_immutable
class MyBottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;
  // final bool visible;
  int selectedIndex;
  MyBottomNavBar(
      {super.key,
      required this.onTabChange,
      // required this.visible,
      this.selectedIndex = 0});

  manualTabChange(int value) {
    onTabChange!(value);
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return SafeArea(
      child: GNav(
          selectedIndex: selectedIndex,
          tabMargin:
              // !visible
              //     ? const EdgeInsets.fromLTRB(8, 32, 8, 16)
              //     :
              const EdgeInsets.fromLTRB(8, 24, 8, 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          mainAxisAlignment: MainAxisAlignment.center,
          color: Theme.of(context).primaryColor,
          activeColor: Colors.white,
          tabBackgroundColor: Theme.of(context).primaryColor,
          // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          curve: Curves.easeInOutExpo,
          tabBorderRadius: 30,
          haptic: true,
          gap: 8,
          onTabChange: (value) => onTabChange!(value),
          tabs:
              // visible      ?
              const [
            GButton(
              icon: CupertinoIcons.home,
              text: "Home",
            ),
            GButton(
              icon: CupertinoIcons.location_fill,
              // text: "Map",
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            ),
            GButton(
              icon: CupertinoIcons.add_circled,
              text: "Add alert",
            )
          ]
          // : const [
          //     GButton(
          //       icon: CupertinoIcons.home,
          //       text: "Home",
          //     ),
          //     GButton(
          //       icon: CupertinoIcons.add_circled,
          //       text: "Add alert",
          //     )
          //   ]),
          ),
    );
  }
}
