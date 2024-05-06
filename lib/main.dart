import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travelmaker/src/app.dart';
import 'package:travelmaker/src/controller/bottom_nav_controller.dart'; // BottomNavController import 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(BottomNavController()); // BottomNavController 주입
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Obx(() {
        final isLoggedIn = Get.find<AuthController>().isLoggedIn.value;
        if (isLoggedIn) {
          return const App(); // 로그인 성공 시 APP으로 이동합니다.
        } else {
          return const GoogleLogin();
        }
      }),
    );
  }
}

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  void updateLoginStatus(bool status) {
    isLoggedIn.value = status;
  }
}

class GoogleLogin extends StatelessWidget {
  const GoogleLogin({Key? key}) : super(key: key);

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
                Get.find<AuthController>().updateLoginStatus(true);
                Get.offAll(const App()); // 로그인 성공 시 HomePage로 이동합니다.
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('구글 로그인에 실패했습니다.'),
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
