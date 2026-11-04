import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O nama'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Džemat Bochum',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}