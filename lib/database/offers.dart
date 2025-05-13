import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swap/views/swaphistory.dart';

import '../views/swapoffers.dart';
import '../views/swapoffers_1.dart';
import 'all-items.dart';

Future<List<Offer>> fetchOffers() async {
  final response = await http.get(Uri.parse('http://10.0.2.2/api/offers'));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData["success"] == true) {
      List<dynamic> itemsJson = jsonData["offers"];
      return itemsJson.map((json) => Offer.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  } else {
    throw Exception('Sunucu hatası: ${response.statusCode}');
  }
}

class Offer {
  final int offerId;
  final int itemId;
  final int offered_by;
  final int offered_item_id;
  final String status;
  final String createdAt;

  Offer({
    required this.offerId,
    required this.itemId,
    required this.offered_by,
    required this.offered_item_id,
    required this.status,
    required this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      offerId: json['offer_id'],
      itemId: json['item_id'],
      offered_by: json['offered_by'],
      offered_item_id: json['offered_item_id'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}

///BÜTÜN ÜRÜNLER LİSTESİ ///
Future<List<TakasTeklifleri>> getOffers(String userId) async {
  List<Offer> offerList = await fetchOffers();
  List<Item> itemList = await fetchItems();
  List<TakasTeklifleri> myOfferList = [];
  late String myitem;
  late String otheritem;

  for (var offer in offerList) {
    if(offer.offered_by.toString() == userId && offer.status == "Bekliyor")
      {
        for (var item in itemList) {
          if(offer.offered_item_id == item.itemId)
            {
              myitem = item.title;
            }
        }

        for (var item in itemList) {
          if(offer.itemId == item.itemId)
          {
            otheritem = item.title;
          }
        }

        String createdAtStr = offer.createdAt;
        DateTime createdAt = DateTime.parse(createdAtStr);
        DateTime now = DateTime.now();
        Duration fark = now.difference(createdAt);
        int gecenGun = fark.inDays;

        myOfferList.add(
          TakasTeklifleri(
            offerId: offer.offerId,
            benimUrunum: myitem,
            alinacakUrun: otheritem,
            durum: offer.status,
            tarih: gecenGun.toString(),
          ),
        );
      }

  }

  return myOfferList;
}

Future<List<TakasTeklifi>> getIncomingOffers(String userId) async {
  List<Offer> offerList = await fetchOffers();
  List<Item> itemList = await fetchItems();
  List<TakasTeklifi> incomingOfferList = [];
  late String myitem;
  late String otheritem;

  for (var offer in offerList) {
    // Teklifi yapan ben değilim ve teklif hala "Bekliyor"
    if (offer.offered_by != userId && offer.status == "Bekliyor") {
      // Teklif edilen item (karşı tarafın ürünü)
      for (var item in itemList) {
        if (offer.offered_item_id == item.itemId) {
          otheritem = item.title;
        }
      }

      // Sana teklif edilen ürün senin mi?
      for (var item in itemList) {
        if (offer.itemId == item.itemId && item.userId.toString() == userId) {
          myitem = item.title;

          // Teklif tarihi işlemleri
          String createdAtStr = offer.createdAt;
          DateTime createdAt = DateTime.parse(createdAtStr);
          DateTime now = DateTime.now();
          Duration fark = now.difference(createdAt);
          int gecenGun = fark.inDays;

          incomingOfferList.add(
            TakasTeklifi(
              offerId: offer.offerId,
              benimUrunum: myitem,
              alinacakUrun: otheritem,
              durum: offer.status,
              tarih: gecenGun.toString(),
            ),
          );
        }
      }
    }
  }

  return incomingOfferList;
}

Future<List<TakasTeklifim>> getTradeHistory(String userId) async {
  List<Offer> offerList = await fetchOffers();
  List<Item> itemList = await fetchItems();
  List<TakasTeklifim> historyList = [];

  for (var offer in offerList) {
    // Status "Bekliyor" değilse devam et
    if (offer.status.toLowerCase().trim() != "bekliyor") {
      bool isUserInvolved = false;
      String myitem = "";
      String otheritem = "";

      // Kullanıcının yaptığı teklif
      if (offer.offered_by.toString().trim() == userId.trim()) {
        isUserInvolved = true;

        // Kullanıcının teklif ettiği ürün
        for (var item in itemList) {
          if (offer.offered_item_id == item.itemId) {
            myitem = item.title;
            break;
          }
        }

        // Almak istediği ürün
        for (var item in itemList) {
          if (offer.itemId == item.itemId) {
            otheritem = item.title;
            break;
          }
        }
      }

      // Kullanıcının ürünü teklif edildiyse (gelen teklif)
      for (var item in itemList) {
        if (offer.itemId == item.itemId &&
            item.userId.toString().trim() == userId.trim()) {
          isUserInvolved = true;
          myitem = item.title;

          // Karşı tarafın ürünü
          for (var other in itemList) {
            if (offer.offered_item_id == other.itemId) {
              otheritem = other.title;
              break;
            }
          }

          break;
        }
      }

      // Kullanıcı bir şekilde bu teklifle ilişkiliyse ekle
      if (isUserInvolved) {
        DateTime createdAt = DateTime.tryParse(offer.createdAt) ?? DateTime.now();
        int gecenGun = DateTime.now().difference(createdAt).inDays;

        historyList.add(
          TakasTeklifim(
            offerId: offer.offerId,
            benimUrunum: myitem,
            alinacakUrun: otheritem,
            durum: offer.status,
            tarih: gecenGun.toString(),
          ),
        );
      }
    }
  }

  return historyList;
}

