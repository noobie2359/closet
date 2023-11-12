import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:personalcloset/calendar/calendar_ImagePage.dart';
import 'package:personalcloset/screens/statistic_screen.dart';
import 'package:http/http.dart' as http; // 추가
import 'dart:convert'; // 추가
import 'package:personalcloset/market/market_page.dart';

class TabHome extends StatefulWidget {
  const TabHome({Key? key});

  @override
  State<TabHome> createState() => _CalendarState();
}

class _CalendarState extends State<TabHome> {
  DateTime today = DateTime.now();

  String getWeatherComment(String condition) {
    if (condition.contains('rain')) {
      return '비가 오고 있어요. 우산을 챙기세요!';
    } else if (condition.contains('clear')) {
      return '날씨가 맑아요. 산책을 즐기기 좋은 날이에요!';
    } else if (condition.contains('clouds')) {
      return '구름이 많아요. 실내 활동을 계획해 보세요.';
    } else if (condition.contains('snow')) {
      return '눈이 내리고 있어요. 따뜻하게 입고 나가세요!';
    } else if (condition.contains('thunderstorm')) {
      return '천둥번개를 동반한 비가 오고 있어요. 안전에 유의하세요!';
    } else {
      return '날씨 정보를 확인하세요.';
    }
  }

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

  // 날씨 정보 가져오기
  Future<Map<String, dynamic>> fetchWeatherData() async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=Asan&appid=731baa1e40c2e7ee5d127df91d53f738'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return {
        'temperature': (data['main']['temp'] - 273.15)
            .toStringAsFixed(1), // Kelvin to Celsius
        'condition': data['weather'][0]['description'],
      };
    } else {
      throw Exception('Failed to load weather data');
    }
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
                  return ElevatedButton.icon(
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
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    icon: Icon(Icons.edit, color: Colors.white),
                    label: Text('데일리룩 정보 수정',
                        style: TextStyle(color: Colors.white)),
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
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    icon: Icon(Icons.add_a_photo, color: Colors.white),
                    label: Text('데일리룩을 업데이트',
                        style: TextStyle(color: Colors.white)),
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
        SizedBox(height: 16),
        // "날씨 정보" 섹션 추가
        FutureBuilder<Map<String, dynamic>>(
          future: fetchWeatherData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                // 날씨 상태에 따른 아이콘 결정
                IconData weatherIcon;
                String condition = snapshot.data!['condition'];
                String weatherComment = getWeatherComment(
                    condition); // Generate the comment based on the condition

                // Decide the weather icon based on the condition
                if (condition.contains('rain')) {
                  weatherIcon = Icons.umbrella;
                } else if (condition.contains('clear')) {
                  weatherIcon = Icons.wb_sunny;
                } else {
                  weatherIcon = Icons.cloud;
                }

                return Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.blue[100],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 날씨 아이콘과 상태 표시
                          Row(
                            children: [
                              Icon(weatherIcon,
                                  size: 32.0, color: Colors.blue[800]),
                              SizedBox(width: 8.0),
                              Text(
                                '상태: ${snapshot.data!['condition']}',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          // 온도 표시
                          Text(
                            '온도: ${snapshot.data!['temperature']}°C',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // 날씨 코멘트 추가
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          weatherComment, // Display the generated comment
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800]),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Text('날씨 정보를 불러올 수 없습니다.');
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // 버튼들 사이에 고르게 공간을 분배합니다.
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarketPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 255, 94, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: Icon(Icons.shop, color: Colors.white),
              label: Text('중고 장터', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 16), // 버튼 사이의 간격을 조정합니다.
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatisticsPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: Icon(Icons.insert_chart, color: Colors.white),
              label: Text('통계 보기', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
