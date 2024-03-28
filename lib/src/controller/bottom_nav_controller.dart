/*
  하단 내비게이션 바 조작
  upload 버튼 누르면 새로운 페이지로 이동
 */

import 'package:get/get.dart';
import 'package:travelmaker/pages/post/plan_page.dart';

enum PageName{ HOME, REGION_INFO, PLAN, COMMUNITY, MYPAGE }

class BottomNavController extends GetxController {
  RxInt pageIndex = 0.obs;

  void changeBottomNav(int value, {bool hasGesture = true}) {
    var page = PageName.values[value];
    switch (page) {
      case PageName.PLAN:
      // Upload라는 새로운 페이지를 만들어줌 => upload.dart
        Get.to(() => const PlanPage());
        break;
      case PageName.HOME:
      case PageName.REGION_INFO:
      case PageName.COMMUNITY:
      case PageName.MYPAGE:
        _changePage(value, hasGesture: hasGesture);
        break;
    }
  }

  void _changePage(int value, {bool hasGesture = true}) {
    // pageIndex 변경하면 페이지 바뀜
    pageIndex(value);
    //hasGesture == false이면 반환값 없음
    if (!hasGesture) return;
  }
}
