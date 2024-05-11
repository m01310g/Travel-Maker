// my_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase/login_google.dart';
import '../../firebase/user_data.dart';
import 'my_liked_list.dart';
import 'my_post_list.dart';
import 'package:google_sign_in/google_sign_in.dart'; // GoogleSignIn 추가
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 추가
import 'package:travelmaker/firebase/login_google.dart'; // 구글 로그인 페이지 추가

class UserModel {
  String profileImagePath;
  String nickname;

  UserModel({required this.profileImagePath, required this.nickname});
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  UserModel user = UserModel(
    profileImagePath: '', // 초기 프로필 이미지 경로를 빈 값으로 설정
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
              // 로그아웃 기능 실행
              _logout(context);
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
                  backgroundImage: user.profileImagePath.isNotEmpty
                      ? FileImage(File(user.profileImagePath)) as ImageProvider // 파일 이미지일 경우
                      : const AssetImage('assets/images/default_image.png'), // 기본 이미지일 경우
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
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('UserData').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || snapshot.data!.docs.isEmpty) {
                      return Text(user.nickname, style: const TextStyle(fontSize: 20)); // 에러 발생 시 기본 닉네임 표시
                    }
                    var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                    String nickname = data['nickname'] ?? user.nickname; // 서버에서 받아온 닉네임이 없으면 기본 닉네임 사용
                    return Text(nickname, style: const TextStyle(fontSize: 20));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 15),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => UserData()), // UserData 페이지로 이동
                    );
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
              child: const Text('내 일정'),
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
        // 프로필 이미지 경로를 업데이트
        user.profileImagePath = pickedFile.path;
      });
    }
  }

  // 로그아웃 기능
  void _logout(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut(); // Google 계정에서 로그아웃
      // FirebaseAuth에서도 로그아웃 수행
      await FirebaseAuth.instance.signOut();
      // 로그아웃 후 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GoogleLogin()),
      );
      print('로그아웃 성공'); // 로그아웃 성공 메시지 출력
    } catch (e) {
      print('로그아웃 중 오류 발생: $e');
    }
  }
}
