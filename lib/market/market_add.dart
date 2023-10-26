import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class RegItem extends StatefulWidget {
  final Map _market;
  RegItem(this._market, {Key? key}) : super(key: key);

  @override
  State<RegItem> createState() => _RegItem();
}

class _RegItem extends State<RegItem> {
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerSize = TextEditingController();
  TextEditingController _controllerInf = TextEditingController();
  TextEditingController _controllerPrice = TextEditingController();
  late DocumentReference _reference;

  GlobalKey<FormState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controllerName = TextEditingController(text: widget._market['name']);
    _controllerSize = TextEditingController(text: widget._market['size']);

    _reference = FirebaseFirestore.instance
        .collection('market')
        .doc(widget._market['name']);
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerSize.dispose();
    super.dispose();
  }

  String imageUrl = '';
  String? _selectedItem;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('아이템 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: key,
          child: Column(
            children: [
              TextFormField(
                controller: _controllerName,
                decoration: InputDecoration(hintText: '아이템 이름을 입력해주세요'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _controllerSize,
                decoration: InputDecoration(hintText: '아이템 사이즈를 입력해주세요'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the size';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _controllerPrice,
                decoration: InputDecoration(hintText: '아이템 가격을 입력해주세요'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _controllerInf,
                decoration: InputDecoration(hintText: '아이템 설명을 입력해주세요'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the information';
                  }

                  return null;
                },
              ),
              IconButton(
                onPressed: () async {
                  ImagePicker imagePicker = ImagePicker();
                  XFile? file =
                      await imagePicker.pickImage(source: ImageSource.camera);
                  print('${file?.path}');
                  if (file == null) return;

                  // Generate a unique file name using the current time
                  String uniqueFileName =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  /* Upload to Firebase storage */

                  // Reference the root of the storage
                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference referenceDirImages = referenceRoot.child('images');

                  // Create a reference to the image we want to upload
                  Reference referenceImageToUpload =
                      referenceDirImages.child(uniqueFileName);

                  // Upload the file and get the URL
                  try {
                    await referenceImageToUpload.putFile(File(file.path));
                    imageUrl = await referenceImageToUpload.getDownloadURL();
                  } catch (error) {
                    // Handle errors here
                  }
                },
                icon: Icon(Icons.camera_alt),
              ),
              ElevatedButton(
                onPressed: () async {
                  ImagePicker imagePicker = ImagePicker();
                  XFile? file =
                      await imagePicker.pickImage(source: ImageSource.gallery);
                  print('${file?.path}');
                  if (file == null) return;

                  // Generate a unique file name using the current time
                  String uniqueFileName =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  /* Upload to Firebase storage */

                  // Reference the root of the storage
                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference referenceDirImages = referenceRoot.child('images');

                  // Create a reference to the image we want to upload
                  Reference referenceImageToUpload =
                      referenceDirImages.child(uniqueFileName);

                  // Upload the file and get the URL
                  try {
                    await referenceImageToUpload.putFile(File(file.path));
                    imageUrl = await referenceImageToUpload.getDownloadURL();
                  } catch (error) {
                    // Handle errors here
                  }
                },
                child: Text('갤러리에서 선택'),
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (imageUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please upload an image')));
                      return;
                    }

                    if (key.currentState!.validate()) {
                      String itemName = _controllerName.text;
                      String itemSize = _controllerSize.text;
                      String itemInfomation = _controllerInf.text;
                      String itemPrice = _controllerPrice.text;

                      // 데이터 맵
                      Map<String, dynamic> dataToSend = {
                        'name': itemName,
                        'size': itemSize,
                        'information': itemInfomation,
                        'image': imageUrl,
                        'price': itemPrice,
                      };

                      // 카테고리 추가
                      DocumentReference<Map<String, dynamic>> categoryRef =
                          FirebaseFirestore.instance
                              .collection('market')
                              .doc(itemName);

                      categoryRef.set(dataToSend);

                      // 등록 완료 알림 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('물품이 등록 되었습니다!')));
                    }
                  },
                  child: Text('등록하기'))
            ],
          ),
        ),
      ),
    );
  }
}
