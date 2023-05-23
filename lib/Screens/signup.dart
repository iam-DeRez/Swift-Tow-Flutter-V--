import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swifttow/Screens/home.dart';
import 'package:swifttow/modules/colors.dart';
import 'package:swifttow/modules/social%20links%20header.dart';
import '../modules/to login page.dart';
import 'profile.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  bool _isObscure = true;

  final formsfield = GlobalKey<FormState>();

  //Firebase Authentication Var
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Controllers
  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();

//function for Registering Users using Email and Password
  void registerUser() async {
    if (formsfield.currentState!.validate()) {
      // take action what you want
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        //instantiate database
        DatabaseReference newUserRef =
            FirebaseDatabase.instance.ref().child('users');

        String uid = userCredential.user!.uid;
        // Retrieve user data

//push user details to database
        await newUserRef.child(uid).set({
          'Email': emailController.text,
          'Name': nameController.text,
          'Phone': phoneController.text,
        });

        await CoolAlert.show(
            context: context,
            type: CoolAlertType.loading,
            autoCloseDuration: const Duration(seconds: 2));

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
            child: const Home(),
          ),
        );

        AnimatedSnackBar.material('Signup successful',
                type: AnimatedSnackBarType.success,
                duration: const Duration(seconds: 2),
                mobileSnackBarPosition: MobileSnackBarPosition.bottom,
                desktopSnackBarPosition: DesktopSnackBarPosition.bottomLeft)
            .show(context);
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

//function for registering users using socials
  Future<void> googleSignUp() async {
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

        if (user != null) {
          // Instantiate users database reference
          DatabaseReference newUserRef =
              FirebaseDatabase.instance.ref().child('users');

          String uid = user.uid;
          String name = user.displayName ?? '';
          String email = user.email ?? '';
          String phoneNumber = user.phoneNumber ?? '';

          // Push user details to the database
          await newUserRef.child(uid).set({
            'Id': uid,
            'Email': email,
            'Name': name,
            'Phone': phoneNumber,
          });

          await CoolAlert.show(
            context: context,
            type: CoolAlertType.loading,
            autoCloseDuration: const Duration(seconds: 2),
          );

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
        } else {
          throw Exception('User is null');
        }
      } else {
        throw Exception('Google sign-in account is null');
      }
    } catch (e) {
      String error = 'Error signing in with Google: $e';

      AnimatedSnackBar.material(error,
              type: AnimatedSnackBarType.error,
              mobileSnackBarPosition: MobileSnackBarPosition.bottom,
              desktopSnackBarPosition: DesktopSnackBarPosition.bottomLeft)
          .show(context);
      // Handle the error as per your requirement

      AnimatedSnackBar.material('Login successful',
              type: AnimatedSnackBarType.success,
              duration: const Duration(seconds: 2),
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
                  "Create Account! 😁",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(
                  height: 8,
                ),

                const Text(
                  "We can see you are new here! Register and enjoy our services with ease.",
                  style: TextStyle(color: subtext, height: 1.25),
                ),

                const SizedBox(
                  height: 35,
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
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primary),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
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
                  height: 35,
                ),

                //Name Textfield
                const Text(
                  "Name",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),

                const SizedBox(
                  height: 10,
                ),

                TextFormField(
                  controller: nameController,
                  style: const TextStyle(fontSize: 16),
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
                    hintText: 'Eg. Batman Awuni',
                    hintStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 12.0),
                  ),

                  //validating Email
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Name';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 35,
                ),

                //Phone Textfield
                const Text(
                  "Phone",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),

                const SizedBox(
                  height: 10,
                ),

                TextFormField(
                  controller: phoneController,
                  style: const TextStyle(fontSize: 16),
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
                    hintText: 'Enter Phone Number',
                    hintStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 12.0),
                  ),

                  //validating Email
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Phone Number';
                    }

                    if (value.length < 10) {
                      return 'Should be up to 10 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(
                  height: 35,
                ),

                // Password Textfield
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
                  height: 55,
                ),

                //Login button
                ElevatedButton(
                  onPressed: () {
                    registerUser();
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
                    "Create account",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(
                  height: 45,
                ),
                const SocialLinksHeader(),

                const SizedBox(
                  height: 45,
                ),
                //social Sign up
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 175,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            googleSignUp();
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
                  height: 110,
                ),

                //Registration Button
                const ToLoginPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
