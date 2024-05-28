import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/post/my_page.dart';

class FirestoreDatabase extends StatefulWidget {
  const FirestoreDatabase({Key? key}) : super(key: key);

  @override
  State<FirestoreDatabase> createState() => _FirestoreDatabaseState();
}

class _FirestoreDatabaseState extends State<FirestoreDatabase> {
  // TextController 및 FirebaseFirestore 인스턴스를 상태 클래스 외부로 이동하지 않았습니다.
  final nameController = TextEditingController();
  final nicknameController = TextEditingController();
  final birthDateController = TextEditingController();
  String gender = '';
  final phoneNumberController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // initState에서 사용자 데이터를 가져와서 필드에 할당합니다.
    firestore
        .collection('UserData')
        .doc(FirebaseAuth.instance.currentUser!.uid)
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
                  setErrorMessage("모든 필드를 입력하세요.");
                  return;
                }

                if (!isNumeric(birthDateController.text) ||
                    !isNumeric(phoneNumberController.text)) {
                  setErrorMessage("생년월일과 전화번호는 숫자로 입력하세요.");
                  return;
                }

                setErrorMessage(null);

                // 사용자의 UID를 이용하여 데이터 저장
                try {
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

                  // 데이터 수정 후 마이페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyPage()),
                  );
                } catch (e) {
                  print('Error updating user data: $e');
                  setErrorMessage("데이터 수정 중 오류가 발생했습니다.");
                }
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
      child: Text(
        text,
        style: TextStyle(
          color: gender == text ? Colors.white : Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: gender == text ? Colors.blue : Colors.grey[300],
      ),
    );
  }

  void setErrorMessage(String? message) {
    setState(() {
      errorMessage = message;
    });
  }

  bool isNumeric(String str) {
    if (str.isEmpty) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
