import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final String defaultImageUrl = 'assets/images/default_image.png';
  bool isImageChanged = false;

  @override
  void initState() {
    super.initState();
    user = UserModel(
      uid: FirebaseAuth.instance.currentUser!.uid,
      profileImageUrl: defaultImageUrl,
      nickname: '',
    );
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
                backgroundImage: user.profileImageUrl == defaultImageUrl
                    ? Image.asset(defaultImageUrl).image
                    : NetworkImage(user.profileImageUrl) as ImageProvider,
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
                  return Text(user.nickname, style: const TextStyle(fontSize: 20));
                }
                var data = snapshot.data!.data() as Map<String, dynamic>;
                String nickname = data['nickname'] ?? user.nickname;
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserData()),
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
      await _uploadImage(imageFile);
      setState(() {
        isImageChanged = true;
      });
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String previousImageUrl = user.profileImageUrl;
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$uid/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        String imageUrl = await storageReference.getDownloadURL();
        await FirebaseFirestore.instance.collection('UserData').doc(user.uid).update({'profileImageUrl': imageUrl});
        if (previousImageUrl.isNotEmpty && previousImageUrl != defaultImageUrl) {
          await FirebaseStorage.instance.refFromURL(previousImageUrl).delete();
        }
        setState(() {
          user.profileImageUrl = imageUrl;
        });
      });
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
    }
  }

  void _loadUserData() async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('UserData').doc(user.uid).get();
      if (userData.exists) {
        var data = userData.data() as Map<String, dynamic>;
        String profileImageUrl = data['profileImageUrl'] ?? defaultImageUrl;
        String nickname = data['nickname'] ?? '';
        setState(() {
          user.profileImageUrl = profileImageUrl.isNotEmpty ? profileImageUrl : defaultImageUrl;
          user.nickname = nickname;
        });
      } else {
        print('해당 사용자의 데이터가 존재하지 않습니다.');
      }
    } catch (e) {
      print('사용자 정보 불러오기 중 오류 발생: $e');
    }
  }

  void _logout(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GoogleLogin()),
      );
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 중 오류 발생: $e');
    }
  }
}
