import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swifttow/Screens/login.dart';
import 'colors.dart';

class ToLoginPage extends StatefulWidget {
  const ToLoginPage({super.key});

  @override
  State<ToLoginPage> createState() => _ToLoginPageState();
}

class _ToLoginPageState extends State<ToLoginPage> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Login()));
        },
        style: TextButton.styleFrom(foregroundColor: text),
        child: const Text("Already having an account ? Create Account"));
  }
}
