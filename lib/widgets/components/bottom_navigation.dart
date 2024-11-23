import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:sprout/pages/chatbot/chatbot_bud.dart';
import 'package:sprout/pages/home_page.dart';
import 'package:sprout/pages/profile/user_profile.dart';
import 'package:sprout/pages/sensors/soil_moisture.dart';
import 'package:sprout/pages/shop/shop_collections.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  const AppBottomNavigationBar({super.key, required this.selectedIndex});

  @override
  _AppBottomNavigationBarState createState() =>
      _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = widget.selectedIndex;
  }

  void _onItemTapped(int selectedIndex) {
    setState(() {
      index = selectedIndex;
    });
    _navigateToPage(index);
  }

  void _navigateToPage(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const SoilMoisturePage();
        break;
      case 1:
        page = const ShopCollections();
        break;
      case 2:
        page = const SproutHome(); 
        break;
      case 3:
        page = const BudChatbot();
        break;
      case 4:
        page = const UserProfile();
        break;
      default:
        page = const SproutHome();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: index,
      height: 70,
      backgroundColor: Colors.transparent,
      color: Colors.green,
      animationDuration: const Duration(milliseconds: 600), // Add animation duration here
      items: <Widget>[
        Image.asset('assets/icons/icon_health-identifier.png', width: 30, height: 30,),
        Image.asset('assets/icons/icon_plant_shops.png', width: 30, height: 30,),
        Image.asset('assets/icons/icon_sprout_leaf (1).png', width: 30, height: 30,),
        Image.asset('assets/icons/icon_chat.png', width: 30, height: 30,),
        Image.asset('assets/icons/icon_user_profile.png', width: 30, height: 30,),
      ],
      onTap: _onItemTapped,
    );
  }
}
