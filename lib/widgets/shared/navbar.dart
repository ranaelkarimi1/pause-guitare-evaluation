import 'dart:developer';

import 'package:pauseguitare/screens/user_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pauseguitare/theme/app_colors.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  // propriétés
  final bool isHome;

  // constructeur
  const Navbar({super.key, this.isHome = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isHome
          ? null
          : SvgPicture.asset("assets/images/logo_navbar.svg", width: 100),
      centerTitle: true,
      backgroundColor: isHome ? Colors.transparent : AppColors.tertiary,
      actions: [
        Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserScreen()),
              );
            },
            icon: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}
