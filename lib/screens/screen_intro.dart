import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        scrollPhysics: BouncingScrollPhysics(),
        pages: [
          PageViewModel(
            titleWidget: Text(
              "옷장 등록하기",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            body: "옷장을 등록하고 간편하게 \n가지고 있는 옷을 활용해보세요.",
            image: Padding(
              padding: EdgeInsets.only(top: 50), // 여기에 상단 패딩을 설정합니다.
              child: Image.asset(
                "lib/images/closet2.png",
                height: 400,
                width: 400,
              ),
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "데일리룩 기록",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            body: "캘린더 기능을 통해 \n매일 입은 옷들을 기록해보세요.",
            image: Padding(
              padding: EdgeInsets.only(top: 50), // 여기에 상단 패딩을 설정합니다.
              child: Image.asset(
                "lib/images/calendar.png",
                height: 400,
                width: 400,
              ),
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "통계 제공",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            body: "옷장과 캘린더에 기록한 정보들을 바탕으로 \n통계를 제공받아 옷 활용도를 파악해보세요.",
            image: Padding(
              padding: EdgeInsets.only(top: 50), // 여기에 상단 패딩을 설정합니다.
              child: Image.asset(
                "lib/images/statistics.png",
                height: 400,
                width: 400,
              ),
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "중고장터",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            body: "옷장에서 입지 않는 옷들을 발견했다면\n 중고장터를 통해 판매해보세요.",
            image: Padding(
              padding: EdgeInsets.only(top: 50), // 여기에 상단 패딩을 설정합니다.
              child: Image.asset(
                "lib/images/cart.png",
                height: 400,
                width: 400,
              ),
            ),
          ),
        ],
        onDone: () {
          Navigator.pushNamed(context, "/splash");
        },
        onSkip: () {
          Navigator.pushNamed(context, "/splash");
        },
        showSkipButton: true,
        skip: Text(
          "Skip",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF6C63FF),
          ),
        ),
        next: Icon(
          Icons.arrow_forward,
          color: Color(0xFF6C63FF),
        ),
        done: Text(
          "Done",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF6C63FF),
          ),
        ),
        dotsDecorator: DotsDecorator(
          size: Size.square(10.0),
          activeSize: Size(20.0, 10.0),
          color: Colors.black26,
          activeColor: Color(0xFF6C63FF),
          spacing: EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
