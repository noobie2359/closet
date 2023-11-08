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
    // 아이템을 빈도수에 따라 내림차순으로 정렬합니다.
    List<MapEntry<String, Map<String, dynamic>>> sortedItems = itemData.entries.toList()
        ..sort((a, b) => b.value['count'].compareTo(a.value['count']));
    
    // 상위 5개 또는 하위 5개의 아이템을 가져옵니다.
    List<MapEntry<String, Map<String, dynamic>>> itemsToShow = frequent
        ? sortedItems.take(5).toList()
        : sortedItems.reversed.take(5).toList();

    return ListView.builder(
      itemCount: itemsToShow.length,
      itemBuilder: (context, index) {
        String key = itemsToShow[index].key;
        Map<String, dynamic> data = itemsToShow[index].value;
        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(key),
              SizedBox(height: 4),  // 간격을 조금 추가합니다.
              Text("횟수 : ${data['count']}회")
            ],
          ),
          leading: Container(
            width: 100.0,  // 원하는 너비로 변경
            height: 100.0,  // 원하는 높이로 변경
            decoration: BoxDecoration(
              image: DecorationImage(
              fit: BoxFit.contain,  // 이미지가 컨테이너에 꽉 차도록 조정
              image: NetworkImage(data['itemImage'])
          ),
        ),
        ),
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
                        _buildTabContent(snapshot.data!, true),  // 상위 5개
                        _buildTabContent(snapshot.data!, false)  // 하위 5개
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