import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutePage extends StatefulWidget {
  final double startLatitude;
  final double startLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final List<LatLng> waypoints;
  final List<String> waypointTitles;

  const RoutePage({
    Key? key,
    required this.startLatitude,
    required this.startLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.waypoints,
    required this.waypointTitles,
  }) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    setMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void setMarkers() {
    // Adding start location marker
    markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(widget.startLatitude, widget.startLongitude),
        infoWindow: InfoWindow(
          title: widget.waypointTitles.isNotEmpty ? widget.waypointTitles.first : '출발지',
        ),
      ),
    );

    // Adding destination marker
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.destinationLatitude, widget.destinationLongitude),
        infoWindow: InfoWindow(
          title: widget.waypointTitles.isNotEmpty ? widget.waypointTitles.last : '도착지',
        ),
      ),
    );

    // Adding waypoint markers
    for (int i = 0; i < widget.waypoints.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('waypoint$i'),
          position: widget.waypoints[i],
          infoWindow: InfoWindow(
            title: widget.waypointTitles[i + 1], // Titles for waypoints
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모아보기'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.startLatitude, widget.startLongitude),
          zoom: 14.0,
        ),
        trafficEnabled: true,
        markers: markers,
      ),
    );
  }
}
