
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmaker/pages/community_page.dart';
import 'package:travelmaker/pages/home_page.dart';
import 'package:travelmaker/pages/post/plan_page.dart';
import 'package:travelmaker/pages/post/my_page.dart';
import 'package:travelmaker/pages/region_info/region_info_page.dart';
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
                children: const [
                  HomePage(),
                  RegionInfoPage(),
                  PlanPage(),
                  CommunityPage(),
                  MyPage(),
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
                    icon: ImageData(IconsPath.regioninfoOff),
                    activeIcon: ImageData(IconsPath.regioninfoOn),
                    label: 'regioninfo',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageData(IconsPath.uploadIcon),
                    label: 'plan',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageData(IconsPath.communityOff),
                    activeIcon: ImageData(IconsPath.communityOn),
                    label: 'community',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageData(IconsPath.mypageOff),
                    activeIcon: ImageData(IconsPath.mypageOn),
                    label: 'mypage',
                  ),
                ],
              ),
            )
        )
    );
  }
}