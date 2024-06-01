import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlanPage extends StatefulWidget {
  @override
  State createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _getInitialMessage();
  }

  Future<void> _getInitialMessage() async {
    try {
      var url = Uri.parse('http://172.30.1.53:5000/init');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        setState(() {
          _messages.add('Bot: ${responseBody['message']}');
        });
      } else {
        print("HTTP Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
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
            _messages.add('User: ${_controller.text}');
            _messages.add('Bot: User Intent - $userIntent, Location - $location, Sub Category - $subCategory, Duration - $duration');
          });
          _controller.clear();
        } else {
          print("HTTP Request failed with status: ${response.statusCode}");
        }
      } catch (e) {
        print('Error: $e');
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
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _buildMessage(_messages[index]),
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

  Widget _buildMessage(String message) {
    return ListTile(
      title: Text(message),
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
                decoration: InputDecoration.collapsed(hintText: 'Send a message'),
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
