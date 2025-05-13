import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swap/views/account_details_page.dart';
import 'package:swap/views/add_product_page.dart';
import 'package:swap/views/favorites.dart';
import 'package:swap/views/login.dart';
import 'package:swap/views/logout.dart';
import 'package:swap/views/main.dart';
import 'package:swap/views/messagespage.dart';
import 'package:swap/views/my_products.dart';
import 'package:swap/views/register.dart';
import 'package:swap/views/swaphistory.dart';
import 'package:swap/views/swapoffers.dart';
import 'package:swap/views/swapoffers_1.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('userId')) {
    await prefs.setString('userId', '');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/login": (context) => LoginPage(),
        "/home": (context) => HomePage(),
        "/accountDetails": (context) => AccountDetailsPage(),
        "/addProduct": (context) => AddProductPage(),
        "/myProducts": (context) => MyProductsPage(),
        "/messages": (context) {
          final loggedUserId = ModalRoute.of(context)!.settings.arguments as int;
          return UserListPage(loggedUserId: loggedUserId);
        },
        "/swapOffers": (context) => SwapOffersPage(),
        "/swapOffers-1": (context) => SwapOffers_1_Page(),
        "/swapHistory": (context) => SwapHistoryPage(),
        "/logout": (context) => LogoutPage()
      },
      theme: ThemeData(
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

