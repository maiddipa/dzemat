import 'package:flutter/material.dart';

class Ilmihal1Page extends StatefulWidget {
  const Ilmihal1Page({super.key});

  @override
  State<Ilmihal1Page> createState() => _Ilmihal1PageState();
}

class _Ilmihal1PageState extends State<Ilmihal1Page> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  static const int totalPages = 90;

String _pageImage(int index) {
  final number = (index + 1).toString().padLeft(3, '0');

  return 'lib/screens/assets/Ilmihal1/page_$number.jpg';
}

  void _nextPage() {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF006962);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text(
          'Ilmihal 1',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // STRANICE KNJIGE
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,

              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },

              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),

                      // omogućava zoom
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,

                        child: Center(
                          child: Image.asset(
                            _pageImage(index),
                            fit: BoxFit.contain,

                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Center(
                                child: Text(
                                  'Nije pronađena stranica ${index + 1}',
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // DONJA KONTROLA
          Container(
            height: 70,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed:
                      _currentPage == 0 ? null : _previousPage,
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                  ),
                  color: green,
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ilmihal 1',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_currentPage + 1} / $totalPages',
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                IconButton(
                  onPressed:
                      _currentPage == totalPages - 1
                          ? null
                          : _nextPage,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                  ),
                  color: green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}