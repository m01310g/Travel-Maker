import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChungbukInfo extends StatefulWidget {
  const ChungbukInfo({super.key});

  @override
  _ChungbukInfoState createState() => _ChungbukInfoState();
}

class _ChungbukInfoState extends State<ChungbukInfo> {
  List<String> regionInfo = [];

  @override
  void initState() {
    super.initState();
    fetchRegionInfo();
  }

  Future<void> fetchRegionInfo() async {
    const apiKey =
        'xHIYywSVOCXTorWSMxYoMW92r1or16xp%2FtCpAviub7VzP26w68%2BB22HAnjI%2FR6DFfXvd%2BuTxmHUYabfyeti4sw%3D%3D';
    const url =
        'http://apis.data.go.kr/B551011/KorService1/areaBasedList1?ServiceKey=$apiKey&areaCode=8&arrange=D&numOfRows=20&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      final items = decodedData['response']['body']['items']['item'];
      setState(() {
        regionInfo =
            List<String>.from(items.map((item) => item['title'])).toList();
      });
    } else {
      throw Exception('Failed to load region information');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('충북 정보'),
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
                  return ListTile(
                    title: Text(regionInfo[index]),
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
