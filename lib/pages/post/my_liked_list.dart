import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'detail_page2.dart';

class MyLikedList extends StatelessWidget {
  const MyLikedList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("찜한 여행"),
      ),
      body: ListView.separated(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Get.to(DetailPage2(index));
            },
            title: const Text("제목"),
            leading: const Text("1"),
          );
        }, separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
      ),
    );
  }
}