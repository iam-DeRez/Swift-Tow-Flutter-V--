import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text("Drawer"),
                ]),
          ),
        ),
      ),
    );
  }
}
