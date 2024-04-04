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

class RegioninfoPage extends StatelessWidget {
  const RegioninfoPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('지역 정보'),
      ),
      body: Stack(
        children: <Widget>[
          // 대한민국 지도 이미지
          Positioned.fill(
            child: Image.asset('assets/images/korea_map2.jpg',
              fit: BoxFit.contain,
            ),
          ),
          // 수도권
          Positioned(
            left: 115, // 실제 위치에 맞게 조정
            top: 125, // 실제 위치에 맞게 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const MetroArea());
              },
            ),
          ),
          // 수도권 이름
            const Positioned(
              left: 115, // 실제 위치에 맞게 조정
              top: 155, // 실제 위치에 맞게 조정
              child: Text(
                '수도권',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          // 강원도
          Positioned(
            right: 120, // 실제 위치에 맞게 조정
            top: 110, // 실제 위치에 맞게 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const GangwonInfo());
              },
            ),
          ),
          // 강원도 이름
          const Positioned(
            right: 120, // 실제 위치에 맞게 조정
            top: 140, // 실제 위치에 맞게 조정
            child: Text(
              '강원도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 충청북도
          Positioned(
            left: 170, // 실제 위치에 맞게 조정
            top: 200, // 실제 위치에 맞게 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const ChungbukInfo());
              },
            ),
          ),
          // 충청북도 이름
          const Positioned(
            right: 165, // 실제 위치에 맞게 조정
            top: 235, // 실제 위치에 맞게 조정
            child: Text(
              '충청북도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 충청남도
          Positioned(
            left: 105, // 실제 위치에 맞게 조정
            top: 210, // 실제 위치에 맞게 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const ChungnamInfo());
              },
            ),
          ),
          // 충청남도 이름
          const Positioned(
            left: 90, // 실제 위치에 맞게 조정
            top: 245, // 실제 위치에 맞게 조정
            child: Text(
              '충청남도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 전라북도
          Positioned(
            left: 115, // 실제 위치에 맞게 조정
            top: 300, // 실제 위치에 맞게 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const JeonbukInfo());
              },
            ),
          ),
          // 전라북도 이름
          const Positioned(
            left: 105, // 실제 위치에 맞게 조정
            top: 335, // 실제 위치에 맞게 조정
            child: Text(
              '전라북도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 전라남도
          Positioned(
            left: 97, // 실제 위치에 맞게 조정
            top: 380, // 실제 위치에 맞게 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const JeonnamInfo());
              },
            ),
          ),
          // 전라남도 이름
          const Positioned(
            left: 90, // 실제 위치에 맞게 조정
            top: 415, // 실제 위치에 맞게 조정
            child: Text(
              '전라남도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 경상북도
          Positioned(
            right: 90, // 실제 위치에 맞게 조정
            top: 230, // 실제 위치에 맞게 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const GyeongbukInfo());
              },
            ),
          ),
          // 경상북도 이름
          const Positioned(
            right: 80, // 실제 위치에 맞게 조정
            top: 265, // 실제 위치에 맞게 조정
            child: Text(
              '경상북도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 경상남도
          Positioned(
            right: 115, // 실제 위치에 맞게 조정
            top: 345, // 실제 위치에 맞게 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const GyeongnamInfo());
              },
            ),
          ),
          // 경상남도 이름
          const Positioned(
            right: 105, // 실제 위치에 맞게 조정
            top: 380, // 실제 위치에 맞게 조정
            child: Text(
              '경상남도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 제주도
          Positioned(
            left: 77, // 실제 위치에 맞게 조정
            bottom: 80, // 실제 위치에 맞게 조정
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                Get.to(const JejeInfo());
              },
            ),
          ),
          // 제주도 이름
          const Positioned(
            left: 75, // 실제 위치에 맞게 조정
            bottom: 70, // 실제 위치에 맞게 조정
            child: Text(
              '제주도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}


