import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../Screens/signup.dart';
import 'colors.dart';

class ToSignupPage extends StatefulWidget {
  const ToSignupPage({super.key});

  @override
  State<ToSignupPage> createState() => _ToSignupPageState();
}

class _ToSignupPageState extends State<ToSignupPage> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const SignUp()));
        },
        style: TextButton.styleFrom(foregroundColor: text),
        child: const Text("Don't have an account ? Create Account"));
  }
}
