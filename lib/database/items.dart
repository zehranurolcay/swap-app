import 'dart:convert';
import 'package:http/http.dart' as http;

import '../views/my_products.dart';

Future<List<Item>> fetchUserItems(String user_id) async {
  final response = await http.get(Uri.parse('http://10.0.2.2/api/items?user_id=$user_id'));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData["success"] == true) {
      List<dynamic> itemsJson = jsonData["items"];
      return itemsJson.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  } else {
    throw Exception('Sunucu hatası: ${response.statusCode}');
  }
}

class Item {
  final int itemId;
  final int userId;
  final String categoryName;
  final String title;
  final String description;
  final String status;
  final String photo;
  final String location;
  final String createdAt;

  Item({
    required this.itemId,
    required this.userId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.status,
    required this.photo,
    required this.location,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['item_id'],
      userId: json['user_id'],
      categoryName: json['category_name'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      photo: json['photo'],
      location: json['location'],
      createdAt: json['created_at'],
    );
  }
}

///BÜTÜN ÜRÜNLER LİSTESİ ///
Future<List<Product>> getUserAllItems(String userId) async {
  List<Item> dataList = await fetchUserItems(userId);
  List<Product> itemList = [];

  for (var data in dataList) {
    itemList.add(Product(
      itemId: data.itemId.toString(),
      name: data.title,
      category: data.categoryName,
      status: data.status,
      imageUrl: 'http://10.0.2.2/img/' + data.photo,
    ));
  }

  return itemList;
}

