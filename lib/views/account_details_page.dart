import 'package:flutter/material.dart';
import 'package:swap/database/user-details.dart';

import '../database/changepassword.dart';
import '../widget/recorded_data.dart';

class AccountDetailsPage extends StatefulWidget {
  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  late String name;
  late String email;
  bool isLoading = true;
  String? userId;

  void initState() {
    super.initState();
    checkUserId();
  }

  Future<void> checkUserId() async {
    String? id = await getUserId();

    if (id == "") {
      Navigator.pushReplacementNamed(context, '/login');
    }
    else
    {
      setState(() {
        userId = id;
        get_userInfo(userId!);
      });
    }
  }

  Future<void> get_userInfo(String userId) async {
    List<Map<String, String>> itemList = await getUserInformation(userId);

    for (var data in itemList) {
      setState(() {
        name = data['name']!;
        email = data['email']!;
        isLoading = false;
      });
    }
  }

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    String current = _currentPasswordController.text;
    String newPass = _newPasswordController.text;
    String confirm = _confirmPasswordController.text;

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Yeni şifreler eşleşmiyor."),
          backgroundColor: Colors.red,),

      );
      return;
    }

    bool result = await changePassword(userId!, current, newPass);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Şifreniz Başarıyla Değiştirildi."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mevcut Şifre Eşleşme Hatası."),
          backgroundColor: Colors.red,
        ),
      );
    }

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Hesap Detayları"),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ad Soyad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text(name, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 16),
                      Text("E-posta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text(email, style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text("Şifre Değiştir", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            buildPasswordField("Mevcut Şifre", _currentPasswordController),
            buildPasswordField("Yeni Şifre", _newPasswordController),
            buildPasswordField("Yeni Şifre (Tekrar)", _confirmPasswordController),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _changePassword,
                icon: Icon(Icons.lock_reset),
                label: Text("Şifreyi Güncelle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}
