import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmaker/pages/post/detail_page.dart';

class MyPostList extends StatelessWidget {
  const MyPostList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 여행"),
      ),
      body: ListView.separated(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Get.to(DetailPage(index));
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