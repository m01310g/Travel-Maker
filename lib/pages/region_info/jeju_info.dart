import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class JejuInfo extends StatefulWidget {
  const JejuInfo({super.key});

  @override
  _JejuInfoState createState() => _JejuInfoState();
}

class _JejuInfoState extends State<JejuInfo> {
  List<Map<String, dynamic>> regionInfo = [];

  @override
  void initState() {
    super.initState();
    fetchRegionInfo();
  }

  Future<void> fetchRegionInfo() async {
    final apiKey = dotenv.env['region_apiKey'];
    String url = 'https://api.odcloud.kr/api/15049995/v1/uddi:f2e87fc5-9d8d-4f22-adfc-ae9993d1bbe5?page=5&perPage=20&serviceKey=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      final items = decodedData['data'];
      setState(() {
        regionInfo = List<Map<String, dynamic>>.from(
            items.map((item) => {
              'name': item['장소명'],
              'address': item['도로명주소'],
              'latitude': double.parse(item['위도']),
              'longitude': double.parse(item['경도']),
            })
        );
      });
    } else {
      throw Exception('Failed to load region information');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('제주 정보'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: regionInfo.length,
                itemBuilder: (context, index) {
                  final info = regionInfo[index];
                  return ListTile(
                    title: Text(info['name']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            name: info['name'],
                            address: info['address'],
                            latitude: info['latitude'],
                            longitude: info['longitude'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const DetailPage({super.key, 
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      latitude: latitude,
                      longitude: longitude,
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
            Text('위도: $latitude, 경도: $longitude'),
          ],
        ),
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapPage({super.key, 
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng initialPosition = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('지도 보기'),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 비활성화
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selectedLocation'),
            position: initialPosition,
            infoWindow: const InfoWindow(
              title: '선택한 위치',
            ),
          ),
        },
      ),
    );
  }
}
