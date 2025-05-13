import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widget/messagedetailspage.dart';

class UserListPage extends StatefulWidget {
  final int loggedUserId;

  UserListPage({required this.loggedUserId});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2/api/users?sender=${widget.loggedUserId}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        users = List<Map<String, dynamic>>.from(data)
            .where((u) => u['user_id'] != widget.loggedUserId)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Kullanıcılar'),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 4.0), // Kenarlardan daraltmak için padding
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Daha yuvarlak köşeler
              ),
              color: Colors.orange,
              elevation: 4, // Hafif gölge efekti
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // ListTile içi de uyumlu olur
                ),
                title: Text(
                  user['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios, // Sağda ok ikonu
                  color: Colors.white,
                  size: 18,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagesPage(
                        loggedUserId: widget.loggedUserId,
                        selectedUserId: user['user_id'],
                        selectedUserName: user['name'],
                      ),
                    ),
                  );
                },
              ),
            ),
          );

        },
      ),
    );
  }
}
