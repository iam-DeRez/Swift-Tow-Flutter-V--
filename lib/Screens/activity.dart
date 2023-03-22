import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:swifttow/modules/colors.dart';

import 'navDrawer.dart';
import 'notification.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  static const routeName = '/activity';
  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),

        //endIcon
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Notifications(),
                  ),
                );
              },
              icon: const Icon(
                Ionicons.notifications_outline,
              ))
        ],
      ),
      extendBodyBehindAppBar: true,

      //Side drawer
      drawer: const NavDrawer(),

      //body
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Activities',
                  style: TextStyle(
                      fontSize: 25,
                      color: text,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/empty.png',
                        scale: 3.1,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        "Oops! No recent tows",
                        style: TextStyle(
                            fontSize: 16,
                            color: text,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3),
                      )
                    ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
