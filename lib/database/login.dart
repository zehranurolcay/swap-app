import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swap/widget/recorded_data.dart';

Future<bool> checkLogin(String email, String password) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2/api/login?email=$email&password=$password'),
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    if (jsonData["success"] == true) {
      final userJson = jsonData["user"];
      final String userId = userJson["user_id"].toString();

      saveUserId(userId);

      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
