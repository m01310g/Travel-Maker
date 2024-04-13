import 'dart:async';
import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class PlanPage extends StatelessWidget {
  final int? testId;

  const PlanPage({super.key, this.testId});

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: testId == null ? const FirstPage() : TestPage(key: Key("testPage_$testId")),
  );
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return true to allow back navigation
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('First Page'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Pop the current route off the navigation stack
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestPage()),
              );
            },
            child: const Text('지도보기'),
          ),
        ),
      ),
    );
  }
}



class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize = Size(mediaQuery.size.width - 32, mediaQuery.size.height - 72);
    final physicalSize = Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    print("physicalSize: $physicalSize");

    return Scaffold(
      backgroundColor: const Color(0xFF343945),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Map'),
      ),
      body: Center(
        child: SizedBox(
          width: mapSize.width,
          height: mapSize.height,
          child: _naverMapSection(),
        ),
      ),
    );
  }

  Widget _naverMapSection() => NaverMap(
    options: const NaverMapViewOptions(
      indoorEnable: true,
      locationButtonEnable: false,
      consumeSymbolTapEvents: false,
    ),
    onMapReady: (controller) async {
      _mapController = controller;
      mapControllerCompleter.complete(controller);
      log("onMapReady", name: "onMapReady");
    },
  );
}
