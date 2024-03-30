import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmaker/pages/post/my_post_list.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width / 6;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("마이페이지"),
        ),
        body: Column(
          children: [
            Align(
              alignment: const Alignment(-0.95, -0.5),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.width / 6,
                  minWidth: MediaQuery.of(context).size.width / 6,
                ),
                child: GestureDetector(
                  onTap: () {
                    showBottomSheet();
                  },
                  child: Icon(
                    Icons.account_circle,
                    size: imageSize,
                  ),
                ),
              ),
            ),
            Expanded(
                child: ListView.separated(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Get.to(const MyPostList());
                      },
                      title: const Text("나의 일정"),
                    );
                  },
                  separatorBuilder: (BuildContext context,
                      int index) => const Divider(),
                )
            )
          ],
        ),
      ),
    );
  }

  // 프로필 클릭시 하단에서 사진찍기/라이브러리에서 불러오기 창 출력
  showBottomSheet() {
    return showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: const Text("사진 찍기")
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(
                thickness: 3,
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: const Text("라이브러리에서 불러오기")
              ),
              const SizedBox(
                height: 20,
              )
            ],
          );
        }
    );
  }
}
