import 'package:flutter/material.dart';

class DetailPage2 extends StatelessWidget {

  final int id;

  const DetailPage2(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "글 제목",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35
                ),
              ),
              const Divider(),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     ElevatedButton(
              //         onPressed: () {
              //           Get.to(() => const UpdatePage());
              //         },
              //         child: const Text("수정")),
              //     const SizedBox(width: 10,),
              //     ElevatedButton(
              //         onPressed: () {
              //           Get.off(() => const App());  // 상태관리로 갱신 가능
              //         },
              //         child: const Text("삭제")),
              //   ],
              // ),
              Expanded(
                child: SingleChildScrollView(
                  child: Text("글 내용" * 500),
                ),
              )
            ],
          ),
        )
    );
  }
}