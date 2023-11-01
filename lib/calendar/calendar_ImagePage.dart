import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:collection/collection.dart';

class ImagePage extends StatefulWidget {
  final String? imageUrl;
  final DateTime? date;

  ImagePage({required this.imageUrl, required this.date});

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  List<Map<String,dynamic>> selectedItemsDetails = []; // to store selected items
  late String formattedDate;
  File? _image;

  // 이미지피커
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  // 파이어베이스에서 아이템 목록을 가져오는 기능
  Future<List<Map<String,dynamic>>> getItems() async {
    List<String> categories = ['상의', '신발', '악세서리', '하의'];
    List<Map<String,dynamic>> itemList = [];

    for (String category in categories) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("shopping_list")
          .doc(category)
          .collection('items')
          .get();
      for (var doc in querySnapshot.docs) {
        itemList.add(doc.data() as Map<String,dynamic>);
      }
    }
    return itemList;
  }

  void _addItem() async {
    List<Map<String,dynamic>> items = await getItems();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("아이템을 선택해주세요"),
            content: DropdownButton<String>(
              hint: Text("아이템을 선택해주세요"),
              value: _selectedItem,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItem = newValue;
                });
              },
              items: items.map<DropdownMenuItem<String>>((itemMap) {
                return DropdownMenuItem<String>(
                  value: itemMap['name'],
                  child: Text(itemMap['name']),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                child: Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("추가"),
                onPressed: () {
                  if (_selectedItem != null) {
                    Map<String, dynamic>? selectedItem = items.firstWhereOrNull(
                      (item) => item['name'] == _selectedItem,
                    );
                    if (selectedItem != null) {
                      setState(() {
                        selectedItemsDetails.add(selectedItem);
                      });
                    }
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
}


  // 파이어베이스에서 데이터 불러오는 함수
  Future<DocumentSnapshot> _getData(DateTime date) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(date);

    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('images')
        .doc(formatted)
        .get();

    return snapshot;
  }

  // 파이어베이스에 이미지와 선택한 아이템 업로드
  // 파이어베이스에 이미지 업로드
  Future<void> _uploadImage(DateTime date, List<Map<String,dynamic>> itemsDetails) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(date);

    final Reference storageRef =
        FirebaseStorage.instance.ref().child('images/$formatted.jpg');
    final TaskSnapshot snapshot = await storageRef.putFile(_image!);
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    final DocumentReference documentRef =
        FirebaseFirestore.instance.collection('images').doc(formatted);

    List<Map<String,dynamic>> itemsToSave=itemsDetails.map((item) {
      return {
        'name': item['name'],
        'imageUrls':item['image'],
      };
    }).toList();

    await documentRef.set({
      'imageUrl': downloadUrl,
      'date': formatted,
      'itemsDetails': itemsToSave, // 선택된 아이템들
    });

    // 이미지 업로드가 완료되면 setState 메소드 호출 ,
    // _image 변수를 null로 초기화하고 문구 출력
    setState(() {
      _image = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('데일리룩이 업로드 되었습니다!'),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    formattedDate = formatter.format(widget.date!);
  }

  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
      ),
      body: Column(
        children: [
          _image != null
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 99, vertical: 30),
                  child: Image.file(_image!),
                )
              : widget.imageUrl != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 99, vertical: 30),
                      child: Image.network(widget.imageUrl!),
                    )
                  : Center(child: Text('이 날짜에는 업로드된 데일리룩이 없습니다.')),
          ListView.builder(
            shrinkWrap: true,
            itemCount: selectedItemsDetails.length,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<List<Map<String,dynamic>>>(
                future: getItems(),
                builder: (BuildContext context, AsyncSnapshot<List<Map<String,dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      // add this line
                      return Text('No items found.'); // add this line
                    } // add this line
                    return DropdownButton<String>(
                      hint: Text("아이템을 선택해주세요"),
                      value: selectedItemsDetails[
                          index]['name'], // ensure this value is in snapshot.data
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedItemsDetails[index]['name'] = newValue;
                          });
                        }
                      },
                      items: snapshot.data!
                          .map<DropdownMenuItem<String>>((itemMap) {
                        return DropdownMenuItem<String>(
                          value: itemMap['name'],
                          child: Text(itemMap['name']),
                        );
                      }).toList(),
                    );
                  }
                },
              );
            },
          ),
          ElevatedButton(
            onPressed: _addItem,
            child: Text('아이템 추가 선택'),
          ),
        ],
      ),
      bottomNavigationBar: _image == null
          ? BottomAppBar(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: Text('이미지를 선택해주세요'),
              ),
            )
          : BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _image = null;
                      });
                    },
                    child: Text('다시 선택'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedItemsDetails.isNotEmpty) {
                        _uploadImage(widget.date!, selectedItemsDetails);
                      } else {
                        print('Please select at least one item.');
                      }
                    },
                    child: Text('Upload image'),
                  ),
                ],
              ),
            ),
    );
  }
}