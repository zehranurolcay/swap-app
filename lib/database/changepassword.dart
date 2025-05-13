import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swap/widget/recorded_data.dart';

Future<bool> changePassword(String user_id, String current_password, String new_password) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2/api/change-password?user_id=$user_id&current_password=$current_password&new_password=$new_password'),
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    if (jsonData["success"] == true) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
