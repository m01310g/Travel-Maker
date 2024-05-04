import 'package:flutter/material.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({Key? key}) : super(key: key);

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _textController = TextEditingController();

  void _sendMessage(String message) {
    setState(() {
      // 사용자가 보낸 메시지를 오른쪽에 배치하도록 추가합니다.
      messages.add({
        'text': message,
        'isUser': true,
      });

      // 챗봇 응답을 추가합니다.
      messages.add({
        'text': '어디GO: Response to "$message"',
        'isUser': false,
      });

      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('어디GO'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['isUser'] as bool;
                final text = message['text'] as String;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.0),
                        border: isUser
                            ? Border.all(color: Colors.blue)
                            : Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
