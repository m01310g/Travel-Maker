import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'user_data.dart';

class FirestoreDatabase extends StatefulWidget {
  const FirestoreDatabase({Key? key}) : super(key: key);

  @override
  State<FirestoreDatabase> createState() => _FirestoreDatabaseState();
}

final nameController = TextEditingController();
final nicknameController = TextEditingController();
final birthDateController = TextEditingController();
String gender = ''; // 성별 변수 추가
final phoneNumberController = TextEditingController();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class _FirestoreDatabaseState extends State<FirestoreDatabase> {
  String? errorMessage; // 입력이 잘못된 경우의 오류 메시지

  @override
  void initState() {
    super.initState();
    // Firestore에서 데이터 가져오기
    firestore.collection('UserData').doc(getDocumentId()).get().then((doc) {
      if (doc.exists) {
        // 데이터가 존재할 경우 각 컨트롤러에 데이터 설정
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
            // 이름 필드
            commonTextField("이름", nameController, false),
            SizedBox(height: 10),
            // 성별 선택 버튼
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
            // 닉네임 필드
            commonTextField("닉네임", nicknameController, false),
            SizedBox(height: 10),
            // 생년월일 필드
            commonTextField("생년월일  예) 010101", birthDateController, false, isNumeric: true),
            SizedBox(height: 10),
            // 전화번호 필드
            commonTextField("전화번호(-없이 입력하세요)", phoneNumberController, false, isNumeric: true),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                // Check if any of the text fields are empty
                if (nameController.text.isEmpty ||
                    nicknameController.text.isEmpty ||
                    birthDateController.text.isEmpty ||
                    gender.isEmpty || // 성별이 선택되지 않은 경우
                    phoneNumberController.text.isEmpty) {
                  setState(() {
                    errorMessage = "모든 필드를 입력하세요.";
                  });
                  return; // 데이터 추가 진행 중단
                }

                // Check if birthDate and phoneNumber are numeric
                if (!isNumeric(birthDateController.text) ||
                    !isNumeric(phoneNumberController.text)) {
                  setState(() {
                    errorMessage = "생년월일과 전화번호는 숫자로 입력하세요.";
                  });
                  return; // 데이터 추가 진행 중단
                }

                // Clear error message if fields are valid
                setState(() {
                  errorMessage = null;
                });

                // Add data to Firestore
                await firestore.collection('UserData').doc(getDocumentId()).set({
                  'name': nameController.text,
                  'nickname': nicknameController.text,
                  'birthDate': birthDateController.text,
                  'gender': gender,
                  'phoneNumber': phoneNumberController.text,
                });

                // Clear text controllers
                nameController.clear();
                nicknameController.clear();
                birthDateController.clear();
                phoneNumberController.clear();
                gender = ''; // 선택된 성별 초기화

                // Dismiss the keyboard after adding items
                FocusScope.of(context).unfocus();

                // Navigate to UserData screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserData()), // 수정된 부분
                );
              },
              child: const Text("수정"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // ElevatedButton의 색상
              ),
            ),
            if (errorMessage != null) // 오류 메시지가 있는 경우에만 표시
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

  String getDocumentId() {
    // 이름과 생년월일을 조합하여 문서의 ID로 사용
    return '${nameController.text}_${birthDateController.text}';
  }

  Padding commonTextField(hint, controller, hide, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: hide,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric ? <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ] : null,
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

  // 성별 선택 버튼 위젯
  Widget genderButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: gender == text ? Colors.blue : null, // 선택된 성별은 파란색으로 표시
      ),
    );
  }

  // Check if a string is numeric
  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
