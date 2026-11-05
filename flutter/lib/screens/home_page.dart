import 'package:flutter/material.dart';
import '../i18n/dzemat_locale_controller.dart';

class HomePage extends StatelessWidget {
  final Function(int) onOpenPage;

  const HomePage({
    super.key,
    required this.onOpenPage,
  });

  @override
  Widget build(BuildContext context) {
    final lang=DzematLocaleController.instance;
    return AnimatedBuilder(animation:lang,builder:(context,_)=>Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // LOGO I POZDRAV
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                color: const Color(0xFF006962),
                child: Column(
                  children: [
                    Image.asset(
                      'lib/screens/assets/logo.jpg',
                      height: 170,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Esselamu alejkum, ehlen ve sehlen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // MENI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.18,
                  children: [
                    // DEŠAVANJA
                    _menuCard(
                      title: lang.t('news'),
                      icon: Icons.event,
                      onTap: () => onOpenPage(1),
                    ),

                    // SUFARA
                    _menuCard(
                      title: 'Sufara',
                      icon: Icons.menu_book,
                      onTap: () => onOpenPage(2),
                    ),

                    // MEKTEB
                    _menuCard(
                      title: 'Mekteb',
                      icon: Icons.school,
                      onTap: () => onOpenPage(3),
                    ),

                    // KUR'AN
                    _menuCard(
                      title: "Kur'an",
                      icon: Icons.auto_stories,
                      onTap: () => onOpenPage(4),
                    ),

                    // O NAMA
                    _menuCard(
                      title: lang.t('about'),
                      icon: Icons.mosque,
                      onTap: () => onOpenPage(5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _menuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: const Color(0xFF006962),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}