import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Community"),
      ),
      body: ListView.separated(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {},
            title: const Text("제목"),
            leading: const Text("1"),
          );
        }, separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
      ),
    );
  }
}
