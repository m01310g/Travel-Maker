import 'package:flutter/material.dart';
import 'package:travelmaker/firebase/login_google.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login', // 앱이 실행될 때 로그인 페이지로 이동
      routes: {
        '/login': (context) => GoogleLoginPage(), // 로그인 페이지
        '/home': (context) => MyHomePage(title: 'Home Page'), // 홈 페이지
      },
    );
  }
}

class GoogleLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google 로그인'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 여기에 구글 로그인 기능 구현
            // 예: Navigator.pushNamed()를 사용하여 다음 페이지로 이동
            Navigator.pushNamed(context, '/login'); // 로그인 페이지로 이동
          },
          child: const Text('구글로 로그인'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
