import 'package:flutter/material.dart';
import 'ilmihal1.dart';
import 'ilmihal2.dart';
import 'ilmihal3.dart';

class MektebPage extends StatelessWidget {
  const MektebPage({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF006962);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mekteb'),
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ilmihalButton(
              context,
              title: 'Ilmihal 1',
              page: const Ilmihal1Page(),
              green: green,
            ),

            const SizedBox(height: 16),

            _ilmihalButton(
              context,
              title: 'Ilmihal 2',
              page: const Ilmihal2Page(),
              green: green,
            ),

            const SizedBox(height: 16),

            _ilmihalButton(
              context,
              title: 'Ilmihal 3',
              page: const Ilmihal3Page(),
              green: green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _ilmihalButton(
    BuildContext context, {
    required String title,
    required Widget page,
    required Color green,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.menu_book,
              size: 42,
              color: green,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: green,
            ),
          ],
        ),
      ),
    );
  }
}