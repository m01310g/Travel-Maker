import 'package:validators/validators.dart';

/*
    funValidator에서 return하는 것 생성
*/

Function validateID = () => (String? value) {
  if(value!.isEmpty) {
    return "공백이 들어갈 수 없습니다.";
  } else if(!isAlphanumeric(value)) {
    // alphabet이거나 숫자가 아니면 반환값 출력
    return "ID에 한글이나 특수문자가 들어갈 수 없습니다.";
  } else if(value.length < 4) {
    return "ID의 최소 길이는 4자입니다.";
  } else if(value.length > 12) {
    return "ID의 길이를 초과하였습니다.";
  } else {
    return null;
  }
};

Function validatePassword = () => (String? value) {
  if(value!.isEmpty) {
    return "공백이 들어갈 수 없습니다.";
  } else if(value.length < 4) {
    return "password의 최소 길이는 4자입니다.";
  } else if(value.length > 12) {
    return "password의 길이를 초과하였습니다.";
  }  else {
    return null;
  }
};

Function validateEmail = () => (String? value) {
  if(value!.isEmpty) {
    return "Email은 공백이 들어갈 수 없습니다.";
  } else if(!isEmail(value)) {
    return "Email 형식에 맞지 않습니다.";
  } else {
    return null;
  }
};