import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';

class GoalWeightScreen extends StatefulWidget {
  const GoalWeightScreen({
    super.key,
    required this.model,
    required this.onContinue,
  });

  final OnboardingViewModel model;
  final VoidCallback onContinue;

  @override
  State<GoalWeightScreen> createState() => _GoalWeightScreenState();
}

class _GoalWeightScreenState extends State<GoalWeightScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.model,
          builder: (context, _) {
            final canContinue = widget.model.sex != null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Let’s start simple 🙂',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                  ),
                  const SizedBox(height: 28),
                  _SectionTitle('You are?'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ChipButton(
                        label: 'Male',
                        selected: widget.model.sex == Sex.male,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.model.updateSex(Sex.male);
                        },
                      ),
                      const SizedBox(width: 12),
                      _ChipButton(
                        label: 'Female',
                        selected: widget.model.sex == Sex.female,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.model.updateSex(Sex.female);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _SectionTitle('Your weight?'),
                  const SizedBox(height: 12),
                  _WeightSlider(model: widget.model),
                  const SizedBox(height: 12),
                  _UnitToggle(model: widget.model),
                  const SizedBox(height: 32),
                  _SectionTitle('Your height?'),
                  const SizedBox(height: 12),
                  _HeightSlider(model: widget.model),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        widget.model.markUnknownHeight();
                      },
                      child: const Text('I don’t know'),
                    ),
                  ),
                  const Spacer(),
                  _PrimaryButton(
                    label: 'Continue',
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
            fontWeight: FontWeight.w600,
            color: AppColors.neutralText,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.vitalityGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.vitalityGreen : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? Colors.white : AppColors.neutralText,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _WeightSlider extends StatelessWidget {
  const _WeightSlider({required this.model});

  final OnboardingViewModel model;

  @override
  Widget build(BuildContext context) {
    final display = model.weightDisplay;
    final unit = model.weightUnit;
    final min = unit == WeightUnit.kg ? 40.0 : 88.0;
    final max = unit == WeightUnit.kg ? 130.0 : 286.0;
    final stepLabel = '${display.toStringAsFixed(0)} ${unit == WeightUnit.kg ? 'kg' : 'lb'}';

    return Column(
      children: [
        Text(
          stepLabel,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.vitalityGreen,
              ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.vitalityGreen,
            inactiveTrackColor: AppColors.lightBorder,
            thumbColor: AppColors.vitalityGreen,
            overlayColor:
                AppColors.vitalityGreen.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: display.clamp(min, max),
            min: min,
            max: max,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              model.updateWeight(value, unit: unit);
            },
          ),
        ),
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.model});

  final OnboardingViewModel model;

  @override
  Widget build(BuildContext context) {
    final isKg = model.weightUnit == WeightUnit.kg;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('kg'),
        Switch(
          value: !isKg,
          activeColor: AppColors.vitalityGreen,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            final nextUnit = value ? WeightUnit.lb : WeightUnit.kg;
            model.toggleWeightUnit(nextUnit);
          },
        ),
        const Text('lb'),
      ],
    );
  }
}

class _HeightSlider extends StatelessWidget {
  const _HeightSlider({required this.model});

  final OnboardingViewModel model;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AppColors.vitalityGreen,
        inactiveTrackColor: AppColors.lightBorder,
        thumbColor: AppColors.vitalityGreen,
        overlayColor: AppColors.vitalityGreen.withValues(alpha: 0.15),
      ),
      child: Column(
        children: [
          Text(
            '${model.heightCm.toStringAsFixed(0)} cm',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.neutralText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Slider(
            value: model.heightCm.clamp(140, 200),
            min: 140,
            max: 200,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              model.updateHeight(value);
            },
          ),
        ],
      ),
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
        scale: widget.enabled && _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
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
