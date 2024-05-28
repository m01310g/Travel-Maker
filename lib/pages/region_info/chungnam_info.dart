import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChungnamInfo extends StatefulWidget {
  const ChungnamInfo({Key? key}) : super(key: key);

  @override
  _ChungnamInfoState createState() => _ChungnamInfoState();
}

class _ChungnamInfoState extends State<ChungnamInfo> {
  List<Map<String, dynamic>> regionInfo = [];
  String selectedCategory = '12'; // 초기 카테고리: 관광지
  String subCategory = ''; // 소분류 카테고리
  Set<String> likedItems = {}; // Firestore에서 가져온 좋아요한 항목 ID 집합

  @override
  void initState() {
    super.initState();
    fetchLikedItems(); // Firestore에서 좋아요한 항목 가져오기
    fetchRegionInfo(selectedCategory, subCategory);
  }

  Future<void> fetchLikedItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('UserData').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          likedItems = Set<String>.from(userDoc['likedItems'].map((item) => item['itemId']) ?? []);
        });
      }
    }
  }

  Future<void> fetchRegionInfo(String contentTypeId, String subCategory) async {
    const apiKey = 'xHIYywSVOCXTorWSMxYoMW92r1or16xp%2FtCpAviub7VzP26w68%2BB22HAnjI%2FR6DFfXvd%2BuTxmHUYabfyeti4sw%3D%3D';
    List<String> areaCodes = ['34', '3']; // 전남과 광주 지역 코드

    List<Map<String, dynamic>> fetchedInfo = [];

    for (String areaCode in areaCodes) {
      String url =
          'http://apis.data.go.kr/B551011/KorService1/areaBasedList1?ServiceKey=$apiKey&areaCode=$areaCode&contentTypeId=$contentTypeId&arrange=D&numOfRows=200&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json';

      if (contentTypeId == '39' && subCategory.isNotEmpty) {
        url += '&cat3=$subCategory';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        try {
          final decodedData = json.decode(utf8.decode(response.bodyBytes));
          final items = decodedData['response']['body']['items']['item'];

          fetchedInfo.addAll(
            List<Map<String, dynamic>>.from(
              items.map((item) => {
                'id': item['contentid'],
                'title': item['title'],
                'address': item['addr1'],
                'image': item['firstimage'],
                'mapx': double.parse(item['mapx'] ?? '0'),
                'mapy': double.parse(item['mapy'] ?? '0'),
                'liked': likedItems.contains(item['contentid']),
              }),
            ),
          );
        } catch (e) {
          print("데이터 파싱 중 오류 발생: $e");
        }
      } else {
        print("API 호출 실패: ${response.statusCode}");
      }
    }

    setState(() {
      regionInfo = fetchedInfo;
      regionInfo.shuffle(); // 데이터 섞기
    });
  }

  void handleCategoryChange(String category, String subCategory) {
    setState(() {
      selectedCategory = category;
      this.subCategory = subCategory;
    });
    fetchRegionInfo(category, subCategory);
  }

  void addLikedPlace(String placeId, String title, String address, String image, double mapx, double mapy) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDoc = FirebaseFirestore.instance.collection('UserData').doc(uid);
    await userDoc.update({
      'likedItems': FieldValue.arrayUnion([
        {
          'itemId': placeId,
          'title': title,
          'address': address,
          'image': image,
          'mapx': mapx,
          'mapy': mapy,
        },
      ]),
    });
    setState(() {
      likedItems.add(placeId);
    });
  }

  void removeLikedPlace(String placeId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDoc = FirebaseFirestore.instance.collection('UserData').doc(uid);

    // Retrieve the current liked items
    DocumentSnapshot snapshot = await userDoc.get();
    List<dynamic> currentLikedItems = snapshot['likedItems'];

    // Find the item to remove
    Map<String, dynamic>? itemToRemove = currentLikedItems.firstWhere(
          (item) => item['itemId'] == placeId,
      orElse: () => null,
    );

    if (itemToRemove != null) {
      await userDoc.update({
        'likedItems': FieldValue.arrayRemove([itemToRemove]),
      });
      setState(() {
        likedItems.remove(placeId);
      });
    }
  }

  void toggleLike(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // 사용자가 로그인하지 않은 경우 처리
    final item = regionInfo[index];
    final itemId = item['id'];
    setState(() {
      item['liked'] = !item['liked'];
    });

    if (item['liked']) {
      addLikedPlace(itemId, item['title'], item['address'], item['image'], item['mapx'], item['mapy']); // Firestore에 추가
    } else {
      removeLikedPlace(itemId); // Firestore에서 제거
    }
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
        title: const Text('충남 정보'),
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
                      info['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.image, size: 50), // 이미지가 없을 때 기본 이미지로 대체
                    title: Text(info['title']),
                    subtitle: Text(info['address']),
                    trailing: IconButton(
                      icon: Icon(
                        info['liked'] ? Icons.favorite : Icons.favorite_border,
                        color: info['liked'] ? Colors.red : null,
                      ),
                      onPressed: () => toggleLike(index),
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

  const DetailPage({
    Key? key,
    required this.title,
    required this.address,
    required this.image,
    required this.mapx,
    required this.mapy,
    required this.liked,
    required this.toggleLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null && image.isNotEmpty)
              Image.network(
                image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16.0),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              address,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
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
              icon: Icon(Icons.map),
              label: Text('구글 맵에서 보기'),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? Colors.red : null,
                size: 30,
              ),
              onPressed: toggleLike,
            ),
          ],
        ),
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  final double mapx;
  final double mapy;

  const MapPage({Key? key, required this.mapx, required this.mapy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도 보기'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(mapy, mapx),
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: MarkerId('location'),
            position: LatLng(mapy, mapx),
          ),
        },
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '충남 정보',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const ChungnamInfo(),
    );
  }
}
