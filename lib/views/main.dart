import 'package:flutter/material.dart';
import 'package:swap/views/categories.dart';

import '../widget/BottomNavBar.dart';
import '../widget/productSection.dart';
import 'categoriespage.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Text(
              'exchy',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Icon(Icons.search, color: Colors.grey),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Önerilen Ürünler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ProductSection(),
              SizedBox(height: 20),
              Text("Kategoriler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CategorySection(),
              SizedBox(height: 20),
              ProductGridSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0,),
    );
  }
}

class CategorySection extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'title': 'Kitap ve Dergi'},
    {'title': 'Elektronik'},
    {'title': 'Kıyafet'},
    {'title': 'Daha Fazla Kategori'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryCard(categories[index]);
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Map<String, String> category;

  CategoryCard(this.category);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if(category['title'] == 'Daha Fazla Kategori')
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryPage(),
            ),
          );
        }
        else
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductListPage(
                baslangicKategorisi: category['title'],
              ),
            ),
          );
        }

      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            category['title']!,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}



