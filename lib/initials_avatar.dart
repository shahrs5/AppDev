import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.radius = 20});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    String initials = '';
    for (var part in name.split(' ')) {
      if (part.isNotEmpty && initials.length < 2) {
        initials = initials + part[0];
      }
    }
    return CircleAvatar(radius: radius, child: Text(initials));
  }
}
