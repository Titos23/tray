import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_step.dart';
import 'onboarding_state.dart';

class OnboardingPersistence {
  static const _stateKey = 'protly_onboarding_state';

  Future<void> save({
    required OnboardingStep step,
    required List<OnboardingStep> history,
    required OnboardingViewModel model,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'step': step.name,
      'history': history.map((e) => e.name).toList(),
      'model': model.toMap(),
    };
    await prefs.setString(_stateKey, jsonEncode(payload));
  }

  Future<OnboardingRestored?> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stateKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final step = _stepFromName(decoded['step'] as String?);
      if (step == null) return null;
      final historyNames = (decoded['history'] as List<dynamic>? ?? [])
          .cast<String>()
          .map(_stepFromName)
          .whereType<OnboardingStep>()
          .toList();
      final modelMap = decoded['model'] as Map<String, dynamic>? ?? {};
      return OnboardingRestored(
        step: step,
        history: historyNames,
        modelState: modelMap,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stateKey);
  }

  OnboardingStep? _stepFromName(String? name) {
    if (name == null) return null;
    return OnboardingStep.values.firstWhere(
      (e) => e.name == name,
      orElse: () => OnboardingStep.splash,
    );
  }
}

class OnboardingRestored {
  const OnboardingRestored({
    required this.step,
    required this.history,
    required this.modelState,
  });

  final OnboardingStep step;
  final List<OnboardingStep> history;
  final Map<String, dynamic> modelState;
}
