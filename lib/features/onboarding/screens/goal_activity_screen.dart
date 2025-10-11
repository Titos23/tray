import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';

class GoalActivityScreen extends StatefulWidget {
  const GoalActivityScreen({
    super.key,
    required this.model,
    this.onBack,
    required this.onContinue,
  });

  final OnboardingViewModel model;
  final VoidCallback? onBack;
  final VoidCallback onContinue;

  @override
  State<GoalActivityScreen> createState() => _GoalActivityScreenState();
}

class _GoalActivityScreenState extends State<GoalActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.model,
          builder: (context, _) {
            final canContinue =
                widget.model.goal != null && widget.model.activity != null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.onBack != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: widget.onBack,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 24),
                  Text(
                    'Tell me your goal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle('What is your main goal?'),
                  const SizedBox(height: 16),
                  _GoalCards(model: widget.model),
                  const SizedBox(height: 28),
                  const _SectionTitle('How active are you?'),
                  const SizedBox(height: 12),
                  _ActivityChips(model: widget.model),
                  const Spacer(),
                  _PrimaryButton(
                    label: 'See my goal',
                    enabled: canContinue,
                    onPressed: () {
                      if (!canContinue) return;
                      HapticFeedback.lightImpact();
                      widget.onContinue();
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.neutralText,
            fontWeight: FontWeight.w600,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class _GoalCards extends StatelessWidget {
  const _GoalCards({required this.model});

  final OnboardingViewModel model;

  static const _entries = <_GoalEntry>[
    _GoalEntry(
      type: GoalType.maintain,
      title: 'Maintain',
      description: 'Keep your current shape.',
    ),
    _GoalEntry(
      type: GoalType.gainMuscle,
      title: 'Gain muscle',
      description: 'Build lean mass.',
    ),
    _GoalEntry(
      type: GoalType.loseFat,
      title: 'Lose fat',
      description: 'Tone and slim down.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _entries.map((entry) {
        final selected = model.goal == entry.type;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              model.updateGoal(entry.type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color:
                    selected ? AppColors.vitalityGreen.withValues(alpha: 0.12) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? AppColors.vitalityGreen : AppColors.lightBorder,
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.vitalityGreen.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutralText,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedText,
                              ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: selected ? 1 : 0,
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.vitalityGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ActivityChips extends StatelessWidget {
  const _ActivityChips({required this.model});

  final OnboardingViewModel model;

  static const _entries = <_ActivityEntry>[
    _ActivityEntry(
      level: ActivityLevel.sedentary,
      label: 'Sedentary',
    ),
    _ActivityEntry(
      level: ActivityLevel.active,
      label: 'Active',
    ),
    _ActivityEntry(
      level: ActivityLevel.regular,
      label: 'Regular',
    ),
    _ActivityEntry(
      level: ActivityLevel.intense,
      label: 'Intense',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      alignment: WrapAlignment.center,
      children: _entries.map((entry) {
        final selected = model.activity == entry.level;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            model.updateActivity(entry.level);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.vitalityGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.vitalityGreen : AppColors.lightBorder,
              ),
            ),
            child: Text(
              entry.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected ? Colors.white : AppColors.neutralText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: widget.enabled && _pressed ? 0.97 : 1,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.4,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.vitalityGreen,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (widget.enabled)
                  BoxShadow(
                    color: AppColors.vitalityGreen.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalEntry {
  const _GoalEntry({
    required this.type,
    required this.title,
    required this.description,
  });

  final GoalType type;
  final String title;
  final String description;
}

class _ActivityEntry {
  const _ActivityEntry({
    required this.level,
    required this.label,
  });

  final ActivityLevel level;
  final String label;
}
