import 'package:flutter/material.dart';
import 'package:travelmaker/src/components/image_data.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTappedRanking = false;
  bool isTappedSchedule = false;

  @override
  Widget build(BuildContext context) {
    // 달력 섹션과 같은 여백을 위해 사용
    double horizontalMargin = 20;
    double sectionWidth = (MediaQuery.of(context).size.width - horizontalMargin * 2 - 20) / 2; // 20은 섹션 사이의 여백

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            //expandedHeight: 200.0,
            floating: false,
            pinned: true,
            elevation: 0,
            title: ImageData(
              IconsPath.logoh,
              width: 300,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 섹션 사이의 간격을 최대로 설정
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          isTappedRanking = !isTappedRanking;
                        }),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            color: isTappedRanking ? Colors.red : Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          width: sectionWidth,
                          height: 200,
                          child: Text('현재 관광지 랭킹', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          isTappedSchedule = !isTappedSchedule;
                        }),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            color: isTappedSchedule ? Colors.purple : Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          width: sectionWidth,
                          height: 200,
                          child: Text('내 여행일정 바로가기', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          SliverToBoxAdapter( // 달력을 SliverToBoxAdapter로 감싼다
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
