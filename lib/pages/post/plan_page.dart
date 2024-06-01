import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanPage extends StatefulWidget {
  @override
  State createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  String userProfileImageUrl = 'assets/images/default_image.png';
  bool _isLoading = false;
  late AnimationController _animationController;
  int _lastBotMessageIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _getInitialMessage();
    _loadUserProfileImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getInitialMessage() async {
    try {
      var url = Uri.parse('http://172.30.1.53:5000/init');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        setState(() {
          _messages.add({'sender': 'bot', 'text': responseBody['message'], 'isLoading': 'true'});
          _lastBotMessageIndex = _messages.length - 1;
        });
      } else {
        print("HTTP 요청이 실패했습니다: ${response.statusCode}");
      }
    } catch (e) {
      print('오류: $e');
    }
  }

  Future<void> _loadUserProfileImage() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('UserData').doc(uid).get();
      if (userData.exists) {
        var data = userData.data() as Map<String, dynamic>;
        setState(() {
          userProfileImageUrl = data['profileImageUrl'] ?? 'assets/images/default_image.png';
        });
      }
    } catch (e) {
      print('사용자 프로필 이미지 불러오기 중 오류 발생: $e');
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      // 키보드 숨기기
      FocusScope.of(context).unfocus();

      setState(() {
        _messages.add({'sender': 'user', 'text': _controller.text});
        _isLoading = true;
        _animationController.repeat();
      });

      try {
        var body = jsonEncode({"query": _controller.text});
        var url = Uri.parse('http://172.30.1.53:5000/query');
        var headers = {"Content-Type": "application/json"};

        var response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          print(responseBody);
          var responseContent = responseBody['response'];
          var userIntent = responseContent['user_intent'];
          var location = responseContent['location'];
          var subCategory = responseContent['sub_category'];
          var duration = responseContent['duration'];

          setState(() {
            _messages.add({
              'sender': 'bot',
              'text': '사용자 의도 - $userIntent, 위치 - $location, 세부 카테고리 - $subCategory, 기간 - $duration',
              'isLoading': 'true'
            });
            _lastBotMessageIndex = _messages.length - 1;
            _isLoading = false;
            _animationController.stop();
          });
          _controller.clear();
        } else {
          print("HTTP 요청이 실패했습니다: ${response.statusCode}");
          setState(() {
            _isLoading = false;
            _animationController.stop();
          });
        }
      } catch (e) {
        print('오류: $e');
        setState(() {
          _isLoading = false;
          _animationController.stop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('어디GO'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _buildMessage(_messages[index], index),
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, String> message, int index) {
    bool isUser = message['sender'] == 'user';
    bool isLoading = message['isLoading'] == 'true' && index == _lastBotMessageIndex;
    String textToShow = message['text'] ?? ''; // 메시지가 없을 경우를 대비해 빈 문자열로 초기화

    return Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
    children: <Widget>[
    if (!isUser) ...[
    isLoading
    ? RotationTransition(
    turns: _animationController,
    child: Transform(
    alignment: Alignment.center,
    transform: Matrix4.rotationY(0), // 이미지가 돌아가지 않도록 설정
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/Chatbot.jpg'),
      ),
    ),
    )
        : CircleAvatar(
      backgroundImage: AssetImage('assets/images/Chatbot.jpg'),
    ),
      SizedBox(width: 8.0),
    ],
      Flexible(
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isUser ? Colors.blueAccent : Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text.rich(
            TextSpan(
              text: '', // 빈 문자열로 초기화된 상태에서 문자열을 추가할 예정
              children: textToShow.characters.map((char) {
                return TextSpan(
                  text: char,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      if (isUser) ...[
        SizedBox(width: 8.0),
        CircleAvatar(
          backgroundImage: userProfileImageUrl.startsWith('assets/')
              ? AssetImage(userProfileImageUrl)
              : NetworkImage(userProfileImageUrl) as ImageProvider,
        ),
      ],
    ],
    ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).primaryColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration.collapsed(hintText: '메시지를 입력하세요'),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

