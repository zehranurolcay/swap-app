import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<User>> fetchUsers(String userId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2/api/seller-name?user_id='+userId));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData["success"] == true) {
      List<dynamic> itemsJson = jsonData["user"];
      return itemsJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  } else {
    throw Exception('Sunucu hatası: ${response.statusCode}');
  }
}

class User {
  final int userId;
  final String name;
  final String email;
  final String createdAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['created_at'],
    );
  }
}

///KULLANICI BİLGİSİ ///
Future<List<Map<String, String>>> getUserInformation(String userId) async {
  List<User> dataList = await fetchUsers(userId);
  List<Map<String, String>> userList = [];

  for (var data in dataList) {
    userList.add({
      'userId' : data.userId.toString(),
      'name' : data.name,
      'email': data.email,
      'createdAt' : data.createdAt
    });
  }

  return userList;
}

///KULLANICI NAME ///
Future<String> getUserName(String userId) async {
  List<User> dataList = await fetchUsers(userId);

  if (dataList.isNotEmpty) {
    return dataList.first.name;
  } else {
    return '';
  }
}