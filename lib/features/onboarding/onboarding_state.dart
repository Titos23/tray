import 'dart:math' as math;

import 'package:flutter/foundation.dart';

enum Sex { male, female }

enum WeightUnit { kg, lb }

enum GoalType { maintain, gainMuscle, loseFat }

enum ActivityLevel { sedentary, active, regular, intense }

enum PermissionStatus { unknown, granted, denied, restricted }

enum ReminderIntensity { light, standard, silent }

class ProteinGoalSummary {
  const ProteinGoalSummary({
    required this.grams,
    required this.approximate,
    required this.fallback,
    required this.highTarget,
    this.subtitle,
    this.note,
  });

  final double grams;
  final bool approximate;
  final bool fallback;
  final bool highTarget;
  final String? subtitle;
  final String? note;
}

class OnboardingViewModel extends ChangeNotifier {
  Sex? sex;
  GoalType? goal;
  ActivityLevel? activity;
  ReminderIntensity? reminder;

  PermissionStatus cameraPermission = PermissionStatus.unknown;
  PermissionStatus notificationPermission = PermissionStatus.unknown;

  bool heightKnown = true;
  bool isOffline = false;

  WeightUnit weightUnit = WeightUnit.kg;
  double _weightKg = 70;
  double heightCm = 170;

  double get weightKg => _weightKg;

  double get weightDisplay =>
      weightUnit == WeightUnit.kg ? _weightKg : _kgToLb(_weightKg);

  void updateSex(Sex value) {
    if (sex == value) return;
    sex = value;
    notifyListeners();
  }

  void updateGoal(GoalType value) {
    if (goal == value) return;
    goal = value;
    notifyListeners();
  }

  void updateActivity(ActivityLevel value) {
    if (activity == value) return;
    activity = value;
    notifyListeners();
  }

  void updateReminder(ReminderIntensity value) {
    if (reminder == value) return;
    reminder = value;
    notifyListeners();
  }

  void updateWeight(double value, {required WeightUnit unit}) {
    final kgValue = unit == WeightUnit.kg ? value : _lbToKg(value);
    if ((kgValue - _weightKg).abs() < 0.01) return;
    _weightKg = kgValue;
    notifyListeners();
  }

  void toggleWeightUnit(WeightUnit nextUnit) {
    if (weightUnit == nextUnit) return;
    weightUnit = nextUnit;
    notifyListeners();
  }

  void updateHeight(double value) {
    if ((heightCm - value).abs() < 0.5) return;
    heightCm = value;
    heightKnown = true;
    notifyListeners();
  }

  void markUnknownHeight() {
    heightKnown = false;
    heightCm = 170;
    notifyListeners();
  }

  void updateCameraPermission(PermissionStatus status) {
    if (cameraPermission == status) return;
    cameraPermission = status;
    notifyListeners();
  }

  void updateNotificationPermission(PermissionStatus status) {
    if (notificationPermission == status) return;
    notificationPermission = status;
    notifyListeners();
  }

  ProteinGoalSummary computeProteinGoal() {
    if (sex == null || goal == null || activity == null) {
      return const ProteinGoalSummary(
        grams: 130,
        approximate: true,
        fallback: true,
        highTarget: false,
        subtitle:
            'We\'ll start with an average goal (130 g). You can edit it later.',
      );
    }

    if (!heightKnown) {
      return const ProteinGoalSummary(
        grams: 120,
        approximate: true,
        fallback: false,
        highTarget: false,
        subtitle: 'You can adjust this later in your profile.',
      );
    }

    final baseFactor = switch (goal!) {
      GoalType.maintain => 1.5,
      GoalType.gainMuscle => 2.0,
      GoalType.loseFat => 1.8,
    };

    final activityMultiplier = switch (activity!) {
      ActivityLevel.sedentary => 0.9,
      ActivityLevel.active => 1.0,
      ActivityLevel.regular => 1.1,
      ActivityLevel.intense => 1.2,
    };

    final sexAdjustment = switch (sex!) {
      Sex.male => 1.05,
      Sex.female => 0.95,
    };

    var grams =
        _weightKg * baseFactor * activityMultiplier * sexAdjustment;
    grams = math.max(0, grams);
    final rounded = (grams).clamp(40, 240);
    final roundedInt = (rounded).roundToDouble();

    final isHigh = roundedInt > 180;

    return ProteinGoalSummary(
      grams: roundedInt,
      approximate: false,
      fallback: false,
      highTarget: isHigh,
      subtitle: '≈ 1 g per lb of body weight.',
      note: isHigh ? 'That\'s a strong goal — you can tweak it anytime.' : null,
    );
  }

  static double _kgToLb(double kg) => kg * 2.20462;

  static double _lbToKg(double lb) => lb / 2.20462;
}
