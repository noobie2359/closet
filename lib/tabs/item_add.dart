import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddItem extends StatefulWidget {
  final Map _shoppingItem;
  AddItem(this._shoppingItem, {Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerSize = TextEditingController();
  late DocumentReference _reference;

  GlobalKey<FormState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controllerName = TextEditingController(text: widget._shoppingItem['name']);
    _controllerSize = TextEditingController(text: widget._shoppingItem['size']);

    _reference = FirebaseFirestore.instance
        .collection('shopping_list')
        .doc(widget._shoppingItem['name']);
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerSize.dispose();
    super.dispose();
  }

  String imageUrl = '';
  String? _selectedCategory;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add an item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: key,
          child: Column(
            children: [
              ListTile(
                title: const Text('상의'),
                leading: Radio<String>(
                  value: '상의',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('하의'),
                leading: Radio<String>(
                  value: '하의',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('신발'),
                leading: Radio<String>(
                  value: '신발',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('악세서리'),
                leading: Radio<String>(
                  value: '악세서리',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
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
                      String selectedCategory = _selectedCategory ?? '';

                      // 데이터 맵
                      Map<String, dynamic> dataToSend = {
                        'name': itemName,
                        'size': itemSize,
                        'image': imageUrl,
                      };

                      // 카테고리 추가
                      DocumentReference<Map<String, dynamic>> categoryRef =
                          FirebaseFirestore.instance
                              .collection('shopping_list')
                              .doc(selectedCategory)
                              .collection('items')
                              .doc(itemName);

                      categoryRef.set(dataToSend);

                      // 등록 완료 알림 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('의류가 추가되었습니다!')));
                    }
                  },
                  child: Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
}
