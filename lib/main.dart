import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travelmaker/src/app.dart';
import 'package:travelmaker/src/controller/bottom_nav_controller.dart'; // BottomNavController import 추가
import '../main.dart'; // 변경된 import

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
      home: const GoogleLogin(), // GoogleLogin을 먼저 호출
    );
  }
}

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  void updateLoginStatus(bool status) {
    isLoggedIn.value = status;
  }
}

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
        Get.find<AuthController>().updateLoginStatus(true); // 변경된 부분
        Get.offAll(const App()); // 로그인 성공 시 HomePage로 이동합니다.
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
