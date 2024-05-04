import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GyeongnamInfo extends StatefulWidget {
  const GyeongnamInfo({Key? key}) : super(key: key);

  @override
  _GyeongnamInfoState createState() => _GyeongnamInfoState();
}

class _GyeongnamInfoState extends State<GyeongnamInfo> {
  List<Map<String, dynamic>> mixedInfo = [];

  @override
  void initState() {
    super.initState();
    fetchRegionInfo('6', '부산'); // 부산 지역 정보 가져오기
    fetchRegionInfo('7', '울산'); // 울산 지역 정보 가져오기
  }

  Future<void> fetchRegionInfo(String areaCode, String regionName) async {
    final apiKey =
        '***REMOVED***';
    final url =
        'http://apis.data.go.kr/B551011/KorService1/areaBasedList1?ServiceKey=$apiKey&areaCode=$areaCode&arrange=D&numOfRows=10&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        print("API 응답 데이터 구조: $decodedData"); // 응답 데이터 구조 디버그 출력
        final items = decodedData['response']['body']['items']['item'];

        // 데이터 파싱 및 결합
        final infoList = items.map((item) => {
          'title': item['title'],
          'address': item['addr1'],
          'mapx': double.parse(item['mapx'] ?? '0'),
          'mapy': double.parse(item['mapy'] ?? '0'),
        }).toList();

        // 부산과 울산 데이터 결합 및 셔플
        setState(() {
          mixedInfo.addAll(infoList);
          mixedInfo.shuffle(); // 데이터 섞기
        });
      } else {
        print("API 호출 실패: $response.statusCode"); // 에러 코드 출력
        throw Exception('Failed to load $regionName region information');
      }
    } catch (e) {
      print("API 호출 오류: $e"); // 에러 메시지 출력
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('경남 정보'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mixedInfo.length,
            itemBuilder: (context, index) {
              final info = mixedInfo[index];
              return ListTile(
                title: Text(info['title']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        title: info['title'],
                        address: info['address'],
                        mapx: info['mapx'],
                        mapy: info['mapy'],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final String address;
  final double mapx;
  final double mapy;

  const DetailPage({
    required this.title,
    required this.address,
    required this.mapx,
    required this.mapy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '상세 주소:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(address),
            SizedBox(height: 10),
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
              child: Text('구글 맵에서 보기'),
            ),
            SizedBox(height: 10),
            Text(
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

class MapPage extends StatelessWidget {
  final double mapx;
  final double mapy;

  const MapPage({
    required this.mapx,
    required this.mapy,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng initialPosition = LatLng(mapy, mapx);

    return Scaffold(
      appBar: AppBar(
        title: const Text('지도 보기'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: initialPosition,
            infoWindow: InfoWindow(
              title: '선택한 위치',
            ),
          ),
        },
      ),
    );
  }
}
