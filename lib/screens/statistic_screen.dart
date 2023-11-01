import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<Map<String, Map<String, dynamic>>> getItemCounts() async {
  Map<String, Map<String, dynamic>> itemDetailsMap = {};

  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('images').get();

  for (var doc in snapshot.docs) {
  var rawData = doc.data();
  List<Map<String, dynamic>>? itemsDetails;  // 여기서 선언

  if (rawData is Map<String, dynamic>) {
    Map<String, dynamic> data = rawData;
    if (data.containsKey('itemsDetails') && data['itemsDetails'] is List) {
      itemsDetails = (data['itemsDetails'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      print("itemsDetails 필드가 없거나 올바른 타입이 아닙니다.");
      continue;  // 다음 doc으로 이동
    }
  } else {
    print("문서 데이터가 null이거나 Map<String, dynamic> 타입이 아닙니다.");
    continue;  // 다음 doc으로 이동
  }

  for (Map<String, dynamic> itemDetail in itemsDetails!) {  // '!'를 사용하여 nullable 처리
    String itemName = itemDetail['name'];
    if (itemDetailsMap.containsKey(itemName)) {
      int currentCount = itemDetailsMap[itemName]!['count']!;
      itemDetailsMap[itemName]!['count'] = currentCount + 1;
    } else {
      itemDetailsMap[itemName] = {
        'count': 1,
        'itemImage': itemDetail['imageUrls']  // 이미지 URL 정보를 저장합니다.
      };
    }
  }
}

  return itemDetailsMap;
}

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late Future<Map<String, Map<String, dynamic>>> itemCountsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    itemCountsFuture = getItemCounts();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabContent(Map<String, Map<String, dynamic>> itemData, bool frequent) {
    List<MapEntry<String, Map<String, dynamic>>> items = frequent
        ? itemData.entries.where((e) => e.value['count'] >= 5).toList()
        : itemData.entries.where((e) => e.value['count'] < 5).toList();

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        String key = items[index].key;
        Map<String, dynamic> data = items[index].value;
        return ListTile(
          title: Text("$key: ${data['count']}회"),
          leading: Image.network(data['itemImage']), // 이미지 URL 사용
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("옷 빈도수 분석")),
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: itemCountsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("에러: ${snapshot.error}"));
            }

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: "가장 자주 입은 옷들"),
                      Tab(text: "손이 가지 않았던 옷")
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTabContent(snapshot.data!, true),
                        _buildTabContent(snapshot.data!, false)
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}