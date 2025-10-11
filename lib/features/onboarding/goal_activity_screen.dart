import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/protly_theme.dart';

class GoalActivityScreen extends StatefulWidget {
  const GoalActivityScreen({super.key});

  @override
  State<GoalActivityScreen> createState() => _GoalActivityScreenState();
}

class _GoalActivityScreenState extends State<GoalActivityScreen> {
  String? _selectedGoal;
  String? _selectedActivity;

  final List<GoalOption> _goals = [
    GoalOption(
      emoji: '🧘',
      title: 'Maintain',
      description: 'Keep your current shape.',
      factor: 1.5,
    ),
    GoalOption(
      emoji: '🏋️',
      title: 'Gain muscle',
      description: 'Build lean mass.',
      factor: 2.0,
    ),
    GoalOption(
      emoji: '🔥',
      title: 'Lose fat',
      description: 'Tone and slim down.',
      factor: 1.8,
    ),
  ];

  final List<ActivityOption> _activities = [
    ActivityOption(emoji: '🪑', title: 'Sedentary', multiplier: 0.9),
    ActivityOption(emoji: '🚶', title: 'Active', multiplier: 1.0),
    ActivityOption(emoji: '🏋️', title: 'Regular', multiplier: 1.1),
    ActivityOption(emoji: '🏃', title: 'Intense', multiplier: 1.2),
  ];

  void _onGoalSelected(String goal) {
    setState(() => _selectedGoal = goal);
    HapticFeedback.lightImpact();
  }

  void _onActivitySelected(String activity) {
    setState(() => _selectedActivity = activity);
    HapticFeedback.lightImpact();
  }

  void _onSeeMyGoalPressed() {
    if (_selectedGoal == null || _selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both goal and activity level'),
          backgroundColor: ProtlyTheme.mediumGray,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    // Get previous screen data
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final sex = args?['sex'] as String? ?? 'Male';
    final weight = args?['weight'] as double? ?? 70.0;
    final height = args?['height'] as double? ?? 170.0;

    // Calculate protein goal
    final goalFactor =
        _goals.firstWhere((g) => g.title == _selectedGoal).factor;
    final activityMultiplier =
        _activities.firstWhere((a) => a.title == _selectedActivity).multiplier;
    final sexAdjustment = sex == 'Male' ? 1.05 : 0.95;

    final proteinGoal =
        (weight * goalFactor * activityMultiplier * sexAdjustment).round();

    Navigator.of(context).pushNamed(
      '/goal-summary',
      arguments: {
        'sex': sex,
        'weight': weight,
        'height': height,
        'goal': _selectedGoal,
        'activity': _selectedActivity,
        'proteinGoal': proteinGoal,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ProtlyTheme.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                Center(
                  child: Text(
                    'Tell me your goal 🎯',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),

                const SizedBox(height: 48),

                // Goal selection
                Text(
                  'What\'s your main goal?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                ..._goals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildGoalCard(goal),
                  ),
                ),

                const SizedBox(height: 40),

                // Activity level
                Text(
                  'How active are you?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _activities.map((activity) {
                        return _buildActivityChip(activity);
                      }).toList(),
                ),

                const SizedBox(height: 48),

                // Continue button
                ElevatedButton(
                  onPressed: _onSeeMyGoalPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('See my goal'),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalOption goal) {
    final isSelected = _selectedGoal == goal.title;

    return GestureDetector(
      onTap: () => _onGoalSelected(goal.title),
      child: AnimatedContainer(
        duration: ProtlyTheme.mediumAnimation,
        curve: ProtlyTheme.defaultCurve,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ProtlyTheme.pureWhite,
          border: Border.all(
            color:
                isSelected ? ProtlyTheme.vitalityGreen : ProtlyTheme.lightGray,
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: ProtlyTheme.vitalityGreen.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            Text(goal.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ProtlyTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: ProtlyTheme.vitalityGreen,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChip(ActivityOption activity) {
    final isSelected = _selectedActivity == activity.title;

    return GestureDetector(
      onTap: () => _onActivitySelected(activity.title),
      child: AnimatedContainer(
        duration: ProtlyTheme.shortAnimation,
        curve: ProtlyTheme.defaultCurve,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ProtlyTheme.vitalityGreen : ProtlyTheme.pureWhite,
          border: Border.all(
            color:
                isSelected ? ProtlyTheme.vitalityGreen : ProtlyTheme.lightGray,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(activity.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              activity.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    isSelected ? ProtlyTheme.pureWhite : ProtlyTheme.darkGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalOption {
  final String emoji;
  final String title;
  final String description;
  final double factor;

  GoalOption({
    required this.emoji,
    required this.title,
    required this.description,
    required this.factor,
  });
}

class ActivityOption {
  final String emoji;
  final String title;
  final double multiplier;

  ActivityOption({
    required this.emoji,
    required this.title,
    required this.multiplier,
  });
}
