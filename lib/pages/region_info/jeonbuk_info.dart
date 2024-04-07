import 'package:flutter/material.dart';

class JeonbukInfo extends StatelessWidget {
  const JeonbukInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold를 사용하여 기본적인 레이아웃을 제공합니다.
    // AppBar와 같은 다른 위젯들을 추가하여 확장할 수 있습니다.
    return Scaffold(
      // AppBar를 추가하여 상단에 제목을 표시할 수 있습니다.
      appBar: AppBar(
        title: const Text('전북 정보'),
      ),
      // 본문에 Placeholder를 배치합니다.
      body: const Center(
        // Placeholder를 Center 위젯으로 감싸줌으로써 화면 중앙에 위치시킵니다.
        child: Placeholder(),
      ),
    );
  }
}