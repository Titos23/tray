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
    final display = weightDisplay;
    weightUnit = nextUnit;
    updateWeight(display, unit: nextUnit);
  }

  void updateHeight(double value) {
    if ((heightCm - value).abs() < 0.5) return;
    heightCm = value;
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

    var grams = _weightKg * baseFactor * activityMultiplier * sexAdjustment;
    grams = math.max(0, grams);
    final rounded = grams.clamp(40, 240);
    final roundedInt = rounded.roundToDouble();

    final isHigh = roundedInt > 180;

    return ProteinGoalSummary(
      grams: roundedInt,
      approximate: false,
      fallback: false,
      highTarget: isHigh,
      subtitle: 'About 1 g per lb of body weight.',
      note: isHigh ? 'That\'s a strong goal; you can tweak it anytime.' : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sex': sex?.name,
      'goal': goal?.name,
      'activity': activity?.name,
      'reminder': reminder?.name,
      'cameraPermission': cameraPermission.name,
      'notificationPermission': notificationPermission.name,
      'weightUnit': weightUnit.name,
      'weightKg': _weightKg,
      'heightCm': heightCm,
      'isOffline': isOffline,
    };
  }

  void restoreFromMap(Map<String, dynamic> map) {
    sex = _enumFromName(Sex.values, map['sex'] as String?);
    goal = _enumFromName(GoalType.values, map['goal'] as String?);
    activity = _enumFromName(ActivityLevel.values, map['activity'] as String?);
    reminder =
        _enumFromName(ReminderIntensity.values, map['reminder'] as String?);
    cameraPermission = _enumFromName(
          PermissionStatus.values,
          map['cameraPermission'] as String?,
        ) ??
        PermissionStatus.unknown;
    notificationPermission = _enumFromName(
          PermissionStatus.values,
          map['notificationPermission'] as String?,
        ) ??
        PermissionStatus.unknown;
    weightUnit = _enumFromName(WeightUnit.values, map['weightUnit'] as String?) ??
        WeightUnit.kg;
    final storedWeight = (map['weightKg'] as num?)?.toDouble();
    if (storedWeight != null && storedWeight > 0) {
      _weightKg = storedWeight;
    }
    final storedHeight = (map['heightCm'] as num?)?.toDouble();
    if (storedHeight != null && storedHeight > 0) {
      heightCm = storedHeight;
    }
    isOffline = map['isOffline'] as bool? ?? false;
    notifyListeners();
  }

  T? _enumFromName<T>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value is Enum && value.name == name) {
        return value;
      }
    }
    return null;
  }

  static double _kgToLb(double kg) => kg * 2.20462;

  static double _lbToKg(double lb) => lb / 2.20462;
}
