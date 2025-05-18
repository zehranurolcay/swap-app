import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widget/recorded_data.dart';
import 'my_products.dart';

class EditProductPage extends StatefulWidget {
  final List<Product> products;
  final int productIndex;

  EditProductPage({required this.products, required this.productIndex});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late Product product;

  String selectedCategory = 'Elektronik';
  String selectedStatus = 'Yeni';

  int? userId;

  @override
  void initState() {
    super.initState();
    product = widget.products[widget.productIndex];
    checkUserId();

    _titleController = TextEditingController(text: product.name);
    _descriptionController = TextEditingController(text: product.description);
    selectedCategory = product.category;
    selectedStatus = product.status;

  }

  Future<void> checkUserId() async {
    String? id = await getUserId();

    setState(() {
      userId = int.parse(id!);
    });

  }

  Future<void> updateItem({
    required BuildContext context,
    required String userId,
    required String productId,
    required String title,
    required String categoryName,
    required String description,
    required String status,
  }) async {
    final queryParams = {
      'user_id': userId,
      'item_id': productId,
      'title': title,
      'category_name': categoryName,
      'description': description,
      'status': status,
    };

    final uri = Uri.http("10.0.2.2", "/api/edit-item", queryParams);

    print(uri.toString());

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message']), backgroundColor: Colors.green),
        );
        Navigator.pop(context,true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("İstek hatası: $e")),
      );
    }
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürünü Düzenle'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ürün Bilgileri",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),

                  // Başlık
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Başlık',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Kategori
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      'Elektronik',
                      'Ev Ürünleri',
                      'Kitap ve Dergi',
                      'Oyuncaklar',
                      'Kıyafet',
                      'Diğer',
                    ].map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCategory = value!),
                  ),
                  SizedBox(height: 16),

                  // Açıklama
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Açıklama',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Durum
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Durum',
                      prefixIcon: Icon(Icons.info),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Yeni', 'Kullanılmış'].map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedStatus = value!),
                  ),
                  SizedBox(height: 24),

                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (userId == null) return;

                        updateItem(
                          context: context,
                          userId: userId.toString(),
                          productId: product.itemId.toString(),
                          title: _titleController.text,
                          categoryName: selectedCategory,
                          description: _descriptionController.text,
                          status: selectedStatus,
                        );
                      },
                      icon: Icon(Icons.save),
                      label: Text('Kaydet'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
