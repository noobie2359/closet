import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:personalcloset/tabs/item_add.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  Color? selectedColor;
  String? selectedImageUrl;
  String? selectedCategory;
  final List<String> categories = ['상의', '신발', '악세서리', '하의'];
  bool showSelectionScreen = false;
  List<String> similarImages = [];

  Future<Color> getDominantColor(String imageUrl) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(NetworkImage(imageUrl));
    return paletteGenerator.dominantColor?.color ?? Colors.grey;
  }

  Future<List<String>> findSimilarColors(Color selectedColor) async {
    similarImages.clear();

    // 먼저 선택된 아이템을 리스트에 추가합니다.
    if (selectedImageUrl != null && selectedCategory != null) {
      similarImages.add(selectedImageUrl!);
    }

    for (var category in categories) {
      // 선택된 카테고리의 아이템은 이미 추가했으므로 건너뜁니다.
      if (category == selectedCategory) continue;

      QuerySnapshot<Map<String, dynamic>> items = await FirebaseFirestore
          .instance
          .collection('shopping_list')
          .doc(category)
          .collection('items')
          .get();

      for (var item in items.docs) {
        String imageUrl = item['image'];
        Color itemColor = await getDominantColor(imageUrl);

        if (isSimilarColor(selectedColor, itemColor)) {
          similarImages.add(imageUrl);
          // 각 카테고리별로 첫 번째 유사한 색상의 아이템만 찾습니다.
          break;
        }
      }
    }

    return similarImages;
  }

  bool isSimilarColor(Color a, Color b) {
    return (a.red - b.red).abs() < 75 &&
        (a.green - b.green).abs() < 75 &&
        (a.blue - b.blue).abs() < 75;
  }

  @override
  Widget build(BuildContext context) {
    return showSelectionScreen ? buildSelectionScreen() : buildInitialScreen();
  }

  Widget buildInitialScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('코디 추천'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                '나만의 스타일을 찾아보세요!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              const Text(' 입을 옷을 등록하고 옷장에 있는 옷들을\n 활용해서 어울리는 착장을 완성해보세요'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => buildSelectionScreen()),
                  );
                },
                child: const Text('옷장에서 선택하기'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                          MaterialPageRoute(builder: (context) => AddItem({})))
                      .then((value) => setState(() {}));
                },
                child: const Text('아이템 등록하기'),
              ),
              if (selectedColor != null && selectedImageUrl != null) ...[
                const SizedBox(height: 20), // 상단 간격 조정
                const Text(
                  '선택된 아이템',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10), // 제목과 이미지 사이의 간격 조정
                Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Image.network(selectedImageUrl!,
                          height: 100, fit: BoxFit.cover),
                      Container(
                        height: 50,
                        color: selectedColor,
                        alignment: Alignment.center,
                        child: const Text(
                          '추천 색상 매칭',
                          style: TextStyle(
                              color: Color.fromARGB(255, 225, 0, 255),
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // 선택된 아이템과 유사한 아이템들 사이의 간격 조정
                const Text(
                  '추천 코디',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10), // 제목과 유사한 아이템들 사이의 간격 조정
                ...similarImages.map((imgUrl) => Card(
                      elevation: 5,
                      child:
                          Image.network(imgUrl, height: 100, fit: BoxFit.cover),
                    )),
                const SizedBox(height: 10), // 각 유사한 아이템들 사이의 간격 조정
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectionScreen() {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My closet'),
          bottom: TabBar(
            tabs: categories.map((category) => Tab(text: category)).toList(),
          ),
        ),
        body: TabBarView(
          children: categories.map((category) {
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
                return SingleChildScrollView(
                  // Enable scrolling
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap:
                            true, // Needed to use GridView inside a SingleChildScrollView
                        physics:
                            const ClampingScrollPhysics(), // To work alongside the SingleChildScrollView
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3 / 4,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];
                          String currentCategory = category;
                          return InkWell(
                            onTap: () async {
                              Color newColor =
                                  await getDominantColor(doc['image']);
                              String newCategory = category;

                              // 새로운 선택을 위해 상태를 초기화합니다.
                              List<String> newSimilarItems = [];

                              Navigator.pop(context);

                              setState(() {
                                selectedColor = newColor;
                                selectedCategory = newCategory;
                                selectedImageUrl = doc['image'];
                                similarImages =
                                    newSimilarItems; // 초기화된 리스트를 설정합니다.
                              });

                              newSimilarItems =
                                  await findSimilarColors(newColor);

                              setState(() {
                                similarImages =
                                    newSimilarItems; // 새로운 유사한 이미지 리스트를 업데이트합니다.
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.all(4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(doc['image'],
                                    fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

