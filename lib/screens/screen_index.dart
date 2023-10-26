// screens/scrren_index.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalcloset/tabs/tab_closet.dart';
import 'package:personalcloset/tabs/tab_home.dart';
import 'package:personalcloset/tabs/tab_mypage.dart';
import 'package:personalcloset/tabs/tab_market.dart';

class IndexScreen extends StatefulWidget {
  @override
  _IndexScreenState createState() {
    return _IndexScreenState();
  }
}

class _IndexScreenState extends State<IndexScreen> {
  int _currentIndex = 0;

  final List<Widget> tabs = [
    IntroScreen(),
    TabHome(),
    ProfilePage(),
    ItemList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PocKet Closet'),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(-35), // 여백의 높이를 조절합니다
          child: Container(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 44,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontSize: 12),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'market'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mypage'),
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Closet'),
        ],
      ),
      body: tabs[_currentIndex],
    );
  }
}
