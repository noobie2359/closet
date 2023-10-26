import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'item_add.dart';

class ItemList extends StatefulWidget {
  @override
  _CategoryTabState createState() => _CategoryTabState();
}

class _CategoryTabState extends State<ItemList> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Closet'),
          bottom: TabBar(
            tabs: [
              Tab(text: '상의'),
              Tab(text: '하의'),
              Tab(text: '신발'),
              Tab(text: '악세서리'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
        body: TabBarView(
          children: [
            _buildCategoryList('상의'),
            _buildCategoryList('하의'),
            _buildCategoryList('신발'),
            _buildCategoryList('악세서리'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddItem({})))
                .then((value) => setState(() {}));
          },
          tooltip: 'Add Item',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoryList(String category) {
    return Builder(builder: (BuildContext context) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('shopping_list')
            .doc(category)
            .collection('items')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return GridView.count(
            crossAxisCount: 3,
            children: snapshot.data!.docs.map((doc) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          _buildDetailScreen(context, doc.id, category),
                    ),
                  );
                },
                child: Hero(
                  tag: doc.id,
                  child: Image.network(doc['image']),
                ),
              );
            }).toList(),
             mainAxisSpacing: 8.0, // 세로 아이템 간격 설정
  crossAxisSpacing: 8.0, // 가로 아이템 간격 설정
  childAspectRatio: 3 / 4, // 각 아이템의 가로 세로 비율 설정
          );
        },
      );
    });
  }

  Widget _buildDetailScreen(
      BuildContext context, String docId, String category) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('shopping_list')
          .doc(category)
          .collection('items')
          .doc(docId)
          .get(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('The item does not exist.'));
        }
        final data = snapshot.data!.data()!;
        return Scaffold(
          appBar: AppBar(
            title: Text(data['name']),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text('Delete Item'),
                      content: Text('아이템을 정말 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await snapshot.data!.reference.delete();
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (shouldDelete == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('아이템이 제거되었습니다.'),
                      ),
                    );
                    setState(() {});
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Hero(
                tag: docId,
                child: Image.network(data['image']),
              ),
            ),
          ),
        );
      },
    );
  }
}
