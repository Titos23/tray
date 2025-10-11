import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'onboarding_state.dart';
import 'screens/camera_permission_screen.dart';
import 'screens/goal_activity_screen.dart';
import 'screens/goal_summary_screen.dart';
import 'screens/goal_weight_screen.dart';
import 'screens/notification_permission_screen.dart';
import 'screens/privacy_consent_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/try_it_demo_screen.dart';
import 'screens/welcome_value_prop_screen.dart';

enum OnboardingStep {
  splash,
  welcome,
  demo,
  cameraPermission,
  goalWeight,
  goalActivity,
  goalSummary,
  notifications,
  privacy,
  completed,
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final OnboardingViewModel _model = OnboardingViewModel();
  OnboardingStep _step = OnboardingStep.splash;
  bool _skipLock = false;

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case OnboardingStep.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onFinished: () => _goTo(OnboardingStep.welcome),
        );
      case OnboardingStep.welcome:
        return WelcomeValuePropScreen(
          key: const ValueKey('welcome'),
          onTryNow: () => _goTo(OnboardingStep.demo),
          onSignIn: () {
            // Hook for analytics later.
          },
        );
      case OnboardingStep.demo:
        return TryItDemoScreen(
          key: const ValueKey('demo'),
          onContinue: () => _goTo(OnboardingStep.cameraPermission),
        );
      case OnboardingStep.cameraPermission:
        return CameraPermissionScreen(
          key: const ValueKey('camera'),
          model: _model,
          onPermissionRequest: _handleCameraPermissionRequest,
          onContinue: () => _goTo(OnboardingStep.goalWeight),
          onOpenSettings: _openSystemSettings,
        );
      case OnboardingStep.goalWeight:
        return GoalWeightScreen(
          key: const ValueKey('goal-weight'),
          model: _model,
          onContinue: () => _goTo(OnboardingStep.goalActivity),
        );
      case OnboardingStep.goalActivity:
        return GoalActivityScreen(
          key: const ValueKey('goal-activity'),
          model: _model,
          onContinue: () => _goTo(OnboardingStep.goalSummary),
        );
      case OnboardingStep.goalSummary:
        return GoalSummaryScreen(
          key: const ValueKey('goal-summary'),
          model: _model,
          onContinue: () => _goTo(OnboardingStep.notifications),
        );
      case OnboardingStep.notifications:
        return NotificationPermissionScreen(
          key: const ValueKey('notifications'),
          model: _model,
          onPermissionRequest: _handleNotificationPermissionRequest,
          onContinue: () => _goTo(OnboardingStep.privacy),
        );
      case OnboardingStep.privacy:
        return PrivacyConsentScreen(
          key: const ValueKey('privacy'),
          model: _model,
          onOpenSettings: _openSystemSettings,
          onFinish: () => _goTo(OnboardingStep.completed),
        );
      case OnboardingStep.completed:
        return const _MainAppPlaceholder();
    }
  }

  void _goTo(OnboardingStep next) {
    if (!mounted) return;
    setState(() {
      _step = next;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSkip());
  }

  void _maybeSkip() {
    if (_skipLock) return;
    _skipLock = true;
    try {
      if (!mounted) return;
      if (_step == OnboardingStep.cameraPermission &&
          _model.cameraPermission == PermissionStatus.granted) {
        _goTo(OnboardingStep.goalWeight);
        return;
      }
      if (_step == OnboardingStep.notifications &&
          _model.notificationPermission == PermissionStatus.granted) {
        _goTo(OnboardingStep.privacy);
        return;
      }
    } finally {
      _skipLock = false;
    }
  }

  Future<PermissionStatus> _handleCameraPermissionRequest() async {
    // TODO: integrate with permission_handler / camera plugin.
    await Future.delayed(const Duration(milliseconds: 500));
    _model.updateCameraPermission(PermissionStatus.granted);
    return PermissionStatus.granted;
  }

  Future<PermissionStatus> _handleNotificationPermissionRequest() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _model.updateNotificationPermission(PermissionStatus.granted);
    return PermissionStatus.granted;
  }

  void _openSystemSettings() {
    // Placeholder for a platform channel integration.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings opening is not implemented in this prototype.'),
        backgroundColor: AppColors.darkText,
      ),
    );
  }
}

class _MainAppPlaceholder extends StatelessWidget {
  const _MainAppPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Main app experience placeholder',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.neutralText,
              ),
        ),
      ),
    );
  }
}
