import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:travelmaker/pages/post/detail_page.dart';
import 'map_page.dart';
import 'package:travelmaker/pages/post/my_post_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTappedRanking = false;
  bool isTappedSchedule = false;
  List<Map<String, dynamic>> festivalItems = [];
  int currentPage = 0;
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchFestivalData();
    _pageController = PageController(initialPage: currentPage);
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (currentPage < festivalItems.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchFestivalData() async {
    const apiKey = 'xHIYywSVOCXTorWSMxYoMW92r1or16xp%2FtCpAviub7VzP26w68%2BB22HAnjI%2FR6DFfXvd%2BuTxmHUYabfyeti4sw%3D%3D';
    const url = 'http://apis.data.go.kr/B551011/KorService1/areaBasedList1?ServiceKey=$apiKey&arrange=D&numOfRows=100&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];

      if (contentType != null && contentType.contains('application/json')) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));

        final items = decodedData['response']['body']['items']['item']
            .where((item) => item['firstimage'] != null && item['firstimage'].isNotEmpty)
            .take(10)
            .toList();

        setState(() {
          festivalItems = List<Map<String, dynamic>>.from(items);
        });
      } else {
        throw Exception('API 응답 형식이 올바르지 않습니다.');
      }
    } else {
      throw Exception('Failed to load festival data');
    }
  }

  void _navigateToDetail(Map<String, dynamic> festivalItem) {
    Get.to(FestivalDetailPage(
      title: festivalItem['title'],
      address: festivalItem['addr1'],
      image: festivalItem['firstimage'],
      mapx: double.parse(festivalItem['mapx'] ?? '0'),
      mapy: double.parse(festivalItem['mapy'] ?? '0'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = 16.0;
    double buttonWidth = (MediaQuery.of(context).size.width - 2 * horizontalMargin - 16) / 2;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              'Travel Maker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                        onTap: () {
                          setState(() {
                            isTappedRanking = !isTappedRanking;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            color: isTappedRanking ? Colors.deepOrangeAccent : Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          width: buttonWidth,
                          height: 230,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 220,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: festivalItems.length,
                                  itemBuilder: (context, index) {
                                    if (festivalItems.isEmpty) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      final festivalItem = festivalItems[index];
                                      return GestureDetector(
                                        onTap: () => _navigateToDetail(festivalItem),
                                        child: Card(
                                          margin: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  festivalItem['title'],
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              if (festivalItem['firstimage'] != null && festivalItem['firstimage'].isNotEmpty)
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                  child: Image.network(
                                                    festivalItem['firstimage'],
                                                    width: double.infinity,
                                                    height: 160,
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.topCenter,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: horizontalMargin),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyPostList(),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            color: isTappedSchedule ? Colors.deepPurpleAccent : Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          width: buttonWidth,
                          height: 230,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  '나의 여행',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () => Get.to(DetailPage(index)),
                                      title: Text("제목 $index"),
                                      leading: const Icon(Icons.image),
                                    );
                                  },
                                  separatorBuilder: (BuildContext context, int index) {
                                    return const Divider();
                                  },
                                ),
                              ),
                            ],
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
                color: Colors.limeAccent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepOrangeAccent,
                    shape: BoxShape.circle,
                  ),
                  defaultDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FestivalDetailPage extends StatelessWidget {
  final String title;
  final String address;
  final String image;
  final double mapx;
  final double mapy;

  const FestivalDetailPage({
    Key? key,
    required this.title,
    required this.address,
    required this.image,
    required this.mapx,
    required this.mapy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (image.isNotEmpty)
              Image.network(
                image,
                width: double.infinity,
                height: 430,
                fit: BoxFit.fitHeight,
              ),
            const SizedBox(height: 10),
            const Text(
              '상세 주소:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(address),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(
                      mapx: mapx,
                      mapy: mapy,
                    ),
                  ),
                );
              },
              child: const Text('구글 맵에서 보기'),
            ),
            const SizedBox(height: 10),
            const Text(
              '지도 좌표:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('위도: $mapy, 경도: $mapx'),
          ],
        ),
      ),
    );
  }
}
