import 'dart:convert';

import 'package:flutter/material.dart';

import '../widget/productDetailsSection.dart';
import '../widget/recorded_data.dart';
import 'package:http/http.dart' as http;

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedImageIndex = 0;
  String? userId;
  bool isLoading = true;

  void initState() {
    super.initState();
    checkUserId();
  }

  Future<void> checkUserId() async {
    String? id = await getUserId();

    setState(() {
      userId = id;
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    List<String> images = widget.product['images'] ?? [];

    String _calculateUploadDate(dynamic uploadDate) {
      if (uploadDate == null || uploadDate.toString().isEmpty) {
        return '';
      }

      try {
        DateTime uploadDateTime = DateTime.parse(uploadDate.toString());
        Duration difference = DateTime.now().difference(uploadDateTime);
        int daysAgo = difference.inDays;

        if (daysAgo == 0) {
          return 'Bugün oluşturuldu.';
        } else if (daysAgo == 1) {
          return '1 gün önce oluşturuldu.';
        } else {
          return '$daysAgo gün önce oluşturuldu.';
        }
      } catch (e) {
        return '';
      }
    }

    String _capitalize(String text) {
      if (text.isEmpty) return '';
      return text[0].toUpperCase() + text.substring(1);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['title']),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              widget.product['wishlist'] == 'added'
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.product['wishlist'] == 'added'
                  ? Colors.orange
                  : Colors.orange,
            ),
            onPressed: () async {
              bool isFavorited = false;
              var uri = Uri.parse("http://10.0.2.2/api/wishlist?user_id=${userId}&item_id=${widget.product['itemId']}");
              var request = http.Request("GET", uri);

              try {
                var response = await request.send();
                print("Response Headers: ${response.headers}");

                if (response.statusCode == 200) {
                  var responseData = await response.stream.bytesToString();
                  if (response.headers['content-type']!.contains('application/json')) {
                    var jsonResponse = json.decode(responseData);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.product['title']! +" "+ jsonResponse['message']),
                        backgroundColor: Colors.red,
                      ),
                    );
                    isFavorited= true;
                  } else {
                    print("Sunucudan JSON gelmedi: $responseData");
                    var jsonResponse = json.decode(responseData);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.product['title']! +" "+ jsonResponse['message']),
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

              print(widget.product['itemId']);
              setState(() {
                if(isFavorited == true)
                {
                  if (widget.product['wishlist'] == 'added') {
                    widget.product['wishlist'] = 'removed';
                  } else {
                    widget.product['wishlist'] = 'added';
                  }
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Büyük ürün görseli
            AspectRatio(
              aspectRatio: 1,
              child: images.isNotEmpty
                  ? Image.network(
                images[selectedImageIndex],
                fit: BoxFit.cover,
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 80),
              ),
            ),
            const SizedBox(height: 10),

            // Küçük resimler galerisi
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedImageIndex == index
                            ? Colors.orange
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Image.network(
                      images[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Ürün İsmi
            Text(
              widget.product['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Kategori
            Text(
              widget.product['category'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Ürün açıklaması
            Text(
              widget.product['description'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Satıcı Bilgileri
            _buildInfoRow('Satıcı:', widget.product['seller'] ?? ''),
            _buildInfoRow('Ürün Durumu:', widget.product['condition'] ?? ''),
            _buildInfoRow('Konum:', _capitalize(widget.product['location'] ?? '')),
            _buildInfoRow('Yükleme Tarihi:', _calculateUploadDate(widget.product['uploadDate'])),

            const SizedBox(height: 20),

            // Takas Teklifi Ver Butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Takas teklifi işlemleri
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Takas teklifi gönderildi!')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.swap_horiz, color: Colors.orange),
                label: const Text(
                  'TAKAS TEKLİFİ VER',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Şunları da Beğenebilirsiniz
            const Text(
              'Şunları da Beğenebilirsiniz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Alt öneri ürünleri (geçici placeholder)
            ProductSection(category: widget.product['category']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}


