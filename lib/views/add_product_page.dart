import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


import '../widget/recorded_data.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String selectedCategory = 'Elektronik';
  String selectedStatus = 'Yeni';
  String selectedLocation = 'Ankara';
  File? _selectedImage;

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
  }

  final picker = ImagePicker();

  final List<String> categories = ['Elektronik', 'Ev Ürünleri', 'Kitap ve Dergi', 'Oyuncaklar', 'Kıyafet', 'Diğer'];
  final List<String> statuses = ['Yeni', 'Kullanılmış'];
  final List<String> locations = ['Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya', 'Artvin', 'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkâri', 'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir', 'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir', 'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş','Mardin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman', 'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce',];

  Future<void> _pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> addItem({
    required BuildContext context,
    required String userId,
    required String title,
    required String categoryName,
    required String description,
    required String status,
    required String location,
    File? imageFile,
  }) async {
    var uri = Uri.parse("http://10.0.2.2/api/add-item-app");
    var request = http.MultipartRequest("POST", uri);

    request.fields['user_id'] = userId;
    request.fields['title'] = title;
    request.fields['category_name'] = categoryName;
    request.fields['description'] = description;
    request.fields['status'] = status;
    request.fields['location'] = location;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
        ),
      );
    }

    try {
      var response = await request.send();
      print("Response Headers: ${response.headers}");

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        if (response.headers['content-type']!.contains('application/json')) {
          var jsonResponse = json.decode(responseData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonResponse['message']),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          print("Sunucudan JSON gelmedi: $responseData");
          var jsonResponse = json.decode(responseData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonResponse['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print("Hata: ${response.statusCode}");
      }
    } catch (e) {
      print("İstek hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Ekle'),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle("Ürün Görseli"),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : Center(
                  child: Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 24),

            buildSectionTitle("Ürün Başlığı"),
            buildInputField(_titleController, "Ürün başlığını giriniz"),

            SizedBox(height: 20),
            buildSectionTitle("Kategori"),
            buildDropdownField(categories, selectedCategory, (value) {
              setState(() => selectedCategory = value!);
            }),

            SizedBox(height: 20),
            buildSectionTitle("Açıklama"),
            buildInputField(_descriptionController, "Ürünü açıklayın", maxLines: 4),

            SizedBox(height: 20),
            buildSectionTitle("Ürün Durumu"),
            buildDropdownField(statuses, selectedStatus, (value) {
              setState(() => selectedStatus = value!);
            }),

            SizedBox(height: 20),
            buildSectionTitle("Konum"),
            buildDropdownField(locations, selectedLocation, (value) {
              setState(() => selectedLocation = value!);
            }),

            SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  addItem(
                    context: context,
                    userId: userId.toString(),
                    title: _titleController.text,
                    categoryName: selectedCategory,
                    description: _descriptionController.text,
                    status: selectedStatus,
                    location: selectedLocation,
                    imageFile: _selectedImage,
                  );
                },
                icon: Icon(Icons.add),
                label: Text("Ürünü Ekle", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.grey[800],
      ),
    );
  }

  Widget buildInputField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget buildDropdownField(
      List<String> items, String selectedItem, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedItem,
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      ))
          .toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
