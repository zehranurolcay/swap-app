import 'package:flutter/material.dart';

import '../database/offers.dart';
import '../widget/recorded_data.dart';
import 'package:http/http.dart' as http;

class SwapOffersPage extends StatefulWidget {
  @override
  State<SwapOffersPage> createState() => _SwapOffersPageState();
}

class _SwapOffersPageState extends State<SwapOffersPage> {

  bool isLoading = true;
  String? userId;

  List<TakasTeklifleri> teklifler = [];

  void initState() {
    super.initState();
    checkUserId();
  }

  Future<void> checkUserId() async {
    String? id = await getUserId();

    teklifler = await getOffers(id!);
      setState(() {
        userId = id;
        isLoading = false;
      });
    }

  Color _getDurumColor(String durum) {
    switch (durum) {
      case "Kabul Edildi":
        return Colors.green;
      case "Reddedildi":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Takas Tekliflerim"),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: teklifler.length,
        itemBuilder: (context, index) {
          final teklif = teklifler[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRichLine("Benim Ürünüm", teklif.benimUrunum),
                  SizedBox(height: 6),
                  _buildRichLine("Alınacak Ürün", teklif.alinacakUrun),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Durum: ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        teklif.durum,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getDurumColor(teklif.durum),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  _buildRichLine("Tarih", teklif.tarih +" gün önce teklif verildi."),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                        onPressed: () async {
                          bool onaylandi = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Takası iptal etmek istiyor musun?"),
                                content: Text("${teklif.alinacakUrun} takasını iptal etmek üzeresin."),
                                actions: [
                                  TextButton(
                                    child: Text("Vazgeç"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Evet, iptal et"),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (onaylandi == true) {
                            var uri = Uri.parse("http://10.0.2.2/api/offer-status?offer_id=${teklif.offerId}&status=Reddedildi");
                            var request = http.Request("GET", uri);
                            var response = await request.send();

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${teklif.alinacakUrun} takası iptal edildi."),
                                  backgroundColor: Colors.red,
                                ),
                              );

                              List<TakasTeklifleri> yeniListe = await getOffers(userId!);
                              setState(() {
                                teklifler = yeniListe;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("İptal başarısız oldu."),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        },
                      icon: Icon(Icons.cancel),
                      label: Text("Takası İptal Et"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRichLine(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$title: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class TakasTeklifleri {
    final int offerId;
    final String benimUrunum;
    final String alinacakUrun;
    final String durum;
    final String tarih;

  TakasTeklifleri({
    required this.offerId,
    required this.benimUrunum,
    required this.alinacakUrun,
    required this.durum,
    required this.tarih,
  });
}
