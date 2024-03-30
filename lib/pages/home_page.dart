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
<<<<<<< HEAD
=======
      body: Align(
        
      ),
>>>>>>> efe4b1099459ea971b874ae7d56a9ee142b8cd1a
    );
  }
}