import 'dart:async';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTappedRanking = false;
  bool isTappedSchedule = false;
  List<String> travelTitles = [];
  int currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    fetchTravelAddresses();
    _pageController = PageController(initialPage: currentPage);
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (currentPage < travelTitles.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> fetchTravelAddresses() async {
    final apiKey =
        '***REMOVED***';
    final url =
        'http://apis.data.go.kr/B551011/KorService1/areaBasedList1?ServiceKey=$apiKey&arrange=D&numOfRows=5&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      final items = decodedData['response']['body']['items']['item'];
      setState(() {
        travelTitles =
            List<String>.from(items.map((item) => item['title'])).toList();
      });
    } else {
      throw Exception('Failed to load travel addresses');
    }
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = 20;
    double sectionWidth =
        (MediaQuery.of(context).size.width - horizontalMargin * 2 - 20) / 2;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: false,
            pinned: true,
            elevation: 0,
            title: Text('Travel Maker'),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          isTappedRanking = !isTappedRanking;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            color: isTappedRanking ? Colors.red : Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          width: sectionWidth,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '다가오는 지역축제',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 150,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: travelTitles.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(travelTitles[index]),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          isTappedSchedule = !isTappedSchedule;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            color: isTappedSchedule ? Colors.purple : Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          width: sectionWidth,
                          height: 200,
                          child: const Text(
                            '내 일정 바로가기',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              decoration: BoxDecoration(
                color: Colors.lime,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
