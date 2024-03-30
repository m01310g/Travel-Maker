import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String hint;
  final funValidator;

  const CustomTextFormField({super.key, required this.hint, required this.funValidator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 위아래로 여백
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        // validation check
        // 경우에 따라 받는 값이 다르기 때문에 함수를 외부에서 받아야 함
          validator: funValidator,
          // obscureText = 텍스트 가림 -> 비밀번호 못 보게 가림
          obscureText: hint == "비밀번호를 입력하세요" ? true : false,
          decoration: InputDecoration(
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          )
      ),
    );
  }
}