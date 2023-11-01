import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personalcloset/screens/screen_ask.dart';
import 'package:personalcloset/screens/screen_notice.dart';
import 'package:personalcloset/screens/statistic_screen.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart'; // 필요한 패키지를 import

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  String _nickname = ""; // Define _nickname here
  String _email = "";
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage; // Define _profileImage here
  String? _profileImageUrl; // 프로필 이미지 URL을 저장하기 위한 변수

  final TextStyle _titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  final ButtonStyle _buttonStyle = ElevatedButton.styleFrom(
    primary: Colors.green[500],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  );

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
            _profileImageUrl = userInfo['profileImageUrl']; // 프로필 이미지 URL 로드
          });
        }
      } catch (e) {
        print('Firestore 데이터 가져오기 오류: $e');
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage != null) {
      // Firebase Storage에 이미지 업로드 로직
      try {
        String userId = _user?.uid ?? "unknown_user";
        String fileName =
            'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('profile_images/$fileName')
            .putFile(_profileImage!);

        // 업로드 완료 대기
        TaskSnapshot snapshot = await uploadTask;

        // 업로드된 사진의 URL 가져오기
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Firestore에 이미지 URL 저장
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'profileImageUrl': imageUrl});

        // UI 업데이트 및 메시지 표시
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("프로필 사진이 업데이트되었습니다.")));
      } catch (e) {
        print('이미지 업로드 오류: $e');
        // 오류 메시지 표시
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("이미지 업로드에 실패했습니다.")));
      }
    } else {
      // 이미지가 선택되지 않았을 때 메시지 표시
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("먼저 이미지를 선택해주세요.")));
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.getImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Firebase Storage에 이미지 업로드
      try {
        String userId = _user?.uid ?? "unknown_user";
        String fileName =
            'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('profile_images/$fileName')
            .putFile(imageFile);

        // 업로드 완료 대기
        TaskSnapshot snapshot = await uploadTask;

        // 업로드된 사진의 URL 가져오기
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Firestore에 이미지 URL 저장
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'profileImageUrl': imageUrl});

        // 상태 업데이트
        setState(() {
          _profileImage = imageFile;
        });
      } catch (e) {
        print('이미지 업로드 오류: $e');
        // 오류 처리 로직 추가 가능
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '  마이페이지',
          style: TextStyle(color: Colors.black), // 제목 텍스트 색상 설정
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 설정
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
                  _buildProfileImage(),
                  SizedBox(height: 20),
                  _buildProfileInfo(),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsPage(),
                        ),
                      );
                    },
                    style: _buttonStyle,
                    icon: Icon(Icons.insert_chart, color: Colors.white),
                    label: Text('스타일 통계', style: _titleStyle),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (builder) => _buildBottomSheet(),
        );
      },
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: _profileImageUrl != null // URL을 사용하여 프로필 이미지 표시
            ? ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  _profileImageUrl!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(Icons.person), // Fallback if _profileImageUrl is null
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      constraints: BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(_nickname, style: _titleStyle), // Use _nickname here
            Divider(thickness: 1),
            Text('${_user!.email}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoticePage()),
              );
            },
            child: Text('공지사항'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Askpage()),
              );
            },
            child: Text('문의하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      height: 250, // 높이를 조정하여 모든 요소가 잘 보이도록 합니다
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text('Choose Profile Photo', style: _titleStyle),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildSheetButton(Icons.camera, 'Camera', ImageSource.camera),
                _buildSheetButton(
                    Icons.photo_library, 'Gallery', ImageSource.gallery),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage, // 업로드 함수 호출
              child: Text('제출하기'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetButton(IconData icon, String label, ImageSource source) {
    return TextButton.icon(
      icon: Icon(icon, size: 50),
      onPressed: () => _getImage(source),
      label: Text(label, style: TextStyle(fontSize: 20)),
    );
  }
}
