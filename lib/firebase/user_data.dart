import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_database.dart';
import 'user_data.dart'; // 수정된 부분

class UserData extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내정보'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FirestoreDatabase()), // 수정 페이지로 이동
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: firestore.collection('UserData').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('데이터를 불러오는 중 오류가 발생했습니다.'),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('저장된 데이터가 없습니다.'),
            );
          }
          var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          return ListView(
            children: [
              ListTile(
                title: Text('이름: ${data['name']}'),
              ),
              ListTile(
                title: Text('성별: ${data['gender']}'),
              ),
              ListTile(
                title: Text('닉네임: ${data['nickname']}'),
              ),
              ListTile(
                title: Text('생년월일: ${data['birthDate']}'),
              ),
              ListTile(
                title: Text('전화번호: ${data['phoneNumber']}'),
              ),
            ],
          );
        },
      ),
    );
  }
}
