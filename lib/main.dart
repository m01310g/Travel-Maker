import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<AuthController>(
      init: AuthController(),
      builder: (controller) {
        if (controller.isLoggedIn.value) {
          return const HomePage(); // 로그인되어 있으면 홈 페이지로 이동
        } else {
          return const GoogleLoginPage(); // 로그인되어 있지 않으면 로그인 페이지로 이동
        }
      },
    );
  }
}

class AuthController extends GetxController {
  // 로그인 상태를 관리하는 변수
  var isLoggedIn = false.obs;

  // 로그인 상태를 갱신하는 메서드
  void updateLoginStatus(bool status) {
    isLoggedIn.value = status;
  }
}

class GoogleLoginPage extends StatelessWidget {
  const GoogleLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google 로그인'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 구글 로그인 진행
            signInWithGoogle().then((success) {
              if (success) {
                // 로그인 성공 시 AuthController를 통해 로그인 상태 갱신
                Get.find<AuthController>().updateLoginStatus(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Google 로그인에 실패했습니다.'),
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
        print('Successfully signed in with Google');
        return true;
      } else {
        print('User canceled the sign-in process.');
        return false;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return false;
    }
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: const Text('Welcome to Home Page!'),
      ),
    );
  }
}
