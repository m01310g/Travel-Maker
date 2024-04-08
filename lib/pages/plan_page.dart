import 'package:flutter/material.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Align(
        alignment: Alignment.topCenter,
        child: SearchBar(
          trailing: [Icon(Icons.search)],
          constraints: BoxConstraints(maxWidth: 360, minHeight: 56),
          hintText: "어디로 떠나시나요?",
        ),
      ),
    );
  }
}