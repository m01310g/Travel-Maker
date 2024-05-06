import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  final double mapx;
  final double mapy;

  const MapPage({super.key, 
    required this.mapx,
    required this.mapy,
  });

  @override
  Widget build(BuildContext context) {
    // 전달받은 위도(mapy)와 경도(mapx)를 사용하여 LatLng 객체 생성
    final LatLng initialPosition = LatLng(mapy, mapx);

    return Scaffold(
      appBar: AppBar(
        title: const Text('지도 보기'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          // 초기 위치를 지정합니다.
          target: initialPosition,
          zoom: 14.0, // 줌 레벨 설정
        ),
        markers: {
          // 전달받은 위치를 표시하는 마커를 추가합니다.
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
