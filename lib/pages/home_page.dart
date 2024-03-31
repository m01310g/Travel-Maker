import 'package:flutter/material.dart';
import 'package:travelmaker/src/components/image_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: ImageData(
          IconsPath.logoh,
          width: 300,
        ),
      ),
      body: Align(
        
      ),
    );
  }
}