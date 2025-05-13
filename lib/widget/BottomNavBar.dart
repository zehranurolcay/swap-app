import 'package:flutter/material.dart';
import 'package:swap/views/account.dart';
import 'package:swap/views/categories.dart';

import '../views/favorites.dart';
import '../views/main.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FavoritesPage()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CategoryPage()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Keşfet'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorilerim'),
        BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Kategoriler'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hesabım'),
      ],
    );
  }
}
