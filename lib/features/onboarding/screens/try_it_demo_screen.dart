import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

class TryItDemoScreen extends StatefulWidget {
  const TryItDemoScreen({
    super.key,
    this.onBack,
    required this.onContinue,
  });

  final VoidCallback? onBack;
  final VoidCallback onContinue;

  @override
  State<TryItDemoScreen> createState() => _TryItDemoScreenState();
}

class _TryItDemoScreenState extends State<TryItDemoScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final AnimationController _interactionController;
  Timer? _ctaTimer;
  bool _ctaVisible = false;
  bool _feedbackVisible = false;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _interactionController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _feedbackVisible = true;
          });
        }
      });

    _ctaTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || _hasInteracted) return;
      setState(() => _ctaVisible = true);
    });
  }

  @override
  void dispose() {
    _ctaTimer?.cancel();
    _interactionController.dispose();
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _playInteraction() {
    HapticFeedback.selectionClick();
    setState(() {
      _feedbackVisible = false;
      _hasInteracted = true;
      _ctaVisible = true;
    });
    _interactionController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _entryController.drive(CurveTween(curve: Curves.easeIn)),
        child: SafeArea(
          child: Column(
            children: [
              if (widget.onBack != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: widget.onBack,
                    ),
                  ),
                )
              else
                const SizedBox(height: 16),
              SizedBox(height: media.size.height * 0.04),
              FadeTransition(
                opacity: _entryController.drive(
                  CurveTween(curve: const Interval(0.3, 1, curve: Curves.easeIn)),
                ),
                child: Text(
                  'Essaie',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralText,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GestureDetector(
                  onTap: _playInteraction,
                  child: Center(
                    child: _InteractivePlate(
                      floatController: _floatController,
                      interaction: _interactionController,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _feedbackVisible ? 1 : 0,
                child: Text(
                  'Simple, non ?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutralText,
                      ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: media.size.width * 0.08,
                  vertical: media.size.height * 0.04,
                ),
                child: _ContinueButton(
                  visible: _ctaVisible,
                  enabled: _hasInteracted,
                  onPressed: () {
                    if (!_hasInteracted) return;
                    HapticFeedback.lightImpact();
                    widget.onContinue();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractivePlate extends StatelessWidget {
  const _InteractivePlate({
    required this.floatController,
    required this.interaction,
  });

  final AnimationController floatController;
  final AnimationController interaction;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([floatController, interaction]),
      builder: (context, child) {
        final hover = (floatController.value - 0.5) * 12;
        final t = interaction.value;

        final halo = _segment(t, 0.05, 0.2);
        final scan = _segment(t, 0.18, 0.4);
        final grams = _segment(t, 0.35, 0.55);
        final progress = _segment(t, 0.45, 0.75) * 0.3;

        return Transform.translate(
          offset: Offset(0, hover),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200 + halo * 20,
                    height: 200 + halo * 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          AppColors.vitalityGreen.withValues(alpha: 0.12 * halo),
                    ),
                  ),
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFEFF5FF),
                            Color(0xFFE6F9ED),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60 + scan * 40,
                    child: Container(
                      width: 210,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.vitalityGreen
                            .withValues(alpha: 0.25 * scan),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 36,
                    child: Opacity(
                      opacity: grams,
                      child: Transform.translate(
                        offset: Offset(0, (1 - grams) * 16),
                        child: Text(
                          '+28 g',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.vitalityGreen,
                              ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 42,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 120,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.lightBorder.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.vitalityGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  static double _segment(double t, double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    final normalized = (t - start) / (end - start);
    return math.max(0.0, math.min(1.0, normalized));
  }
}

class _ContinueButton extends StatefulWidget {
  const _ContinueButton({
    required this.visible,
    required this.enabled,
    required this.onPressed,
  });

  final bool visible;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      offset: widget.visible ? Offset.zero : const Offset(0, 0.12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 320),
        opacity: widget.visible ? 1 : 0,
        child: GestureDetector(
          onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
          onTap: widget.enabled ? widget.onPressed : null,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: widget.enabled && _pressed ? 0.97 : 1,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: widget.enabled
                    ? AppColors.vitalityGreen
                    : AppColors.lightBorder.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (widget.enabled)
                    BoxShadow(
                      color: AppColors.vitalityGreen.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  'Activer la camera',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: widget.enabled ? Colors.white : AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


