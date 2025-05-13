import 'package:flutter/material.dart';
import 'package:swap/widget/recorded_data.dart';

import '../database/user-details.dart';
import '../widget/BottomNavBar.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  late String userName;
  String? userId;

  @override
  void initState() {
    super.initState();
    checkUserId();
  }

  Future<void> checkUserId() async {
    String? id = await getUserId();

    if (id == "") {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        userId = id;
      });

      getName(userId!);
    }
  }

  Future<void> getName(String userId) async {
    String name = await getUserName(userId);

    setState(() {
      userName = name;
      isLoading = false;
    });
  }

  String getInitials(String name) {
    List<String> parts = name.trim().split(" ");
    String initials = "";

    for (var part in parts) {
      if (part.isNotEmpty) {
        initials += part[0].toUpperCase();
      }
    }

    return initials;
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Hesabım",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.orange,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(getInitials(userName),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Text(
            userName,
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                children: [
                  _buildMenuItem(context, Icons.person, "Hesap Detayları", "/accountDetails"),
                  _buildMenuItem(context, Icons.add, "Ürün Ekle", "/addProduct"),
                  _buildMenuItem(context, Icons.shopping_cart, "Ürünlerim", "/myProducts"),
                  ListTile(
                    leading: Icon(Icons.message, color: Colors.pink),
                    title: Text("Mesajlar", style: TextStyle(fontSize: 16)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/messages",
                            (route) => true,
                        arguments: int.parse(userId!),
                      );
                    },
                  ),
                  _buildMenuItem(context, Icons.swap_horiz, "Takas Tekliflerim", "/swapOffers"),
                  _buildMenuItem(context, Icons.swap_horiz, "Gelen Teklifler", "/swapOffers-1"),
                  _buildMenuItem(context, Icons.history, "Takas Geçmişi", "/swapHistory"),
                  ListTile(
                    leading: Icon(Icons.exit_to_app, color: Colors.pink),
                    title: Text("Çıkış Yap", style: TextStyle(fontSize: 16)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(context, "/logout", (route) => false);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}
