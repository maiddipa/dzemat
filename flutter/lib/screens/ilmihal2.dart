import 'package:flutter/material.dart';

class Ilmihal2Page extends StatefulWidget {
  const Ilmihal2Page({super.key});

  @override
  State<Ilmihal2Page> createState() => _Ilmihal2PageState();
}

class _Ilmihal2PageState extends State<Ilmihal2Page> {
  final PageController _controller = PageController();
  int currentPage = 0;

  static const int totalPages = 128;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ilmihal 2'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: totalPages,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.asset(
                      'lib/screens/assets/Ilmihal2/${index + 1}.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '${currentPage + 1} / $totalPages',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}