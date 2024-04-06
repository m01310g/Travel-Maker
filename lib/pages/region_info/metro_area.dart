import 'package:flutter/material.dart';

class MetroArea extends StatefulWidget {
  const MetroArea({super.key});

  @override
  State<MetroArea> createState() => _MetroAreaState();
}

class _MetroAreaState extends State<MetroArea> {
  final List<String> areas = ['서울', '경기', '인천'];
  String? selectedArea = '서울'; // 기본값 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수도권 지역'),
        centerTitle: true, // 타이틀을 중앙에 배치
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '지역 선택: ',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedArea,
                    icon: Icon(Icons.arrow_downward),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedArea = newValue!;
                      });
                    },
                    items: areas.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text('선택된 지역: $selectedArea'),
            ),
          ),
        ],
      ),
    );
  }
}