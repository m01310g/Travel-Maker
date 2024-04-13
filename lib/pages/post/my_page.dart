import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'my_liked_list.dart';
import 'my_post_list.dart';

//void main() => runApp(const MaterialApp(home: MyPage()));

class UserModel {
  String profileImageUrl;
  String nickname;

  UserModel({required this.profileImageUrl, required this.nickname});
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  UserModel user = UserModel(
    profileImageUrl: 'https://via.placeholder.com/150',
    nickname: '사용자닉네임',
  );

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 로그아웃 로직 구현
              print('로그아웃');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.profileImageUrl),
                  radius: 50,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 15),
                  onPressed: () {
                    _pickImage();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user.nickname, style: const TextStyle(fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.edit, size: 15,),
                  onPressed: () {
                    _changeNickname();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyPostList()),
                );
              },
              child: const Text('내 여행'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyLikedList()),
                );
              },
              child: const Text('찜한 여행'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        user.profileImageUrl = pickedFile.path;
      });
    }
  }


  void _changeNickname() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? newNickname;
        return AlertDialog(
          title: const Text('닉네임 변경'),
          content: TextField(
            onChanged: (value) {
              newNickname = value;
            },
            decoration: const InputDecoration(hintText: "새 닉네임을 입력하세요"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () {
                if (newNickname != null && newNickname!.isNotEmpty) {
                  setState(() {
                    user.nickname = newNickname!;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
