import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ionicons/ionicons.dart';
import 'package:swifttow/Screens/login.dart';
import 'package:swifttow/modules/colors.dart';

import 'navDrawer.dart';
import 'notification.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  //Firebase Authentication Var
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> LogOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    //user information
  }

  //Logout function
  void logout() async {
    await _auth.signOut();

    AnimatedSnackBar.material('Logout successful',
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 2),
            mobileSnackBarPosition: MobileSnackBarPosition.bottom,
            desktopSnackBarPosition: DesktopSnackBarPosition.bottomLeft)
        .show(context);

    //when successful
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const Login();
    }));
  }

  @override
  Widget build(BuildContext context) {
    String photoUrl = user.photoURL.toString();
    String username = user.displayName!;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 0.55,
            width: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),

                //user profile picture

                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                        color: background,
                        image: DecorationImage(image: NetworkImage(photoUrl))),
                  ),
                ),

                //user name
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Text(
                    username,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),

          //account section
          Container(
            padding:
                const EdgeInsets.only(left: 16, top: 22, bottom: 22, right: 16),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Account",
                  style: TextStyle(
                      fontSize: 18,
                      color: text,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton.icon(
                    onPressed: () {},
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(subtext),
                        textStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 16,
                        ))),
                    icon: const Icon(
                      Icons.person_outline,
                      size: 21,
                    ),
                    label: const Text('  Your Information')),
                TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        foregroundColor: subtext,
                        textStyle: const TextStyle(
                          fontSize: 16,
                        )),
                    icon: const Icon(
                      Icons.credit_card,
                      size: 21,
                    ),
                    label: const Text('  Cards and Mobile Money')),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          //Support section
          Container(
            padding:
                const EdgeInsets.only(left: 16, top: 22, bottom: 22, right: 16),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Support",
                  style: TextStyle(
                      fontSize: 18,
                      color: text,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: subtext,
                      textStyle: const TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 14.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    icon: const Icon(
                      Icons.help_outline,
                      size: 21,
                    ),
                    label: const Text('  Help')),
                TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: subtext,
                      textStyle: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    icon: const Icon(
                      Icons.star_outline,
                      size: 21,
                    ),
                    label: const Text('  Rate the app')),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: subtext,
                        alignment: Alignment.topLeft,
                        textStyle: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      icon: const Icon(
                        Icons.drive_eta_outlined,
                        size: 21,
                      ),
                      label: const Text('  Become a tow driver')),
                ),
              ],
            ),
          ),
          //logout section
          const SizedBox(
            height: 12,
          ),

          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                      onPressed: () {
                        logout();
                        LogOut();
                      },
                      style: TextButton.styleFrom(
                        alignment: Alignment.topLeft,
                        foregroundColor: danger,
                        textStyle: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      icon: const Icon(
                        Icons.logout_outlined,
                        size: 21,
                      ),
                      label: const Text('  Log out')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
