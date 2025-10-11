import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

class WelcomeValuePropScreen extends StatefulWidget {
  const WelcomeValuePropScreen({
    super.key,
    required this.onTryNow,
    required this.onSignIn,
  });

  final VoidCallback onTryNow;
  final VoidCallback onSignIn;

  @override
  State<WelcomeValuePropScreen> createState() =>
      _WelcomeValuePropScreenState();
}

class _WelcomeValuePropScreenState extends State<WelcomeValuePropScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _demoController;
  bool _ctaVisible = false;
  bool _secondaryVisible = false;
  bool _sheetVisible = false;
  bool _headlineVisible = false;
  Timer? _ctaTimer;
  Timer? _secondaryTimer;
  Timer? _headlineTimer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _demoController = AnimationController(
      duration: const Duration(milliseconds: 1900),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _demoController.repeat();
    });

    _ctaTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _ctaVisible = true);
    });

    _secondaryTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _secondaryVisible = true);
    });

    _headlineTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() => _headlineVisible = true);
    });
  }

  @override
  void dispose() {
    _ctaTimer?.cancel();
    _secondaryTimer?.cancel();
    _headlineTimer?.cancel();
    _logoController.dispose();
    _demoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.05,
                    left: size.width * 0.05,
                  ),
                  child: _AnimatedLogo(controller: _logoController),
                ),
                const SizedBox(height: 12),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _headlineVisible ? 1 : 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 12),
                      child: Text(
                        'One photo gets you your proteins, no hassle.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutralText,
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.02,
                          ),
                          child: _DemoLoop(
                            controller: _demoController,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                  ),
                  child: _PrimaryCta(
                    visible: _ctaVisible,
                    label: 'Essayer maintenant',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onTryNow();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.05),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _secondaryVisible ? 1 : 0,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onSignIn();
                        setState(() => _sheetVisible = true);
                      },
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w500,
                                ),
                            children: const [
                              TextSpan(text: 'As-tu deja un compte ? '),
                              TextSpan(
                                text: 'Se connecter',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_sheetVisible) ...[
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: 1,
              child: GestureDetector(
                onTap: () => setState(() => _sheetVisible = false),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            _SignInSheet(
              onDismiss: () => setState(() => _sheetVisible = false),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    return FadeTransition(
      opacity: controller,
      child: SlideTransition(
        position: slide,
        child: Image.asset(
          'Logoprotly.png',
          width: MediaQuery.of(context).size.width * 0.12,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatefulWidget {
  const _PrimaryCta({
    required this.visible,
    required this.label,
    required this.onPressed,
  });

  final bool visible;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<_PrimaryCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSlide(
      offset: widget.visible ? Offset.zero : const Offset(0, 0.1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: widget.visible ? 1 : 0,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 110),
            scale: _pressed ? 0.97 : 1.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.vitalityGreen,
                borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.vitalityGreen
                            .withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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

class _SignInSheet extends StatefulWidget {
  const _SignInSheet({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<_SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends State<_SignInSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        )),
        child: FadeTransition(
          opacity: _controller,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            height: media.size.height * 0.43,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Se connecter',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                _SignInButton(
                  label: 'Continuer avec Apple',
                  background: Colors.black,
                  textColor: Colors.white,
                  onTap: widget.onDismiss,
                ),
                const SizedBox(height: 12),
                _SignInButton(
                  label: 'Continuer avec Google',
                  background: Colors.white,
                  textColor: AppColors.neutralText,
                  borderColor: AppColors.lightBorder,
                  onTap: widget.onDismiss,
                ),
                const SizedBox(height: 12),
                _SignInButton(
                  label: 'Continuer avec un email',
                  background: Colors.transparent,
                  textColor: AppColors.neutralText,
                  borderColor: AppColors.lightBorder,
                  onTap: widget.onDismiss,
                ),
                const Spacer(),
                Text(
                  'En continuant, tu acceptes les Conditions generales et la Politique de confidentialite.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.label,
    required this.background,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: background,
          border: borderColor != null
              ? Border.all(color: borderColor!)
              : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _DemoLoop extends StatelessWidget {
  const _DemoLoop({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final flashOpacity = _pulseSegment(t, start: 0.28, end: 0.36);
        final haloOpacity = _pulseSegment(t, start: 0.2, end: 0.28);
        final analyzedOpacity = t.clamp(0.35, 0.55).map(0.35, 0.55);
        final valueOpacity = t.clamp(0.45, 0.65).map(0.45, 0.65);
        final progress = t.clamp(0.45, 0.7).map(0.45, 0.7) * 0.33;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Stack(
            children: [
              Align(
                alignment: const Alignment(-0.6, -0.1),
                child: _PlateIllustration(
                  glowOpacity: haloOpacity,
                ),
              ),
              Align(
                alignment: const Alignment(0.5, -0.1),
                child: _PhoneIllustration(
                  flashOpacity: flashOpacity,
                  analyzedOpacity: analyzedOpacity,
                ),
              ),
              Align(
                alignment: const Alignment(0.4, -0.65),
                child: Opacity(
                  opacity: valueOpacity,
                  child: Transform.translate(
                    offset: Offset(0, (1 - valueOpacity) * 20),
                    child: Text(
                      '+28 g',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.vitalityGreen,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.85),
                child: _ProgressBar(
                  progress: progress,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static double _pulseSegment(double t, {required double start, required double end}) {
    if (t < start || t > end) return 0;
    final middle = (start + end) / 2;
    final distance = (t - middle).abs();
    final width = (end - start) / 2;
    return (1 - (distance / width)).clamp(0.0, 1.0);
  }
}

class _PlateIllustration extends StatelessWidget {
  const _PlateIllustration({required this.glowOpacity});

  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 120 + glowOpacity * 12,
          height: 120 + glowOpacity * 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.vitalityGreen
                .withValues(alpha: glowOpacity * 0.15),
          ),
        ),
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF9F9F9),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.lightBorder),
                ),
              ),
              Positioned(
                top: 30,
                child: Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.vitalityGreen.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneIllustration extends StatelessWidget {
  const _PhoneIllustration({
    required this.flashOpacity,
    required this.analyzedOpacity,
  });

  final double flashOpacity;
  final double analyzedOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 92,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
        ),
        Container(
          width: 78,
          height: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
                    border: Border.all(
                      color: AppColors.vitalityGreen
                          .withValues(alpha: 0.2 + flashOpacity * 0.6),
                      width: 2,
                    ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEFF5FF),
                          const Color(0xFFEFF5FF)
                              .withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                ),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: analyzedOpacity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE6F9ED),
                          Color(0xFFD7F5E3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.vitalityGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: flashOpacity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: AppColors.vitalityGreen.withValues(alpha: 0.15),
            ),
          ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.lightBorder.withValues(alpha: 0.35),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 180 * progress,
          decoration: BoxDecoration(
            color: AppColors.vitalityGreen,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

extension on double {
  double map(double min, double max) {
    return math.max(0.0, math.min(1.0, (this - min) / (max - min)));
  }
}

