import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/protly_theme.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/onboarding/try_demo_screen.dart';
import 'features/onboarding/camera_permission_screen.dart';
import 'features/onboarding/goal_weight_screen.dart';
import 'features/onboarding/goal_activity_screen.dart';
import 'features/onboarding/goal_summary_screen.dart';
import 'features/onboarding/notification_permission_screen.dart';
import 'features/onboarding/privacy_consent_screen.dart';
import 'features/home/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ProtlyTheme.pureWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Protly',
      debugShowCheckedModeBanner: false,
      theme: ProtlyTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/try-demo': (context) => const TryDemoScreen(),
        '/camera-permission': (context) => const CameraPermissionScreen(),
        '/goal-weight': (context) => const GoalWeightScreen(),
        '/goal-activity': (context) => const GoalActivityScreen(),
        '/goal-summary': (context) => const GoalSummaryScreen(),
        '/notification-permission':
            (context) => const NotificationPermissionScreen(),
        '/privacy-consent': (context) => const PrivacyConsentScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
