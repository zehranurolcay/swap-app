import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swap/database/favorites.dart';

import '../widget/recorded_data.dart';
import 'offers.dart';

Future<List<Item>> fetchItems() async {
  final response = await http.get(Uri.parse('http://10.0.2.2/api/all-items'));

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
Future<List<Map<String, String>>> getAllItems() async {
  List<Item> dataList = await fetchItems();
  List<Offer> offerList = await fetchOffers();
  List<Map<String, String>> itemList = [];

  Set<String> acceptedItemIds = {};
  for (var offer in offerList) {
    if (offer.status.toLowerCase().trim() == "kabul edildi") {
      acceptedItemIds.add(offer.itemId.toString());
      acceptedItemIds.add(offer.offered_item_id.toString());
    }
  }

  for (var data in dataList) {
    // Eğer ürün kabul edilmişler listesinde varsa, atla
    if (acceptedItemIds.contains(data.itemId.toString())) {
      continue;
    }

    String wishlist_status = "removed";
    String? id = await getUserId();
    var uri = Uri.parse("http://10.0.2.2/api/wishlist-status?user_id=${id}&item_id=${data.itemId}");
    var request = http.Request("GET", uri);

    var response = await request.send();
    print("Response Headers: ${response.headers}");

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      if (response.headers['content-type']!.contains('application/json')) {
        var jsonResponse = json.decode(responseData);
        wishlist_status = jsonResponse['action'];
      }
    }

    itemList.add({
      'itemId': data.itemId.toString(),
      'userId': data.userId.toString(),
      'image': 'http://10.0.2.2/img/' + data.photo,
      'name': data.title,
      'category': data.categoryName,
      'description': data.description,
      'status': data.status,
      'location': data.location,
      'createdAt': data.createdAt,
      'wishlist': wishlist_status,
    });
  }

  return itemList;
}


///FAVORİLER LİSTESİ ///
Future<List<Map<String, String>>> getFavoriteItems(String userId) async {
  List<Item> dataList = await fetchItems();
  List<Offer> offerList = await fetchOffers();
  List<Map<String, String>> itemList = [];

  List<Favorites> favoriteList = await fetchFavorites(userId);

  Set<String> acceptedItemIds = {};
  for (var offer in offerList) {
    if (offer.status.toLowerCase().trim() == "kabul edildi") {
      acceptedItemIds.add(offer.itemId.toString());
      acceptedItemIds.add(offer.offered_item_id.toString());
    }
  }

  for (var favoriteData in favoriteList) {
    for (var data in dataList) {

      if (acceptedItemIds.contains(data.itemId.toString())) {
        continue;
      }

      String wishlist_status = "removed";

      String? id = await getUserId();

      var uri = Uri.parse("http://10.0.2.2/api/wishlist-status?user_id=${id}&item_id=${data.itemId}");
      var request = http.Request("GET", uri);

      var response = await request.send();
      print("Response Headers: ${response.headers}");

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        if (response.headers['content-type']!.contains('application/json')) {
          var jsonResponse = json.decode(responseData);
          wishlist_status = jsonResponse['action'];
        }
      }

      if(favoriteData.item_id == data.itemId)
        {
          itemList.add({
            'itemId': data.itemId.toString(),
            'userId': data.userId.toString(),
            'image': 'http://10.0.2.2/img/' + data.photo,
            'name': data.title,
            'category': data.categoryName,
            'description': data.description,
            'status': data.status,
            'location': data.location,
            'createdAt': data.createdAt,
            'wishlist' : wishlist_status,
          });
        }
    }
  }

  return itemList;
}