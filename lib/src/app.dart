
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmaker/pages/community_page.dart';
import 'package:travelmaker/pages/home_page.dart';
import 'package:travelmaker/src/components/image_data.dart';
import 'package:travelmaker/src/controller/bottom_nav_controller.dart';

class App extends GetView<BottomNavController> {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        child: Obx(() =>
            Scaffold(
              // appBar: AppBar(),
              body: IndexedStack(
                index: controller.pageIndex.value,
                children: [
                  const HomePage(),
                  Container(child: const Center(child: Text('SEARCH'),),),
                  Container(child: const Center(child: Text('UPLOAD'),),),
                  const CommunityPage(),
                  Container(child: const Center(child: Text('MYPAGE'),),),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                // 라벨 지우기
                showSelectedLabels: false,
                showUnselectedLabels: false,
                currentIndex: controller.pageIndex.value,
                elevation: 0,
                onTap: controller.changeBottomNav,
                items: [
                  BottomNavigationBarItem(
                    icon: ImageData(IconsPath.homeOff),
                    activeIcon: ImageData(IconsPath.homeOn),
                    label: 'home',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageData(IconsPath.searchOff),
                    activeIcon: ImageData(IconsPath.searchOn),
                    label: 'search',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageData(IconsPath.uploadIcon),
                    label: 'upload',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageData(IconsPath.activeOff),
                    activeIcon: ImageData(IconsPath.activeOn),
                    label: 'active',
                  ),
                  BottomNavigationBarItem(
                      icon: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),
                    label: 'mypage'
                  )
                ],
              ),
            )
        )
    );
  }
}