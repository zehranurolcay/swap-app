import 'package:flutter/material.dart';
import 'package:swap/views/categoriespage.dart';

import '../widget/BottomNavBar.dart';

class CategoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Elektronik', 'icon': Icons.devices},
    {'name': 'Ev Ürünleri', 'icon': Icons.home},
    {'name': 'Kitap ve Dergi', 'icon': Icons.menu_book},
    {'name': 'Oyuncaklar', 'icon': Icons.toys},
    {'name': 'Kıyafet', 'icon': Icons.checkroom},
    {'name': 'Diğer', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Kategoriler',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(categories[index]['name'], style: TextStyle(fontSize: 18)),
              leading: Icon(categories[index]['icon'], color: Colors.blueAccent),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductListPage(
                      baslangicKategorisi: categories[index]['name'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2,),
    );
  }
}