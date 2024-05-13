import 'package:flutter/material.dart';
import 'package:travelmaker/pages/region_info/incheon_info.dart';
import 'package:travelmaker/pages/region_info/seoul_info.dart';
import 'package:travelmaker/pages/region_info/gyeonggi_info.dart';


class MetroArea extends StatefulWidget {
  const MetroArea({super.key});

  @override
  State<MetroArea> createState() => _MetroAreaState();
}

class _MetroAreaState extends State<MetroArea> {
  String? selectedArea = '서울'; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수도권 지역'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  '지역 선택: ',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedArea,
                    icon: const Icon(Icons.arrow_downward),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedArea = newValue!;
                      });
                    },
                    items: ['서울', '경기', '인천'].map<DropdownMenuItem<String>>((String value) {
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
              child: _buildAreaWidget(selectedArea),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaWidget(String? selectedArea) {
    switch (selectedArea) {
      case '서울':
        return _buildSeoulWidget();
      case '경기':
        return _buildGyeonggiWidget();
      case '인천':
        return _buildIncheonWidget();
      default:
        return const Text('선택된 지역 없음');
    }
  }

  Widget _buildSeoulWidget() {
    // You can customize this widget for Seoul
    return const SeoulInfo();
  }

  Widget _buildGyeonggiWidget() {
    // You can customize this widget for Gyeonggi
    return const GyeonggiInfo();
  }

  Widget _buildIncheonWidget() {
    // You can customize this widget for Incheon
    return const IncheonInfo();
  }
}
