import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Favorites>> fetchFavorites(String userId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2/api/wishlist-list?user_id='+userId));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData["success"] == true) {
      List<dynamic> itemsJson = jsonData["wishlist"];
      return itemsJson.map((json) => Favorites.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  } else {
    throw Exception('Sunucu hatası: ${response.statusCode}');
  }
}

class Favorites {
  final int id;
  final int user_id;
  final int item_id;
  final String createdAt;

  Favorites({
    required this.id,
    required this.user_id,
    required this.item_id,
    required this.createdAt,
  });

  factory Favorites.fromJson(Map<String, dynamic> json) {
    return Favorites(
      id: json['id'],
      user_id: json['user_id'],
      item_id: json['item_id'],
      createdAt: json['created_at'],
    );
  }
}

///FAVORİLER LİSTESİ ///
Future<List<Map<String, String>>> getFavoriteList(String userId) async {
  List<Favorites> dataList = await fetchFavorites(userId);
  List<Map<String, String>> favoriteList = [];

  for (var data in dataList) {
    favoriteList.add({
      'id' : data.id.toString(),
      'user_id' : data.user_id.toString(),
      'item_id': data.item_id.toString(),
      'createdAt' : data.createdAt
    });
  }

  return favoriteList;
}

