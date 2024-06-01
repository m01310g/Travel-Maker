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
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.pageIndex.value,
        children: [
          const HomePage(),
          const RegionInfoPage(),
          PlanPage(),
          const CommunityPage(),
          const MyPage(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // 라벨 지우기
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: controller.pageIndex.value,
        elevation: 0,
        onTap: controller.changeBottomNav,
        items: [
          BottomNavigationBarItem(
            icon: controller.pageIndex.value == 0 ? ImageData(IconsPath.homeOn) : ImageData(IconsPath.homeOff),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: controller.pageIndex.value == 1 ? ImageData(IconsPath.regioninfoOn) : ImageData(IconsPath.regioninfoOff),
            label: 'regioninfo',
          ),
          BottomNavigationBarItem(
            icon: ImageData(IconsPath.chatbot_icon),
            label: 'chatbot',
          ),
          BottomNavigationBarItem(
            icon: controller.pageIndex.value == 3 ? ImageData(IconsPath.communityOn) : ImageData(IconsPath.communityOff),
            label: 'community',
          ),
          BottomNavigationBarItem(
            icon: controller.pageIndex.value == 4 ? ImageData(IconsPath.mypageOn) : ImageData(IconsPath.mypageOff),
            label: 'mypage',
          ),
        ],
      )),
    );
  }
}