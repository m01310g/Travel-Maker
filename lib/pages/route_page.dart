import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RoutePage extends StatefulWidget {
  final double startLatitude;
  final double startLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final List<LatLng> waypoints; // 경유지 목록
  final List<String> waypointTitles; // 각 경유지의 제목

  const RoutePage({
    Key? key,
    required this.startLatitude,
    required this.startLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.waypoints = const [],
    this.waypointTitles = const [],
  }) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routeCoords = [];
  int _totalDistance = 0;
  int _totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    String clientId = 'wt2u9jddwf'; // Replace with your Naver API client ID
    String clientSecret = 'VUbmGdbC3DnLPTzubYnTk8eITyO3YALMYWb5PQJC'; // Replace with your Naver API client secret

    String start = '${widget.startLongitude},${widget.startLatitude}';
    String goal = '${widget.destinationLongitude},${widget.destinationLatitude}';
    String option = 'trafast'; // Option for the fastest route considering traffic

    // 경유지 추가
    String waypointStr = widget.waypoints.map((waypoint) => '${waypoint.longitude},${waypoint.latitude}').join('|');

    String url = 'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving'
        '?start=$start&goal=$goal&waypoints=$waypointStr&option=$option';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': clientId,
        'X-NCP-APIGW-API-KEY': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['route']['trafast'].isNotEmpty) {
        var route = data['route']['trafast'][0];
        var path = route['path'];
        _routeCoords = path.map<LatLng>((p) => LatLng(p[1], p[0])).toList();
        _totalDistance = route['summary']['distance'];
        _totalDuration = route['summary']['duration'];
        setState(() {
          _addMarkers();
          _addPolyline();
        });
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  void _addMarkers() {
    // 출발지 마커 (녹색)
    _markers.add(
      Marker(
        markerId: MarkerId('start'),
        position: LatLng(widget.startLatitude, widget.startLongitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.waypointTitles[0]),
      ),
    );

    // 도착지 마커 (빨간색)
    _markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: LatLng(widget.destinationLatitude, widget.destinationLongitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: widget.waypointTitles[1]),
      ),
    );

    // 경유지 마커 (기본)
    for (int i = 2; i < widget.waypoints.length + 2; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('waypoint_$i'),
          position: widget.waypoints[i - 2],
          infoWindow: InfoWindow(title: widget.waypointTitles[i]),
        ),
      );
    }
  }


  void _addPolyline() {
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        points: _routeCoords,
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours}시간 ${minutes}분';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('경로'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.startLatitude, widget.startLongitude),
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              trafficEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('총 거리: ${(_totalDistance / 1000).toStringAsFixed(2)} km'),
                //Text('예상 소요 시간 (자동차 기준): ${_formatDuration(_totalDuration)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
