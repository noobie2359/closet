import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personalcloset/screens/screen_ask.dart';
import 'package:personalcloset/screens/screen_notice.dart';
import 'package:personalcloset/screens/statistic_screen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  String _nickname = "";
  String _email = "";
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });

    if (user != null) {
      try {
        DocumentSnapshot userInfo = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userInfo.exists) {
          setState(() {
            _nickname = userInfo['nickname'] ?? "로딩 중...";
            _email = user.email ?? "";
          });
        }
      } catch (e) {
        print('Firestore 데이터 가져오기 오류: $e');
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.getImage(source: source);

    if (pickedFile != null) {
      // 이미지 선택 시 처리할 내용 추가
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '  마이페이지',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // 제목 텍스트 색상 설정
        ),

        backgroundColor: Colors.white,
        iconTheme:
            IconThemeData(color: Color.fromARGB(255, 0, 0, 0)), // 아이콘 색상 설정
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: _user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: ((builder) => bottomSheet()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person),
                      // You can set the initial profile picture here.
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      constraints: BoxConstraints(maxWidth: 220),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        // Wrap the Column with Center
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Align text center horizontally
                          children: <Widget>[
                            Text(
                              _nickname,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            Text(
                              '${_user!.email}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 통계 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.insert_chart),
                    label: Text('스타일 통계'),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                // 공지사항 버튼 클릭 시 처리
                // 예: Navigator를 사용하여 새 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NoticePage()),
                );
              },
              child: Text('공지사항'),
            ),
            TextButton(
              onPressed: () {
                // 문의하기 버튼 클릭 시 처리
                // 예: Navigator를 사용하여 새 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Askpage()),
                );
              },
              child: Text('문의하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomSheet() {
  return Container(
    height: 200, // Adjust the height to your preference
    width: MediaQuery.of(context).size.width,
    margin: EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Text(
            'Choose Profile photo',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton.icon(
                icon: Icon(
                  Icons.camera,
                  size: 50,
                ),
                onPressed: () {
                  _getImage(ImageSource.camera);
                },
                label: Text(
                  'Camera',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  Icons.photo_library,
                  size: 50,
                ),
                onPressed: () {
                  _getImage(ImageSource.gallery);
                },
                label: Text(
                  'Gallery',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
  }
}
