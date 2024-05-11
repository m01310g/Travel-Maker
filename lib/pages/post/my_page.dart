import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage 추가
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase/login_google.dart';
import '../../firebase/user_data.dart';
import 'my_liked_list.dart';
import 'my_post_list.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      File imageFile = File(pickedFile.path);

      // 이미지의 크기를 확인
      int fileSize = await imageFile.length();
      double fileSizeInKB = fileSize / 1024; // 파일 크기를 KB로 변환

      // 파일 크기가 일정 이상인 경우 경고 표시
      if (fileSizeInKB > 1024) { // 예를 들어, 1024KB(1MB) 이상인 경우
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('이미지 크기가 너무 큽니다'),
              content: Text('사진 크기가 맞지 않을 수 있습니다. 계속해서 업로드 하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _uploadImage(imageFile); // 사용자가 계속해서 업로드를 선택한 경우 이미지 업로드 수행
                  },
                  child: Text('예'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('아니오'),
                ),
              ],
            );
          },
        );
      } else {
        // 파일 크기가 적절한 경우에는 그냥 이미지 업로드 수행
        _uploadImage(imageFile);
      }
    }
  }

  void _uploadImage(File imageFile) async {
    // Firebase Storage에 이미지 업로드
    Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.whenComplete(() async {
      // 업로드가 완료되면 이미지 다운로드 URL을 가져와서 업데이트
      String imageUrl = await storageReference.getDownloadURL();
      setState(() {
        // 프로필 이미지 경로를 업데이트
        user.profileImagePath = imageUrl;
      });
    });
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
