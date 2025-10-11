import 'package:flutter/material.dart';
import '../../core/theme/protly_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProtlyTheme.pureWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: ProtlyTheme.vitalityGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 50,
                color: ProtlyTheme.pureWhite,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Protly! 🎯',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Main app will be here',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: ProtlyTheme.mediumGray),
            ),
          ],
        ),
      ),
    );
  }
}
