import 'dart:convert';

import 'package:flutter/material.dart';

import '../database/items.dart';
import '../widget/recorded_data.dart';
import 'package:http/http.dart' as http;

import 'edit_product_page.dart';

class MyProductsPage extends StatefulWidget {

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  bool isLoading = true;
  final List<Product> products = [];

  String? userId;


  void initState() {
    super.initState();
    checkUserId();

  }

  Future<void> checkUserId() async {
      String? id = await getUserId();

      setState(() {
        userId = id;
      });

      get_allItems(userId.toString());
    }

  Future<void> get_allItems(String userId) async {
    List<Product> itemList = await getUserAllItems(userId);
    setState(() {
      products.addAll(itemList);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ürünlerim"),
        backgroundColor: Colors.pink ,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(
            product: products[index],
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductPage(products: products, productIndex: index,),
                ),
              );

              if (result == true) {
                setState(() {
                  isLoading = true;
                  products.clear();
                });
                await get_allItems(userId.toString());
              }
            },
            onDelete: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Sil"),
                  content: Text("${products[index].name} silinsin mi?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("İptal"),
                    ),
                    TextButton(
                      onPressed: () async {
                        String productId = products[index].itemId;
                        Navigator.pop(context);
                        final Uri url = Uri.parse('http://10.0.2.2/api/delete-item?item_id=$productId&user_id=$userId');

                        try {
                          final response = await http.get(url);

                          if (response.statusCode == 200) {
                            final jsonResponse = json.decode(response.body);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(products[index].name + " " + jsonResponse['message']),
                                backgroundColor: Colors.red,
                              ),
                            );

                            if (jsonResponse['success']) {
                              // Listeyi yenile
                              setState(() {
                                products.removeAt(index); // ya da await get_allItems();
                              });
                            }
                          } else {
                            print('Sunucu hatası: ${response.statusCode}');
                          }
                        } catch (e) {
                          print('İstek hatası: $e');
                        }
                      },
                      child: Text("Sil"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Product {
  final String itemId;
  final String name;
  final String category;
  final String status;
  final String description;
  final String imageUrl;

  Product({
    required this.itemId,
    required this.name,
    required this.category,
    required this.status,
    required this.description,
    required this.imageUrl,
  });
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipOval(
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain, // Tüm resim sığar, taşmaz
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Kategori: ${product.category}"),
                    Text("Durum: ${product.status}"),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class ProductDetailPage extends StatelessWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${product.name} Detay"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.imageUrl, width: 100, height: 100),
            SizedBox(height: 16),
            Text("Ürün Adı: ${product.name}", style: TextStyle(fontSize: 18)),
            Text("Kategori: ${product.category}", style: TextStyle(fontSize: 18)),
            Text("Durum: ${product.status}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
