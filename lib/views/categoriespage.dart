import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swap/views/product_details_page.dart';

import '../database/all-item-images.dart';
import '../database/all-items.dart';
import '../database/user-details.dart';
import 'package:http/http.dart' as http;

import '../widget/recorded_data.dart';

class ProductListPage extends StatefulWidget {
  late final String? baslangicKategorisi;
  ProductListPage({this.baslangicKategorisi});
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late String seciliKategori;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    seciliKategori = widget.baslangicKategorisi ?? 'Tümü';
  }

  final List<String> kategoriler = ['Tümü', 'Elektronik', 'Ev Ürünleri', 'Kitap ve Dergi','Oyuncaklar','Kıyafet','Diğer'];

  void didChangeDependencies()
  {
    super.didChangeDependencies();
    get_allItems();
  }

  List<Map<String, String>> tumUrunler = [];

  Future<void> get_allItems() async {
    List<Map<String, String>> itemList = await getAllItems();
    setState(() {
      tumUrunler.addAll(itemList);
      isLoading = false;
    });
  }

  List<Map<String, String>> get filtreliUrunler {
    if (seciliKategori == 'Tümü') return tumUrunler;
    return tumUrunler.where((urun) => urun['category'] == seciliKategori).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(seciliKategori == 'Tümü' ? 'Tüm Ürünler' : seciliKategori + ' Ürünleri'),
        backgroundColor: Colors.pink,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kategoriler.length,
              itemBuilder: (context, index) {
                final kategori = kategoriler[index];
                final aktif = kategori == seciliKategori;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(kategori),
                    selected: aktif,
                    selectedColor: Colors.orange,
                    onSelected: (secildi) {
                      setState(() {
                        seciliKategori = kategori;
                      });
                    },
                    labelStyle: TextStyle(color: aktif ? Colors.white : Colors.black),
                    backgroundColor: Colors.grey.shade200,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: filtreliUrunler.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return ProductCard(filtreliUrunler[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, String> product;

  ProductCard(this.product);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {

  late String userName;
  bool isLoading = true;
  String? userId;

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
    });
  }

  Future<void> sellerName(String userId) async {
    String name = await getUserName(userId);

    setState(() {
      userName = name;
      isLoading = false;
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
                            content: Text(widget.product['name']! +" "+ jsonResponse['message']),
                            backgroundColor: Colors.red,
                          ),
                        );
                        isFavorited= true;
                      } else {
                        print("Sunucudan JSON gelmedi: $responseData");
                        var jsonResponse = json.decode(responseData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.product['name']! +" "+ jsonResponse['message']),
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

