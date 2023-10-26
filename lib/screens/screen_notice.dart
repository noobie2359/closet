import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공지사항'),
      ),
      body: Center(
        child: Text('이 부분에 공지사항 내용을 표시하세요.'),
      ),
    );
  }
}
