import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // ImagePicker 패키지 임포트
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class PostCreatePage extends StatefulWidget {
  @override
  _PostCreatePageState createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  Future<void> _saveData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // 사용자가 로그인하지 않은 경우 로그인 페이지로 이동
      // 예를 들어, Navigator.push를 사용하여 로그인 페이지로 이동할 수 있습니다.
      // 로그인 후에는 다시 _saveData 함수가 호출되므로 여기에서는 그냥 반환합니다.
      return;
    }

    if (_formKey.currentState!.validate()) {
      final newPostRef = await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'likes': [],
        'likesCount': 0,
        'authorId': currentUser.uid,
        'imageUrls': _imageUrls,
        'timestamp': Timestamp.now(),
        'comments': [],
      });

      // 이미지 업로드
      for (final imageUrl in _imageUrls) {
        await newPostRef.collection('images').add({
          'url': imageUrl,
        });
      }

      Navigator.pop(context, true); // Successful creation
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery); // pickImage로 수정
    if (pickedImage != null) {
      // 이미지를 선택한 경우에만 실행
      File imageFile = File(pickedImage.path);

      // Firebase Storage에 이미지 업로드
      String imageUrl = await _uploadImageToFirebaseStorage(imageFile);

      // 선택한 이미지의 URL을 _imageUrls 리스트에 추가
      setState(() {
        _imageUrls.add(imageUrl);
      });
    }
  }

  Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
    try {
      // 현재 시간을 기반으로 이미지 파일의 이름 생성
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Firebase Storage에 이미지 업로드
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('community_images').child(fileName);
      await ref.putFile(imageFile);

      // 업로드한 이미지의 다운로드 URL 반환
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      return '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 작성'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '제목을 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                  ),
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '내용을 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _pickImage, // 이미지 선택 버튼에 이미지 피커 함수 연결
                  child: const Text('이미지 선택'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveData,
                  child: const Text('저장'),
                ),
                const SizedBox(height: 16.0),
                // 선택한 이미지 미리보기
                if (_imageUrls.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '선택한 이미지:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _imageUrls.map((url) => Image.network(url, width: 100, height: 100)).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
