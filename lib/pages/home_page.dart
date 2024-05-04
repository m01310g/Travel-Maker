import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:travelmaker/pages/post/detail_page.dart';
import 'map_page.dart';
import 'package:travelmaker/pages/post/my_post_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTappedRanking = false;
  bool isTappedSchedule = false;
  List<Map<String, dynamic>> festivalItems = [];
  int currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    fetchFestivalData();
    _pageController = PageController(initialPage: currentPage);
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (currentPage < festivalItems.length - 1) {
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

  Future<void> fetchFestivalData() async {
    final apiKey = 'xHIYywSVOCXTorWSMxYoMW92r1or16xp%2FtCpAviub7VzP26w68%2BB22HAnjI%2FR6DFfXvd%2BuTxmHUYabfyeti4sw%3D%3D';
    final url = 'http://apis.data.go.kr/B551011/KorService1/areaBasedList1?ServiceKey=$apiKey&arrange=D&numOfRows=100&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];

      if (contentType != null && contentType.contains('application/json')) {
        // JSON 응답을 파싱
        final decodedData = json.decode(utf8.decode(response.bodyBytes));

        // 항목을 필터링하여 이미지가 있는 항목만 포함
        final items = decodedData['response']['body']['items']['item']
            .where((item) => item['firstimage'] != null && item['firstimage'].isNotEmpty)
            .take(10) // 최대 10개의 항목만 포함
            .toList();

        setState(() {
          festivalItems = List<Map<String, dynamic>>.from(items);
        });
      } else {
        // JSON 형식이 아닌 경우 오류 처리
        throw Exception('API 응답 형식이 올바르지 않습니다.');
      }
    } else {
      throw Exception('Failed to load festival data');
    }
  }



  void _navigateToDetail(Map<String, dynamic> festivalItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FestivalDetailPage(
          title: festivalItem['title'],
          address: festivalItem['addr1'],
          image: festivalItem['firstimage'],
          mapx: double.parse(festivalItem['mapx'] ?? '0'),
          mapy: double.parse(festivalItem['mapy'] ?? '0'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = 16.0; // 수평 여백
    double buttonWidth = (MediaQuery.of(context).size.width - 2 * horizontalMargin - 16) / 2;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
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
                                child:
                                //
                                // 'HomePage' 클래스의 'build' 메서드 내에 있는 'PageView.builder' 부분 수정
                                // 'HomePage' 클래스의 'build' 메서드 내에 있는 'PageView.builder' 부분 수정
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: festivalItems.length,
                                  itemBuilder: (context, index) {
                                    final festivalItem = festivalItems[index];
                                    return GestureDetector(
                                      onTap: () => _navigateToDetail(festivalItem),
                                      child: Card(
                                        margin: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            // 축제 제목 표시
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                festivalItem['title'],
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                                                textAlign: TextAlign.center, // 텍스트를 가운데 정렬
                                              ),
                                            ),

                                            // 축제 이미지 표시
                                            if (festivalItem['firstimage'] != null && festivalItem['firstimage'].isNotEmpty)
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(20.0), // 둥근 모서리 크기 조정
                                                child: Image.network(
                                                  festivalItem['firstimage'],
                                                  width: double.infinity,
                                                  height: 160,
                                                  fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 채워줍니다.
                                                  alignment: Alignment.topCenter, // 이미지를 위쪽부터 정렬
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )





                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: horizontalMargin), // 두 버튼 사이의 수평 간격 조정
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
                            borderRadius: BorderRadius.circular(20), // 둥근 모서리 유지
                          ),
                          alignment: Alignment.center,
                          width: buttonWidth,
                          height: 230, // 상자의 높이를 충분히 크게 설정
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // '나의 여행' 텍스트를 상단에 추가
                              Padding(
                                padding: const EdgeInsets.all(4.0), // 패딩을 줄여서 간격을 좁힘
                                child: Text(
                                  '나의 여행',
                                  style: TextStyle(
                                    color: Colors.white, // 텍스트 색상
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16, // 텍스트 폰트 크기
                                  ),
                                  textAlign: TextAlign.center, // 텍스트 가운데 정렬
                                ),
                              ),

                              // 'MyPostList'의 글들을 표시할 'ListView'
                              Expanded(
                                child: ListView.separated(
                                  itemCount: 5, // 예시에서 'MyPostList'의 글 수
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () => Get.to(DetailPage(index)), // 글을 누르면 'DetailPage'로 이동
                                      title: Text("제목 $index"), // 예시로 제목 표시
                                      leading: Icon(Icons.image), // 썸네일로 아이콘 표시
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
                calendarStyle: CalendarStyle(
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
            fontSize: 16, // 제목 폰트 사이즈를 줄여줍니다.
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
                height: 430, // 이미지를 더 크게 표시합니다.
                fit: BoxFit.fitHeight, // 이미지가 컨테이너에 맞도록 조정합니다.
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

