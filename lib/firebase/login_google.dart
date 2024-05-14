import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:travelmaker/src/app.dart';

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({Key? key}) : super(key: key);

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  late final GoogleSignIn _googleSignIn;
  bool _isButtonDisabled = false; // 버튼 활성/비활성 상태 변수

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _isButtonDisabled ? null : () async => await _signInWithGoogleDelayed(),
          child: _isButtonDisabled ? CircularProgressIndicator() : const Text('구글로 로그인'),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogleDelayed() async {
    setState(() {
      _isButtonDisabled = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        print('구글로 로그인 성공: ${userCredential.user!.displayName}');
        Get.offAll(const App()); // 로그인 성공 시 App 페이지로 이동합니다.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('구글 로그인에 실패했습니다.'),
        ));
      }
    } catch (e) {
      print('구글 로그인 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('구글 로그인 중 오류가 발생했습니다.'),
      ));
    } finally {
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }
}
