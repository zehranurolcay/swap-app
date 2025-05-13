import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Item_Image>> fetchItems() async {
  final response = await http.get(Uri.parse('http://10.0.2.2/api/item-img'));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData["success"] == true) {
      List<dynamic> itemsJson = jsonData["item_images"];
      return itemsJson.map((json) => Item_Image.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  } else {
    throw Exception('Sunucu hatası: ${response.statusCode}');
  }
}

class Item_Image {
  final int imageId;
  final int itemId;
  final String imageUrl;
  final String createdAt;

  Item_Image({
    required this.imageId,
    required this.itemId,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Item_Image.fromJson(Map<String, dynamic> json) {
    return Item_Image(
      imageId: json['image_id'],
      itemId: json['item_id'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }
}

///BÜTÜN ÜRÜNLER LİSTESİ ///
Future<List<Map<String, String>>> getAllItemImages() async {
  List<Item_Image> dataList = await fetchItems();
  List<Map<String, String>> itemList = [];

  for (var data in dataList) {
    itemList.add({
      'imageId' : data.imageId.toString(),
      'itemId' : data.itemId.toString(),
      'imageUrl': 'http://10.0.2.2/img/product_img/'+data.imageUrl,
      'createdAt' : data.createdAt
    });
  }

  return itemList;
}