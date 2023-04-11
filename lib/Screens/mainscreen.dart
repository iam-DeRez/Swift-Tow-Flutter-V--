import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swifttow/Screens/Maps.dart';

import 'package:swifttow/Screens/notification.dart';

import '../modules/colors.dart';
import 'navDrawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

List<Assistance> assistance = [
  Assistance(icon: 'images/tow.png', name: "Tow"),
  Assistance(icon: 'images/tyree.png', name: "Tyre Repair"),
  Assistance(icon: 'images/gas.png', name: "Fill Gas"),
];

class _MainScreenState extends State<MainScreen> {
  //user information
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    String username = user.displayName!.split(" ")[0];
    if (user.displayName == null) {
      username == "";
    }

    return Scaffold(
      //topbar
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
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
      body: ListView(padding: EdgeInsets.zero, children: [
        //container for holding the top part
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(color: primary),
          child: SafeArea(
            child: Row(
              children: [
                //Greeting + Subtext + Button
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Text
                        Text(
                          "Hi, $username 👋",
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),

                        //SubText
                        const Padding(
                          padding:
                              EdgeInsets.only(right: 30, top: 15, bottom: 35),
                          child: Text(
                            "Tapping on order now button can save you a whole lot of your time!",
                            maxLines: 4,
                            style: TextStyle(
                                fontSize: 14,
                                color: border,
                                height: 1.4,
                                letterSpacing: 0.1),
                          ),
                        ),

                        //button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MapScreen()));
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            shadowColor:
                                MaterialStateProperty.all(Colors.transparent),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            minimumSize:
                                MaterialStateProperty.all(const Size(50, 45)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Order now",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      "images/truck.png",
                      scale: 3,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(
          height: 32,
        ),

        //available assistance header
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            "Available Assistance",
            style: TextStyle(
                fontSize: 18,
                color: text,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
        ),
        const SizedBox(
          height: 22,
        ),

        //available assistance
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(assistance.length, (index) {
                return Container(
                  decoration: const BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  width: 112,
                  height: 114,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        assistance[index].icon,
                        scale: 2.9,
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Text(
                        assistance[index].name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                );
              })),
        ),

        const SizedBox(
          height: 42,
        ),

        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 190,
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: const BorderRadius.all(Radius.circular(7)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Need some tips?",
                    style: TextStyle(
                        fontSize: 14,
                        color: text,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "These tips will assist you when your vehicle breaks down in the middle of the road!",
                    style: TextStyle(color: subtext, fontSize: 14),
                  ),
                  const SizedBox(
                    height: 26,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      shadowColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xffE7ECFF)),
                      minimumSize:
                          MaterialStateProperty.all(const Size(50, 45)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "See tips",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 26,
        ),
      ]),
    );
  }
}

class Assistance {
  final String icon;
  final String name;

  Assistance({
    required this.icon,
    required this.name,
  });
}
