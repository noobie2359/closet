import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Askpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 가상의 게시판 데이터. 실제 데이터는 데이터베이스에서 가져와야 합니다.
    List<String> boardData = [
      "문의 1: 여기에 내용 1",
      "문의 2: 여기에 내용 2",
      "문의 3: 여기에 내용 3",
      // 원하는 만큼 게시물 추가
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('문의 게시판'),
      ),
      body: ListView.builder(
        itemCount: boardData.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(boardData[index]),
            // 게시물을 누를 때 이벤트 처리를 추가할 수 있습니다.
            onTap: () {
              // 게시물을 눌렀을 때의 동작 추가
              // 예를 들어, 게시물의 세부 내용 페이지로 이동할 수 있습니다.
            },
          );
        },
      ),
    );
  }
}
class Post {
  String title;
  String content;

  Post({required this.title, required this.content});
}
class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: '내용'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPost = Post(
                  title: titleController.text,
                  content: contentController.text,
                );
                // 게시판 데이터에 새 게시물 추가
                // 이후 게시판 화면으로 돌아가거나 게시물을 업데이트합니다.
              },
              child: Text('등록'),
            ),
          ],
        ),
      ),
    );
  }
}
