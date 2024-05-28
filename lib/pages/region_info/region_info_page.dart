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

class RegionInfoPage extends StatefulWidget {
  const RegionInfoPage({super.key});

  @override
  _RegionInfoPageState createState() => _RegionInfoPageState();
}

class _RegionInfoPageState extends State<RegionInfoPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 10).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              aspectRatio: 9 / 14.5, // 원하는 비율로 조정하세요.
              child: Image.asset(
                'assets/images/korea_map2.jpg',
                fit: BoxFit.fitWidth, // 화면에 맞게 이미지를 채웁니다.
              ),
            ),
          ),
          _buildAnimatedMarker(
            left: screenSize.width * 0.3,
            top: screenSize.height * 0.2,
            label: '수도권',
            onTap: () => Get.to(const MetroArea()),
          ),
          _buildAnimatedMarker(
            right: screenSize.width * 0.32,
            top: screenSize.height * 0.17,
            label: '강원도',
            onTap: () => Get.to(const GangwonInfo()),
          ),
          _buildAnimatedMarker(
            left: screenSize.width * 0.43,
            top: screenSize.height * 0.28,
            label: '충청북도',
            onTap: () => Get.to(const ChungbukInfo()),
          ),
          _buildAnimatedMarker(
            left: screenSize.width * 0.26,
            top: screenSize.height * 0.32,
            label: '충청남도',
            onTap: () => Get.to(const ChungnamInfo()),
          ),
          _buildAnimatedMarker(
            left: screenSize.width * 0.30,
            top: screenSize.height * 0.41,
            label: '전라북도',
            onTap: () => Get.to(const JeonbukInfo()),
          ),
          _buildAnimatedMarker(
            left: screenSize.width * 0.25,
            top: screenSize.height * 0.515,
            label: '전라남도',
            onTap: () => Get.to(const JeonnamInfo()),
          ),
          _buildAnimatedMarker(
            right: screenSize.width * 0.23,
            top: screenSize.height * 0.33,
            label: '경상북도',
            onTap: () => Get.to(const GyeongbukInfo()),
          ),
          _buildAnimatedMarker(
            right: screenSize.width * 0.3,
            top: screenSize.height * 0.46,
            label: '경상남도',
            onTap: () => Get.to(const GyeongnamInfo()),
          ),
          _buildAnimatedMarker(
            left: screenSize.width * 0.2,
            bottom: screenSize.height * 0.125,
            label: '제주도',
            onTap: () => Get.to(const JejuInfo()),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMarker({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required String label,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation.value),
                child: IconButton(
                  icon: const Icon(Icons.location_pin),
                  onPressed: onTap,
                ),
              );
            },
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
