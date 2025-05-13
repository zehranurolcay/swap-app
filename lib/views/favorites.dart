import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swap/views/product_details_page.dart';
import 'package:swap/widget/BottomNavBar.dart';

import '../database/all-item-images.dart';
import '../database/all-items.dart';
import '../database/user-details.dart';
import '../widget/recorded_data.dart';
import 'package:http/http.dart' as http;

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
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
    } else {
      setState(() {
        userId = id;
      });

      await get_allItems(userId!);

      setState(() {
        isLoading = false;
      });
    }
  }


  List<Map<String, String>> favoriteProducts = [];

  Future<void> get_allItems(String userId) async {
    List<Map<String, String>> itemList = await getFavoriteItems(userId);
    setState(() {
      favoriteProducts.addAll(itemList);
      isLoading = false;
    });
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
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
              'Favorilerim',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                ),
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(favoriteProducts[index],userId!);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1,),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, String> product;
  final String user_id;
  ProductCard(this.product, this.user_id);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isLoading = true;
  late String userName;

  void initState() {
    super.initState();
  }

  void didChangeDependencies()
  {
    super.didChangeDependencies();
    get_allItemImages();
    sellerName(widget.product['userId']!);
  }

  List<Map<String, String>> product_images = [];

  Future<void> get_allItemImages() async {
    List<Map<String, String>> itemList = await getAllItemImages();
    setState(() {
      product_images.addAll(itemList);
      isLoading = false;
    });
  }

  Future<void> sellerName(String userId) async {
    String name = await getUserName(userId);

    setState(() {
      userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              product: {
                'itemId': widget.product['itemId'],
                'title': widget.product['name'],
                'category': widget.product['category'],
                'description': widget.product['description'],
                'seller': userName,
                'condition': widget.product['status'],
                'location': widget.product['location'],
                'uploadDate': widget.product['createdAt'],
                'wishlist' : widget.product['wishlist'],
                'images': [
                  widget.product['image'].toString(),
                  ...[
                    for (var data in product_images)
                      if (data['itemId'] == widget.product['itemId'])
                        data['imageUrl'].toString(),

                  ],
                ],
              },
            ),
          ),
        );

      },
      child: Container(
        width: 150,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.shade300)],
        ),
        child: Stack(
          children: [
            Center( // Tüm içerik ortalanıyor
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      widget.product['image']!,
                      height: 100,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      widget.product['category']!,
                      style: TextStyle(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      widget.product['name']!,
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  var uri = Uri.parse("http://10.0.2.2/api/wishlist?user_id=${widget.user_id}&item_id=${widget.product['itemId']}");
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
                            content: Text(widget.product['name']! +" "+ jsonResponse['message']),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        print("Sunucudan JSON gelmedi: $responseData");
                      }
                    } else {
                      print("Hata: ${response.statusCode}");
                    }
                  } catch (e) {
                    print("İstek hatası: $e");
                  }


                  setState(() {
                    if (widget.product['wishlist'] == 'added') {
                      widget.product['wishlist'] = 'removed';
                    } else {
                      widget.product['wishlist'] = 'added';
                    }
                  });
                },
                child: Icon(
                  widget.product['wishlist'] == 'added'
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.product['wishlist'] == 'added'
                      ? Colors.red
                      : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

