import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmaker/pages/user/join_page.dart';
import 'package:travelmaker/src/app.dart';
import 'package:travelmaker/src/binding/init_binding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // controller를 instance로 설정
      initialBinding: InitBinding(),
      home: App(),
    );
  }
}
