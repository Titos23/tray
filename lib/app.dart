import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_flow.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const OnboardingFlow(),
    );
  }
}
