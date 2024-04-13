import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmaker/pages/region_info/chungbuk_info.dart';
import 'package:travelmaker/pages/region_info/chungnam_info.dart';
import 'package:travelmaker/pages/region_info/gangwon_info.dart';
import 'package:travelmaker/pages/region_info/gyeongbuk_info.dart';
import 'package:travelmaker/pages/region_info/gyeongnam_info.dart';
import 'package:travelmaker/pages/region_info/jeju_info.dart';
import 'package:travelmaker/pages/region_info/jeonbuk_info.dart';
import 'package:travelmaker/pages/region_info/jeonnam_info.dart';
import 'package:travelmaker/pages/region_info/metro_area.dart';

class RegionInfoPage extends StatelessWidget {
  const RegionInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 화면 크기를 얻기 위한 MediaQuery
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('지역 정보'),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: 9 / 14.5, // 여기서 원하는 비율로 조정하세요.
              child: Image.asset(
                'assets/images/korea_map2.jpg',
                fit: BoxFit.fitWidth, // 화면에 맞게 이미지를 채웁니다.
              ),
            ),
          ),
          // 아이콘과 텍스트 배치는 이전 예제와 동일하게 유지합니다.
          Positioned(
            left: screenSize.width * 0.3,
            top: screenSize.height * 0.2,
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const MetroArea());
              },
            ),
          ),
          // 수도권 위치 동적 조정
          Positioned(
            left: screenSize.width * 0.3, // 화면 너비의 30% 위치
            top: screenSize.height * 0.2, // 화면 높이의 20% 위치
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const MetroArea());
              },
            ),
          ),
          Positioned(
            left: screenSize.width * 0.3, // 화면 너비의 30% 위치
            top: screenSize.height * 0.24, // 화면 높이의 25% 위치
            child: const Text(
              '수도권',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 강원도 위치 동적 조정
          Positioned(
            right: screenSize.width * 0.32, // 화면 너비에 비례하여 조정
            top: screenSize.height * 0.17, // 화면 높이에 비례하여 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const GangwonInfo());
              },
            ),
          ),
          Positioned(
            right: screenSize.width * 0.32, // 동일한 비율로 이름 위치 조정
            top: screenSize.height * 0.21, // 위치 살짝 조정
            child: const Text(
              '강원도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 충청북도 위치 동적 조정
          Positioned(
            left: screenSize.width * 0.43, // 화면 너비에 비례하여 조정
            top: screenSize.height * 0.28, // 화면 높이에 비례하여 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const ChungbukInfo());
              },
            ),
          ),
          Positioned(
            left: screenSize.width * 0.4, // 동일한 비율로 이름 위치 조정
            top: screenSize.height * 0.32, // 위치 살짝 조정
            child: const Text(
              '충청북도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 충청남도 위치 동적 조정
          Positioned(
            left: screenSize.width * 0.26, // 화면 너비에 비례하여 조정
            top: screenSize.height * 0.32, // 화면 높이에 비례하여 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const ChungnamInfo());
              },
            ),
          ),
          Positioned(
            left: screenSize.width * 0.25, // 동일한 비율로 이름 위치 조정
            top: screenSize.height * 0.36, // 위치 살짝 조정
            child: const Text(
              '충청남도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 전라북도 위치 동적 조정
          Positioned(
            left: MediaQuery.of(context).size.width * 0.30, // 화면 너비에 비례하여 조정
            top: MediaQuery.of(context).size.height * 0.41, // 화면 높이에 비례하여 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const JeonbukInfo());
              },
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.28, // 동일한 비율로 이름 위치 조정
            top: MediaQuery.of(context).size.height * 0.45, // 위치 살짝 조정
            child: const Text(
              '전라북도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // 전라남도 위치 동적 조정
          Positioned(
            left: MediaQuery.of(context).size.width * 0.25, // 화면 너비에 비례하여 조정
            top: MediaQuery.of(context).size.height * 0.515, // 화면 높이에 비례하여 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const JeonnamInfo());
              },
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.24, // 동일한 비율로 이름 위치 조정
            top: MediaQuery.of(context).size.height * 0.55, // 위치 살짝 조정
            child: const Text(
              '전라남도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 경상북도 위치 동적 조정
          Positioned(
            right: MediaQuery.of(context).size.width * 0.23, // 화면 너비에 비례하여 조정
            top: MediaQuery.of(context).size.height * 0.33, // 화면 높이에 비례하여 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const GyeongbukInfo());
              },
            ),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.21, // 동일한 비율로 이름 위치 조정
            top: MediaQuery.of(context).size.height * 0.37, // 위치 살짝 조정
            child: const Text(
              '경상북도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 경상남도 위치 동적 조정
          Positioned(
            right: MediaQuery.of(context).size.width * 0.3, // 화면 너비에 비례하여 조정
            top: MediaQuery.of(context).size.height * 0.46, // 화면 높이에 비례하여 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const GyeongnamInfo());
              },
            ),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.28, // 동일한 비율로 이름 위치 조정
            top: MediaQuery.of(context).size.height * 0.50, // 위치 살짝 조정
            child: const Text(
              '경상남도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 제주도 아이콘 위치 동적 조정
          Positioned(
            left: MediaQuery.of(context).size.width * 0.2, // 화면 너비에 비례하여 조정
            bottom: MediaQuery.of(context).size.height * 0.125, // 화면 높이의 바닥에서부터의 비율로 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const JejuInfo());
              },
            ),
          ),
          // 제주도 이름 위치 동적 조정
          Positioned(
            left: MediaQuery.of(context).size.width * 0.2, // 화면 너비에 비례하여 조정
            bottom: MediaQuery.of(context).size.height * 0.117, // 아이콘보다 조금 더 위에 위치
            child: const Text(
              '제주도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}


