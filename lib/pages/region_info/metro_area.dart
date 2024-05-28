import 'package:flutter/material.dart';
import 'package:travelmaker/pages/region_info/incheon_info.dart';
import 'package:travelmaker/pages/region_info/seoul_info.dart';
import 'package:travelmaker/pages/region_info/gyeonggi_info.dart';

class MetroArea extends StatefulWidget {
  const MetroArea({Key? key}) : super(key: key);

  @override
  State<MetroArea> createState() => _MetroAreaState();
}

class _MetroAreaState extends State<MetroArea> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수도권 정보'),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: const [
          SeoulInfo(),
          GyeonggiInfo(),
          IncheonInfo(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          setState(() {
            _currentPage = index;
            _pageController.jumpToPage(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: '서울 정보',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: '경기 정보',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: '인천 정보',
          ),
        ],
      ),
    );
  }
}
