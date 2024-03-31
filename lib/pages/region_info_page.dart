import 'package:flutter/material.dart';

class RegioninfoPage extends StatelessWidget {
  const RegioninfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('지역 정보'),
      ),
      body: Stack(
        children: <Widget>[
          // 대한민국 지도 이미지
          Positioned.fill(
            child: Image.asset('assets/images/korea_map.jpg',
              fit: BoxFit.contain,
            ),
          ),
          // 각 지역 버튼 배치 예시
          // 서울
          Positioned(
            left: 50, // 실제 위치에 맞게 조정 필요
            top: 100, // 실제 위치에 맞게 조정 필요
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                print('서울 클릭!');
              },
            ),
          ),
          // 부산
          Positioned(
            left: 50, // 실제 위치에 맞게 조정 필요
            top: 200, // 실제 위치에 맞게 조정 필요
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                print('부산 클릭!');
              },
            ),
          ),
          // 추가 지역에 대한 버튼은 여기에 구현...
        ],
      ),
    );
  }
}