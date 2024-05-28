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
  String uid;
  String profileImageUrl;
  String nickname;

  UserModel({required this.uid, required this.profileImageUrl, required this.nickname});
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late UserModel user;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 사용자 정보 초기화
    user = UserModel(
      uid: FirebaseAuth.instance.currentUser!.uid,
      profileImageUrl: '', // 초기 프로필 이미지 경로를 빈 문자열로 설정
      nickname: '', // 초기 닉네임을 빈 문자열로 설정
    );
    // 사용자 정보 불러오기
    _loadUserData();
  }

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
            GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: CircleAvatar(
                backgroundImage: user.profileImageUrl.isEmpty
                    ? Image.asset('assets/images/default_image.png').image
                    : NetworkImage(user.profileImageUrl),
                radius: 50,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('UserData').doc(user.uid).snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return Text(user.nickname, style: const TextStyle(fontSize: 20)); // 에러 발생 시 기본 닉네임 표시
                }
                var data = snapshot.data!.data() as Map<String, dynamic>;
                String nickname = data['nickname'] ?? user.nickname; // 서버에서 받아온 닉네임이 없으면 기본 닉네임 사용
                return Text(nickname, style: const TextStyle(fontSize: 20));
              },
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
              child: const Text('찜한 장소'),
            ),
            ElevatedButton(
              onPressed: () {
                // 수정 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserData()), // 수정 페이지로 이동
                );
              },
              child: const Text('내정보'),
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

      // 파일 크기를 확인하지 않고 바로 이미지 업로드 수행
      _uploadImage(imageFile);
    }
  }

  void _uploadImage(File imageFile) async {
    try {
      // 현재 사용자의 이전 프로필 이미지 URL 가져오기
      String previousImageUrl = user.profileImageUrl;

      // Firebase Storage에 새 이미지 업로드
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$uid/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        // 업로드가 완료되면 새로운 이미지의 URL을 가져옴
        String imageUrl = await storageReference.getDownloadURL();

        // Firestore에 새 이미지 URL 업데이트
        await FirebaseFirestore.instance.collection('UserData').doc(user.uid).update({'profileImageUrl': imageUrl});

        // 이전 프로필 이미지가 있다면 삭제
        if (previousImageUrl.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(previousImageUrl).delete();
        }

        // 프로필 이미지 경로를 업데이트
        setState(() {
          user.profileImageUrl = imageUrl;
        });
      });
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
    }
  }

  // 사용자 정보 불러오기
  void _loadUserData() async {
    try {
      // Firestore에서 해당 사용자의 데이터 가져오기
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('UserData').doc(user.uid).get();
      if (userData.exists) {
        var data = userData.data() as Map<String, dynamic>;
        String profileImageUrl = data['profileImageUrl'] ?? ''; // 프로필 이미지 URL이 없으면 빈 문자열 사용
        String nickname = data['nickname'] ?? ''; // 서버에서 받아온 닉네임이 없으면 빈 문자열 사용
        setState(() {
          // 사용자 정보 업데이트
          user.profileImageUrl = profileImageUrl;
          user.nickname = nickname;
        });
      } else {
        print('해당 사용자의 데이터가 존재하지 않습니다.');
      }
    } catch (e) {
      print('사용자 정보 불러오기 중 오류 발생: $e');
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
