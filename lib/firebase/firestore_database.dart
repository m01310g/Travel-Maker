import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../pages/post/my_page.dart';
import 'user_data.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 추가

class FirestoreDatabase extends StatefulWidget {
  const FirestoreDatabase({Key? key}) : super(key: key);

  @override
  State<FirestoreDatabase> createState() => _FirestoreDatabaseState();
}

final nameController = TextEditingController();
final nicknameController = TextEditingController();
final birthDateController = TextEditingController();
String gender = '';
final phoneNumberController = TextEditingController();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class _FirestoreDatabaseState extends State<FirestoreDatabase> {
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    firestore
        .collection('UserData')
        .doc(FirebaseAuth.instance.currentUser!.uid) // 현재 사용자의 UID로 문서 ID 지정
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          nameController.text = doc['name'];
          nicknameController.text = doc['nickname'];
          birthDateController.text = doc['birthDate'];
          gender = doc['gender'];
          phoneNumberController.text = doc['phoneNumber'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("개인정보 수정"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 25),
            commonTextField("이름", nameController, false),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                genderButton("남자", () {
                  setState(() {
                    gender = '남자';
                  });
                }),
                SizedBox(width: 10),
                genderButton("여자", () {
                  setState(() {
                    gender = '여자';
                  });
                }),
              ],
            ),
            SizedBox(height: 10),
            commonTextField("닉네임", nicknameController, false),
            SizedBox(height: 10),
            commonTextField("생년월일  예) 010101", birthDateController, false,
                isNumeric: true),
            SizedBox(height: 10),
            commonTextField("전화번호(-없이 입력하세요)", phoneNumberController, false,
                isNumeric: true),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    nicknameController.text.isEmpty ||
                    birthDateController.text.isEmpty ||
                    gender.isEmpty ||
                    phoneNumberController.text.isEmpty) {
                  setState(() {
                    errorMessage = "모든 필드를 입력하세요.";
                  });
                  return;
                }

                if (!isNumeric(birthDateController.text) ||
                    !isNumeric(phoneNumberController.text)) {
                  setState(() {
                    errorMessage = "생년월일과 전화번호는 숫자로 입력하세요.";
                  });
                  return;
                }

                setState(() {
                  errorMessage = null;
                });

                // 사용자의 UID를 이용하여 데이터 저장
                await firestore
                    .collection('UserData')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .set({
                  'name': nameController.text,
                  'nickname': nicknameController.text,
                  'birthDate': birthDateController.text,
                  'gender': gender,
                  'phoneNumber': phoneNumberController.text,
                });

                nameController.clear();
                nicknameController.clear();
                birthDateController.clear();
                phoneNumberController.clear();
                gender = '';

                FocusScope.of(context).unfocus();

                // 데이터 수정 후 마이페이지로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyPage()),
                );
              },
              child: const Text("수정"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Padding commonTextField(hint, controller, hide, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: hide,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric
            ? <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ]
            : null,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget genderButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: gender == text ? Colors.blue : null,
      ),
    );
  }

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
