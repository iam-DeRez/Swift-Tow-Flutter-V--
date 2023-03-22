import 'package:flutter/material.dart';

class SocialLinksHeader extends StatelessWidget {
  const SocialLinksHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("images/p2.png"), fit: BoxFit.contain),
      ),
    );
  }
}
