import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:personalcloset/calendar/calendar_ImagePage.dart';
import 'package:personalcloset/screens/statistic_screen.dart';

class TabHome extends StatefulWidget {
  const TabHome({Key? key});

  @override
  State<TabHome> createState() => _CalendarState();
}

class _CalendarState extends State<TabHome> {
  DateTime today = DateTime.now();

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      today = day;
    });

    DocumentSnapshot snapshot = await _getData(day);
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    if (snapshot.exists && data != null && data.containsKey('imageUrl')) {
      String imageUrl = data['imageUrl'];
      print(imageUrl);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePage(
            imageUrl: imageUrl,
            date: today,
          ),
        ),
      );
    } else {
      print('No image found for the selected date.');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePage(
            imageUrl: null,
            date: today,
          ),
        ),
      );
    }
  }

  Future<DocumentSnapshot> _getData(DateTime date) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(date);

    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('images')
        .doc(formatted)
        .get();

    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: TableCalendar(
            locale: "en_US",
            rowHeight: 43,
            headerStyle:
                HeaderStyle(formatButtonVisible: false, titleCentered: true),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            focusedDay: today,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            onDaySelected: _onDaySelected,
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: FutureBuilder<DocumentSnapshot>(
            future: _getData(today),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic>? data =
                    snapshot.data?.data() as Map<String, dynamic>?;
                if (snapshot.hasData &&
                    data != null &&
                    data.containsKey('imageUrl')) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePage(
                            imageUrl: data['imageUrl'],
                            date: today,
                          ),
                        ),
                      );
                    },
                    child: Text('데일리룩 정보 수정'),
                  );
                } else {
                  return ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePage(
                            imageUrl: null,
                            date: today,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.accessibility),
                    label: Text('데일리룩을 업데이트'),
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
        SizedBox(height: 16), // 버튼 위 추가 간격

        // "통계 보기" 버튼 추가
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
          label: Text('통계 보기'),
        ),
      ],
    );
  }
}
