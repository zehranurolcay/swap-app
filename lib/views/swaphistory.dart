import 'package:flutter/material.dart';

import '../database/offers.dart';
import '../widget/recorded_data.dart';

class SwapHistoryPage extends StatefulWidget {
  @override
  State<SwapHistoryPage> createState() => _SwapHistoryPageState();
}

class _SwapHistoryPageState extends State<SwapHistoryPage> {
  bool isLoading = true;
  String? userId;

  List<TakasTeklifim> teklifler = [];

  void initState() {
    super.initState();
    checkUserId();
  }

  Future<void> checkUserId() async {
    String? id = await getUserId();

    teklifler = await getTradeHistory(id!);
    print(teklifler);
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
        title: Text("Takas Geçmişim"),
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

class TakasTeklifim {
  final int offerId;
  final String benimUrunum;
  final String alinacakUrun;
  final String durum;
  final String tarih;

  TakasTeklifim({
    required this.offerId,
    required this.benimUrunum,
    required this.alinacakUrun,
    required this.durum,
    required this.tarih,
  });
}
