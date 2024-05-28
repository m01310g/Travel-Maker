import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  final List<Map<String, dynamic>> locations;

  const MapPage({
    Key? key,
    required this.locations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지도 보기'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _calculateCenter(),
          zoom: 14.0,
        ),
        markers: _buildMarkers(),
      ),
    );
  }

  LatLng _calculateCenter() {
    // 모든 위치의 평균 위도와 경도를 계산하여 지도의 중심으로 설정합니다.
    double totalLatitude = 0.0;
    double totalLongitude = 0.0;
    for (var location in locations) {
      totalLatitude += location['mapy'];
      totalLongitude += location['mapx'];
    }
    return LatLng(totalLatitude / locations.length, totalLongitude / locations.length);
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    for (var location in locations) {
      LatLng position = LatLng(location['mapy'], location['mapx']);
      markers.add(
        Marker(
          markerId: MarkerId('${position.latitude}-${position.longitude}'),
          position: position,
          infoWindow: InfoWindow(
            title: location['title'] ?? 'No Title',
          ),
        ),
      );
    }
    return markers;
  }
}
