import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../map_page.dart';

class JeonnamInfo extends StatefulWidget {
  const JeonnamInfo({super.key});

  @override
  _JeonnamInfoState createState() => _JeonnamInfoState();
}

class _JeonnamInfoState extends State<JeonnamInfo> {
  List<Map<String, dynamic>> regionInfo = [];
  String selectedCategory = '12'; // 초기 카테고리: 관광지
  String subCategory = ''; // 소분류 카테고리

  @override
  void initState() {
    super.initState();
    fetchRegionInfo(selectedCategory, subCategory);
  }

  Future<void> fetchRegionInfo(String contentTypeId, String subCategory) async {
    final apiKey = dotenv.env['region_apiKey']; // 여기에 API 키를 입력하세요
    String url =
        'http://apis.data.go.kr/B551011/KorService1/areaBasedList1?ServiceKey=$apiKey&areaCode=5&contentTypeId=$contentTypeId&arrange=D&numOfRows=50&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json';

    // 음식점 카테고리의 경우 소분류 카테고리 추가
    if (contentTypeId == '39' && subCategory.isNotEmpty) {
      url += '&cat3=$subCategory';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      try {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        final items = decodedData['response']['body']['items']['item'];

        setState(() {
          regionInfo = List<Map<String, dynamic>>.from(
            items.map((item) => {
              'title': item['title'],
              'address': item['addr1'],
              'image': item['firstimage'],
              'mapx': double.parse(item['mapx'] ?? '0'),
              'mapy': double.parse(item['mapy'] ?? '0'),
              'liked': false,
            }),
          );
        });
      } catch (e) {
        print("데이터 파싱 중 오류 발생: $e");
        setState(() {
          regionInfo = [];
        });
      }
    } else {
      print("API 호출 실패: $response.statusCode");
    }
  }

  void handleCategoryChange(String category, String subCategory) {
    setState(() {
      selectedCategory = category;
      this.subCategory = subCategory;
    });
    fetchRegionInfo(category, subCategory);
  }

  // 좋아요 상태 토글 함수
  void toggleLike(int index) {
    setState(() {
      regionInfo[index]['liked'] = !regionInfo[index]['liked'];
    });
  }

  // 카테고리 버튼을 생성합니다.
  Widget _buildCategoryChips() {
    final categories = [
      {'label': '관광지', 'category': '12', 'subCategory': ''},
      {'label': '문화시설', 'category': '14', 'subCategory': ''},
      {'label': '액티비티', 'category': '28', 'subCategory': ''},
      {'label': '숙박', 'category': '32', 'subCategory': ''},
      {'label': '쇼핑', 'category': '38', 'subCategory': ''},
      {'label': '음식점', 'category': '39', 'subCategory': ''},
      {'label': '카페', 'category': '39', 'subCategory': 'A05020900'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // 좌우 스크롤 가능
      child: Row(
        children: List.generate(categories.length, (index) => _buildCategoryChip(categories[index], index)),
      ),
    );
  }

  // 카테고리 버튼 빌더 함수
  Widget _buildCategoryChip(Map<String, String> categoryData, int index) {
    bool isSelected = selectedCategory == categoryData['category'] && subCategory == categoryData['subCategory'];

    return GestureDetector(
      onTap: () {
        handleCategoryChange(categoryData['category']!, categoryData['subCategory']!);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            // 카테고리 텍스트
            Text(
              categoryData['label']!,
              style: TextStyle(
                fontSize: 18.0, // 글씨 크기 조정
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
            // 선택된 카테고리 아래에 파란색 선을 표시합니다.
            AnimatedContainer(
              duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
              height: isSelected ? 2.0 : 0.0, // 선택된 경우 파란 선 높이
              width: 30.0, // 파란 선 너비
              color: Colors.blue, // 파란 선 색상
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전남 정보'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 카테고리 버튼
          _buildCategoryChips(),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: regionInfo.length,
                itemBuilder: (context, index) {
                  final info = regionInfo[index];
                  return ListTile(
                    leading: info['image'] != null && info['image'].isNotEmpty
                        ? Image.network(
                        info['image'], width: 50, height: 50, fit: BoxFit.cover)
                        : null,
                    title: Text(info['title']),
                    subtitle: Text(info['address']),
                    trailing: IconButton(
                      icon: Icon(
                        info['liked'] ? Icons.favorite : Icons.favorite_border,
                        color: info['liked'] ? Colors.red : null,
                      ),
                      onPressed: () {
                        toggleLike(index);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            title: info['title'],
                            address: info['address'],
                            image: info['image'],
                            mapx: info['mapx'],
                            mapy: info['mapy'],
                            liked: info['liked'],
                            toggleLike: () => toggleLike(index),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final String address;
  final String image;
  final double mapx;
  final double mapy;
  final bool liked;
  final VoidCallback toggleLike;

  const DetailPage({super.key, 
    required this.title,
    required this.address,
    required this.image,
    required this.mapx,
    required this.mapy,
    required this.liked,
    required this.toggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? Colors.red : null,
            ),
            onPressed: toggleLike,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (image.isNotEmpty)
                Image.network(image, width: 200, fit: BoxFit.fill),
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
      ),
    );
  }
}
