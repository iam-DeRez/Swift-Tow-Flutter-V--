import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swifttow/modules/colors.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    Key? key,
    required this.location,
    required this.secondary,
    required this.press,
  }) : super(key: key);

  final String location;
  final String secondary;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: ListTile(
            leading: SvgPicture.asset("images/locationIcon.svg"),
            onTap: press,
            horizontalTitleGap: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 14),
              child: Text(
                location,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 14),
              child: Text(
                secondary,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: subtext),
              ),
            ),
          ),
        ),
        const Divider(
          height: 2,
          thickness: 1,
          color: outline,
        )
      ],
    );
  }
}
