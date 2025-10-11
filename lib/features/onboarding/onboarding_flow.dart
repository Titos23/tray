import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'
    as device_permissions;

import '../../core/theme/app_colors.dart';
import 'onboarding_persistence.dart';
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
import 'onboarding_step.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with WidgetsBindingObserver {
  final OnboardingViewModel _model = OnboardingViewModel();
  final OnboardingPersistence _persistence = OnboardingPersistence();
  final List<OnboardingStep> _history = [];

  OnboardingStep _step = OnboardingStep.splash;
  bool _skipLock = false;
  OnboardingStep? _restoredStep;
  List<OnboardingStep>? _restoredHistory;
  bool _splashCompleted = false;
  bool _isRestoring = true;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _model.addListener(_persistModelDebounced);
    _restoreState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.removeListener(_persistModelDebounced);
    _saveDebounce?.cancel();
    _model.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _persistState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _history.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_history.isNotEmpty) {
          _goBack();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case OnboardingStep.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onFinished: _handleSplashFinished,
        );
      case OnboardingStep.welcome:
        return WelcomeValuePropScreen(
          key: const ValueKey('welcome'),
          onTryNow: () => _goTo(OnboardingStep.demo),
          onSignIn: () {},
        );
      case OnboardingStep.demo:
        return TryItDemoScreen(
          key: const ValueKey('demo'),
          onBack: _history.isNotEmpty ? _goBack : null,
          onContinue: () => _goTo(OnboardingStep.cameraPermission),
        );
      case OnboardingStep.cameraPermission:
        return CameraPermissionScreen(
          key: const ValueKey('camera'),
          model: _model,
          onBack: _history.isNotEmpty ? _goBack : null,
          onPermissionRequest: _handleCameraPermissionRequest,
          onContinue: () => _goTo(OnboardingStep.goalWeight),
          onOpenSettings: _openSystemSettings,
        );
      case OnboardingStep.goalWeight:
        return GoalWeightScreen(
          key: const ValueKey('goal-weight'),
          model: _model,
          onBack: _history.isNotEmpty ? _goBack : null,
          onContinue: () => _goTo(OnboardingStep.goalActivity),
        );
      case OnboardingStep.goalActivity:
        return GoalActivityScreen(
          key: const ValueKey('goal-activity'),
          model: _model,
          onBack: _history.isNotEmpty ? _goBack : null,
          onContinue: () => _goTo(OnboardingStep.goalSummary),
        );
      case OnboardingStep.goalSummary:
        return GoalSummaryScreen(
          key: const ValueKey('goal-summary'),
          model: _model,
          onBack: _history.isNotEmpty ? _goBack : null,
          onContinue: () => _goTo(OnboardingStep.notifications),
        );
      case OnboardingStep.notifications:
        return NotificationPermissionScreen(
          key: const ValueKey('notifications'),
          model: _model,
          onBack: _history.isNotEmpty ? _goBack : null,
          onPermissionRequest: _handleNotificationPermissionRequest,
          onContinue: () => _goTo(OnboardingStep.privacy),
        );
      case OnboardingStep.privacy:
        return PrivacyConsentScreen(
          key: const ValueKey('privacy'),
          model: _model,
          onBack: _history.isNotEmpty ? _goBack : null,
          onOpenSettings: _openSystemSettings,
          onFinish: () async {
            await _persistence.clear();
            _history.clear();
            _goTo(OnboardingStep.completed, recordHistory: false);
          },
        );
      case OnboardingStep.completed:
        return const _MainAppPlaceholder();
    }
  }

  void _goTo(OnboardingStep next, {bool recordHistory = true}) {
    if (!mounted || _step == next) return;
    setState(() {
      if (recordHistory && _step != OnboardingStep.splash) {
        _history.add(_step);
      }
      _step = next;
    });
    _persistState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSkip());
  }

  void _goBack() {
    if (_history.isEmpty) return;
    final previous = _history.removeLast();
    setState(() => _step = previous);
    _persistState();
  }

  void _maybeSkip() {
    if (_skipLock) return;
    _skipLock = true;
    try {
      if (!mounted) return;
      if (_step == OnboardingStep.cameraPermission &&
          _model.cameraPermission == PermissionStatus.granted) {
        _goTo(OnboardingStep.goalWeight, recordHistory: false);
        return;
      }
      if (_step == OnboardingStep.notifications &&
          _model.notificationPermission == PermissionStatus.granted) {
        _goTo(OnboardingStep.privacy, recordHistory: false);
        return;
      }
    } finally {
      _skipLock = false;
    }
  }

  void _handleSplashFinished() {
    _splashCompleted = true;
    if (_restoredStep != null) {
      _applyRestoredStep();
    } else {
      _isRestoring = false;
      _goTo(OnboardingStep.welcome, recordHistory: false);
    }
  }

  void _applyRestoredStep() {
    _isRestoring = false;
    final target = _restoredStep;
    if (target == null || target == OnboardingStep.splash) {
      _restoredStep = null;
      _restoredHistory = null;
      _goTo(OnboardingStep.welcome, recordHistory: false);
      return;
    }
    setState(() {
      _history
        ..clear()
        ..addAll(_restoredHistory ?? const []);
      _step = target;
    });
    _restoredStep = null;
    _restoredHistory = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeSkip();
      _persistState();
    });
  }

  Future<void> _restoreState() async {
    final restored = await _persistence.restore();

    if (!mounted) return;

    if (restored != null) {
      _model.restoreFromMap(restored.modelState);
      _restoredStep = restored.step;
      _restoredHistory =
          restored.history.where((step) => step != restored.step).toList();
      if (_splashCompleted) {
        _applyRestoredStep();
      }
    } else {
      _isRestoring = false;
    }
  }

  Future<void> _persistState() async {
    if (_isRestoring) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 150), () async {
      await _persistence.save(
        step: _step,
        history: List<OnboardingStep>.from(_history),
        model: _model,
      );
    });
  }

  void _persistModelDebounced() {
    _persistState();
  }

  Future<PermissionStatus> _handleCameraPermissionRequest() async {
    final choice = await _showSystemPrompt(
      title: 'Allow Protly to use your camera?',
      message:
          'Protly needs your camera so you can scan your meals and get instant protein insights.',
      options: const [
        _SystemOption(label: 'Allow', value: _SystemChoice.allow),
        _SystemOption(label: "Don't ask again", value: _SystemChoice.neverAsk),
        _SystemOption(label: 'Deny', value: _SystemChoice.deny),
      ],
    );

    if (choice == null) {
      return _model.cameraPermission;
    }
    if (choice == _SystemChoice.deny) {
      _model.updateCameraPermission(PermissionStatus.denied);
      return PermissionStatus.denied;
    }
    if (choice == _SystemChoice.neverAsk) {
      _model.updateCameraPermission(PermissionStatus.restricted);
      return PermissionStatus.restricted;
    }

    final status = await device_permissions.Permission.camera.request();
    final mapped = _mapDeviceStatus(status);
    _model.updateCameraPermission(mapped);
    return mapped;
  }

  Future<PermissionStatus> _handleNotificationPermissionRequest() async {
    final choice = await _showSystemPrompt(
      title: 'Enable Protly notifications?',
      message:
          'Notifications will gently remind you to complete your protein goal.',
      options: const [
        _SystemOption(label: 'Allow', value: _SystemChoice.allow),
        _SystemOption(label: 'Later', value: _SystemChoice.later),
        _SystemOption(label: 'Deny', value: _SystemChoice.deny),
      ],
    );

    if (choice == null) {
      return _model.notificationPermission;
    }
    if (choice == _SystemChoice.later) {
      _model.updateNotificationPermission(PermissionStatus.unknown);
      return PermissionStatus.unknown;
    }
    if (choice == _SystemChoice.deny) {
      _model.updateNotificationPermission(PermissionStatus.denied);
      return PermissionStatus.denied;
    }

    final status =
        await device_permissions.Permission.notification.request();
    final mapped = _mapDeviceStatus(status);
    _model.updateNotificationPermission(mapped);
    return mapped;
  }

  PermissionStatus _mapDeviceStatus(
    device_permissions.PermissionStatus status,
  ) {
    switch (status) {
      case device_permissions.PermissionStatus.granted:
      case device_permissions.PermissionStatus.provisional:
        return PermissionStatus.granted;
      case device_permissions.PermissionStatus.denied:
        return PermissionStatus.denied;
      case device_permissions.PermissionStatus.restricted:
      case device_permissions.PermissionStatus.permanentlyDenied:
        return PermissionStatus.restricted;
      case device_permissions.PermissionStatus.limited:
        return PermissionStatus.granted;
    }
  }

  Future<_SystemChoice?> _showSystemPrompt({
    required String title,
    required String message,
    required List<_SystemOption> options,
  }) {
    return showDialog<_SystemChoice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.darkText),
          ),
          content: Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.neutralText),
          ),
          actions: [
            for (final option in options)
              TextButton(
                onPressed: () => Navigator.of(context).pop(option.value),
                child: Text(option.label),
              ),
          ],
        );
      },
    );
  }

  Future<void> _openSystemSettings() async {
    final success = await device_permissions.openAppSettings();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open system settings.'),
          backgroundColor: AppColors.darkText,
        ),
      );
    }
  }
}

class _SystemOption {
  const _SystemOption({required this.label, required this.value});

  final String label;
  final _SystemChoice value;
}

enum _SystemChoice { allow, deny, neverAsk, later }

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
