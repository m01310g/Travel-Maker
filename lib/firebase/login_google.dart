import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

import '../main.dart';

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({Key? key}) : super(key: key);

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            signInWithGoogle().then((success) {
              if (success) {
                // 로그인 성공 시 AuthController를 통해 로그인 상태 갱신
                Get.find<AuthController>().updateLoginStatus(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Google 로그인에 실패했습니다. 사용자가 로그인 프로세스를 취소했을 수 있습니다.'),
                ));
              }
            });
          },
          child: const Text('구글로 로그인'),
        ),
      ),
    );
  }

  Future<bool> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        print('구글로 로그인 성공');
        return true;
      } else {
        print('사용자가 로그인 프로세스를 취소했습니다.');
        return false;
      }
    } catch (e) {
      print('구글 로그인 중 오류 발생: $e');
      return false;
    }
  }
}
