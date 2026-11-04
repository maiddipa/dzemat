import 'package:flutter/material.dart';

import 'home_page.dart';
import 'gallery_page.dart';
import 'sufara_page.dart';
import 'mekteb_page.dart';
import 'quran_page.dart';
import 'about_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  static const Color dzematGreen = Color(0xFF006962);

  int _currentIndex = 0;

  void _openPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onOpenPage: _openPage,
      ),
      const GalleryPage(),
      const SufaraPage(),
      const MektebPage(),
      const QuranPage(),
      const AboutPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              _bottomItem(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),

              _bottomItem(
                index: 1,
                icon: Icons.event_outlined,
                selectedIcon: Icons.event,
                label: 'Ahtuelnosti',
              ),

              _bottomItem(
                index: 2,
                icon: Icons.menu_book_outlined,
                selectedIcon: Icons.menu_book,
                label: 'Sufara',
              ),

              _bottomItem(
                index: 3,
                icon: Icons.school_outlined,
                selectedIcon: Icons.school,
                label: 'Mekteb',
              ),

              _bottomItem(
                index: 4,
                icon: Icons.auto_stories_outlined,
                selectedIcon: Icons.auto_stories,
                label: "Kur'an",
              ),

              _bottomItem(
                index: 5,
                icon: Icons.mosque_outlined,
                selectedIcon: Icons.mosque,
                label: 'O nama',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final bool selected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _openPage(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              size: 24,
              color: selected
                  ? dzematGreen
                  : Colors.grey.shade600,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? dzematGreen
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}