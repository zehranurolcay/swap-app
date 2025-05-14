import 'dart:convert';

import 'package:flutter/material.dart';

import '../database/items.dart';
import '../database/offers.dart';
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
  int? selectedProductId;

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

  void _showPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder(
          future: Future.wait([
            fetchUserItems(userId.toString()),
            fetchOffers(),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('Hata: ${snapshot.error}'),
              );
            }

            List<Item> allUserItems = snapshot.data![0];
            List<Offer> allOffers = snapshot.data![1];

            Set<int> kullanilmisItemIds = {};

            for (var offer in allOffers) {
              if (offer.status.toLowerCase().trim() == "kabul edildi") {
                kullanilmisItemIds.add(offer.itemId); // teklif edilen ürün
                kullanilmisItemIds.add(offer.offered_item_id); // teklif eden ürün
              }
            }

            List<Item> filteredItems = allUserItems
                .where((item) => !kullanilmisItemIds.contains(item.itemId))
                .toList();

            if (filteredItems.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("Takas yapılabilir ürün bulunamadı."),
              );
            }

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Takas Yapacağın Ürünü Seç",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const SizedBox(height: 16),
                      ...filteredItems.map((item) {
                        return RadioListTile<int>(
                          title: Text(item.title),
                          value: item.itemId,
                          groupValue: selectedProductId,
                          activeColor: Colors.orange,
                          onChanged: (value) {
                            setModalState(() {
                              selectedProductId = value;
                            });
                          },
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.pink),
                        ),
                        onPressed: () async {
                          if (selectedProductId != null) {
                            try {
                              final response = await http.get(
                                Uri.parse(
                                  'http://10.0.2.2/api/add-offer?'
                                      'offered_item_id=$selectedProductId'
                                      '&user_id=${userId.toString()}'
                                      '&item_id=${widget.product['itemId']}', // veya showPopup parametresiyle gelen ürün ID
                                ),
                              );

                              if (response.statusCode == 200) {
                                // Başarılı teklif
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Teklif gönderildi')),
                                );
                                Navigator.pop(context); // popup kapat
                                setState(() {}); // sayfayı güncelle
                              } else {
                                throw Exception('Sunucu hatası: ${response.statusCode}');
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Hata oluştu: $e')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(content: Text('Lütfen bir ürün seçin')),
                            );
                          }
                        },
                        child: const Text("Teklif Ver"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
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
                  if (userId == "") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Takas teklifi vermek için giriş yapmanız gerekiyor."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    _showPopup();
                  }
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


