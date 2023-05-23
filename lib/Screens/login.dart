import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swifttow/Screens/home.dart';
import 'package:swifttow/modules/colors.dart';
import 'package:swifttow/modules/button%20to%20signup%20page.dart';
import 'package:swifttow/modules/social%20links%20header.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isObscure = true;

  final formsfield = GlobalKey<FormState>();

  //Firebase Authentication Var
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Controllers
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  //function for Logging In User
  void loginUser() async {
    if (formsfield.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        //instantiate database
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users');
        final user = FirebaseAuth.instance.currentUser!;
        String uid = user.uid;
        DatabaseEvent event = await userRef.child("users/$uid/Name").once();

        await CoolAlert.show(
            context: context,
            type: CoolAlertType.loading,
            autoCloseDuration: const Duration(seconds: 2));

        AnimatedSnackBar.material('Login successful',
                type: AnimatedSnackBarType.success,
                duration: const Duration(seconds: 2),
                mobileSnackBarPosition: MobileSnackBarPosition.bottom,
                desktopSnackBarPosition: DesktopSnackBarPosition.bottomLeft)
            .show(context);

        //when successful
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeftJoined,
                childCurrent: widget,
                alignment: Alignment.bottomCenter,
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 600),
                reverseDuration: const Duration(milliseconds: 600),
                child: const Home()));
      } on FirebaseAuthException catch (e) {
        String error = e.code.toString();

        AnimatedSnackBar.material(error,
                type: AnimatedSnackBarType.error,
                mobileSnackBarPosition: MobileSnackBarPosition.bottom,
                desktopSnackBarPosition: DesktopSnackBarPosition.bottomLeft)
            .show(context);
      }
    }
  }

//google signin
  Future<void> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'openid',
          'https://www.googleapis.com/auth/user.phonenumbers.read'
        ],
      ).signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        UserCredential userCredential =
            await _auth.signInWithCredential(authCredential);
        User? user = userCredential.user;

        await CoolAlert.show(
            context: context,
            type: CoolAlertType.loading,
            autoCloseDuration: const Duration(seconds: 2));
      } else {
        throw Exception(e);
      }

      AnimatedSnackBar.material('Login successful',
              type: AnimatedSnackBarType.success,
              duration: const Duration(seconds: 2),
              mobileSnackBarPosition: MobileSnackBarPosition.bottom,
              desktopSnackBarPosition: DesktopSnackBarPosition.bottomLeft)
          .show(context);

      //when successful
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeftJoined,
              childCurrent: widget,
              alignment: Alignment.bottomCenter,
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 600),
              reverseDuration: const Duration(milliseconds: 600),
              child: const Home()));
    } catch (e) {
      String error = "Not logged In";

      AnimatedSnackBar.material(error,
              type: AnimatedSnackBarType.error,
              mobileSnackBarPosition: MobileSnackBarPosition.bottom,
              desktopSnackBarPosition: DesktopSnackBarPosition.bottomLeft)
          .show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Form(
            key: formsfield,
            child: ListView(
              children: [
                const SizedBox(
                  height: 45,
                ),
                //heading and sub heading
                const Text(
                  "Welcome 👋",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(
                  height: 8,
                ),

                const Text(
                  "Log in into your account and get access to our services",
                  style: TextStyle(color: subtext),
                ),

                const SizedBox(
                  height: 45,
                ),
                // Email Textfield
                const Text(
                  "Email",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),

                const SizedBox(
                  height: 10,
                ),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16),

                  decoration: InputDecoration(
                    focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Color.fromARGB(255, 204, 61, 61),
                    )),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Color.fromARGB(255, 204, 61, 61),
                    )),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primary,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter Email',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 12.0),
                  ),

                  //Validating Email
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your Email address';
                    }
                    if (!RegExp(
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                        .hasMatch(value)) {
                      return 'Enter a Valid Email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(
                  height: 40,
                ),

                //Password Textfield
                const Text(
                  "Password",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),

                const SizedBox(
                  height: 10,
                ),

                TextFormField(
                  controller: passwordController,
                  style: const TextStyle(fontSize: 16),
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Color.fromARGB(255, 179, 54, 54),
                    )),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Color.fromARGB(255, 204, 61, 61),
                    )),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: border,
                      ),
                    ),
                    suffixIcon: IconButton(
                        icon: Icon(_isObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        }),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primary,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter Password',
                    hintStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 12.0),
                  ),

                  //validating password
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Password';
                    }

                    if (value.length < 8) {
                      return 'Must be more than 8 charater';
                    }
                    return null;
                  },
                ),

                const SizedBox(
                  height: 10,
                ),

                //Forget password
                Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        )
                      ]),
                ),

                const SizedBox(
                  height: 45,
                ),

                //Login button
                ElevatedButton(
                  onPressed: () {
                    loginUser();
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(300, 52)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                ),

                const SizedBox(
                  height: 45,
                ),

                //Social Links header
                const SocialLinksHeader(),

                const SizedBox(
                  height: 45,
                ),

                //Social Links
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 175,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            googleSignIn();
                          },
                          icon: Image.asset(
                            "images/googleicon.png",
                            scale: 2.1,
                          ),
                          style:
                              OutlinedButton.styleFrom(foregroundColor: text),
                          label: const Text("Google"),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: 175,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Image.asset(
                            "images/facebookicon.png",
                            scale: 2.1,
                          ),
                          style:
                              OutlinedButton.styleFrom(foregroundColor: text),
                          label: const Text("Facebook"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 75,
                ),

                //Registration Button
                const ToSignupPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
