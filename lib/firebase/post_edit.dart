import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../pages/community_page.dart'; // 커뮤니티 페이지 파일 임포트

class DataEditPage extends StatefulWidget {
  final String documentId;

  DataEditPage({required this.documentId});

  @override
  _DataEditPageState createState() => _DataEditPageState();
}

class _DataEditPageState extends State<DataEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    DocumentSnapshot document =
    await FirebaseFirestore.instance.collection('posts').doc(widget.documentId).get();
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    _titleController.text = data['title'];
    _contentController.text = data['content'];
    _imageUrls = List<String>.from(data['imageUrls']);

    if (!await _checkUserAuthentication(data['authorId'])) {
      _showUnauthorizedDialog();
    }
  }

  Future<bool> _checkUserAuthentication(String authorId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && currentUser.uid == authorId;
  }

  void _showUnauthorizedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('경고'),
        content: Text('수정할 수 있는 권한이 없습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // 페이지 닫기
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('posts').doc(widget.documentId).update({
        'title': _titleController.text,
        'content': _contentController.text,
        'imageUrls': _imageUrls,
      });
      // 수정 성공 시 커뮤니티 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CommunityPage()), // 커뮤니티 페이지로 이동
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 수정'),
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
                  onPressed: _saveData,
                  child: const Text('저장'),
                ),
                const SizedBox(height: 16.0),
                Text('이미지', style: TextStyle(fontSize: 18.0)),
                SizedBox(height: 8.0),
                // 이미지 목록을 보여주는 위젯
                _buildImageList(),
                ElevatedButton(
                  onPressed: () async {
                    final imageUrl = await _getImageUrl();
                    if (imageUrl != null) {
                      setState(() {
                        _imageUrls.add(imageUrl);
                      });
                    }
                  },
                  child: const Text('이미지 추가'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 이미지 목록을 보여주는 위젯
  Widget _buildImageList() {
    return SizedBox(
      height: 200.0, // 이미지 목록의 높이 제한
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal, // 가로 스크롤 지원
        itemCount: _imageUrls.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              children: [
                Container(
                  width: 150.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(_imageUrls[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4.0,
                  right: 4.0,
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _imageUrls.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<String?> _getImageUrl() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final file = File(pickedImage.path);
      return _uploadImageAndGetUrl(file);
    } else {
      return null;
    }
  }

  Future<String?> _uploadImageAndGetUrl(File file) async {
    final fileName = path.basename(file.path);
    final destination = 'community_images/${FirebaseAuth.instance.currentUser!.uid}/$fileName';

    try {
      await firebase_storage.FirebaseStorage.instance.ref(destination).putFile(file);
      final imageUrl = await firebase_storage.FirebaseStorage.instance.ref(destination).getDownloadURL();
      return imageUrl;
    } catch (error) {
      print('이미지 업로드 중 오류 발생: $error');
      return null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
