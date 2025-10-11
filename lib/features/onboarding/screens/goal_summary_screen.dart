import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';

class GoalSummaryScreen extends StatefulWidget {
  const GoalSummaryScreen({
    super.key,
    required this.model,
    required this.onContinue,
  });

  final OnboardingViewModel model;
  final VoidCallback onContinue;

  @override
  State<GoalSummaryScreen> createState() => _GoalSummaryScreenState();
}

class _GoalSummaryScreenState extends State<GoalSummaryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hapticPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();

    _controller.addListener(() {
      if (!_hapticPlayed && _controller.value > 0.55) {
        _hapticPlayed = true;
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.model.computeProteinGoal();
    final approxPrefix = summary.approximate ? '≈ ' : '';
    final mainValue =
        '$approxPrefix${summary.grams.toStringAsFixed(0)} g of protein per day';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _StepProgress(progress: _controller.value),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _controller.drive(
                      CurveTween(curve: const Interval(0.2, 0.6)),
                    ),
                    child: Text(
                      'Here’s your daily goal 🎯',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.darkText,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _controller.drive(
                      CurveTween(curve: const Interval(0.35, 0.9)),
                    ),
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _controller.drive(
                            CurveTween(curve: const Interval(0.35, 0.9)),
                          ),
                          child: Text(
                            mainValue,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neutralText,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (summary.subtitle != null)
                          Text(
                            summary.subtitle!,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.mutedText,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PulseRing(
                    progress: _controller.value,
                    fallback: summary.fallback,
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _controller.drive(
                      CurveTween(curve: const Interval(0.6, 1.0)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          summary.fallback
                              ? 'We’ll adjust once you add more details.'
                              : 'You’re all set 💪 We’ll help you get there.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.neutralText),
                        ),
                        if (summary.note != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            summary.note!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.mutedText),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  _PrimaryButton(
                    onPressed: () {
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

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'Step 2 of 2',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText,
                ),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (progress.clamp(0.0, 1.0)),
            minHeight: 4,
            backgroundColor:
                AppColors.lightBorder.withValues(alpha: 0.4),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.vitalityGreen),
          ),
        ),
      ],
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress, required this.fallback});

  final double progress;
  final bool fallback;

  @override
  Widget build(BuildContext context) {
    final pulse = (progress - 0.5).clamp(0.0, 0.5) * 2;
    final scale = 0.9 + pulse * 0.15;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.vitalityGreen.withValues(alpha: 0.2),
            width: 8,
          ),
        ),
        child: Center(
          child: Icon(
            fallback ? Icons.flag_outlined : Icons.check_circle,
            color: AppColors.vitalityGreen,
            size: 48,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.97 : 1,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.vitalityGreen,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.vitalityGreen.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Continue',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
