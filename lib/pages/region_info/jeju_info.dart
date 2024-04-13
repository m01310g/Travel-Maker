import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JejuInfo extends StatefulWidget {
  const JejuInfo({Key? key}) : super(key: key);

  @override
  _JejuInfoState createState() => _JejuInfoState();
}

class _JejuInfoState extends State<JejuInfo> {
  List<String> regionInfo = [];

  @override
  void initState() {
    super.initState();
    fetchRegionInfo();
  }

  Future<void> fetchRegionInfo() async {
    final apiKey =
        'xHIYywSVOCXTorWSMxYoMW92r1or16xp%2FtCpAviub7VzP26w68%2BB22HAnjI%2FR6DFfXvd%2BuTxmHUYabfyeti4sw%3D%3D';
    final url =
        'https://api.odcloud.kr/api/15049995/v1/uddi:f2e87fc5-9d8d-4f22-adfc-ae9993d1bbe5?page=1&perPage=10&serviceKey=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      final items = decodedData['data']; // Access the 'data' field directly
      setState(() {
        regionInfo =
            List<String>.from(items.map((item) => item['장소명'])).toList(); // Use 'item['장소명']' to access place name
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
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
