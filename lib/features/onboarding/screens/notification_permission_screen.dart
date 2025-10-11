import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({
    super.key,
    required this.model,
    this.onBack,
    required this.onPermissionRequest,
    required this.onContinue,
  });

  final OnboardingViewModel model;
  final VoidCallback? onBack;
  final Future<PermissionStatus> Function() onPermissionRequest;
  final VoidCallback onContinue;

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _cardController;
  late final AnimationController _confettiController;
  ReminderIntensity? _selection;
  bool _isRequesting = false;
  bool _toastVisible = false;
  String _toastMessage = '';
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _selection = widget.model.reminder;
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    if (widget.model.notificationPermission == PermissionStatus.granted) {
      widget.onContinue();
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _iconController.dispose();
    _cardController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    if (_selection == null || _isRequesting) return;
    setState(() => _isRequesting = true);
    widget.model.updateReminder(_selection!);
    HapticFeedback.lightImpact();

    final status = await widget.onPermissionRequest();
    widget.model.updateNotificationPermission(status);

    if (!mounted) return;

    switch (status) {
      case PermissionStatus.granted:
        _confettiController.forward(from: 0).whenComplete(() {
          if (mounted) widget.onContinue();
        });
        break;
      case PermissionStatus.denied:
        _presentToast('No worries - you can enable notifications later.');
        Timer(const Duration(milliseconds: 1200), () {
          if (mounted) widget.onContinue();
        });
        break;
      case PermissionStatus.unknown:
        _presentToast('We\'ll remind you again soon.');
        Timer(const Duration(milliseconds: 1200), () {
          if (mounted) widget.onContinue();
        });
        break;
      case PermissionStatus.restricted:
        _presentToast('Notifications are blocked. Enable them in Settings.');
        Timer(const Duration(milliseconds: 1400), () {
          if (mounted) widget.onContinue();
        });
        break;
    }
    setState(() => _isRequesting = false);
  }

  void _presentToast(String message) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
      _toastVisible = true;
    });
    _toastTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _toastVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selection != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  _PulsingBell(controller: _iconController),
                  const SizedBox(height: 32),
                  Text(
                    'Gentle reminders to complete your bar.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _ReminderCards(
                    controller: _cardController,
                    selection: _selection,
                    onSelect: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selection = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'You can change this anytime.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                  const Spacer(),
                  _EnableButton(
                    enabled: canContinue && !_isRequesting,
                    onTap: _requestPermission,
                    label: _isRequesting ? 'Requesting...' : 'Enable my reminders',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(_confettiController.value),
                  );
                },
              ),
            ),
          ),
          if (_toastVisible)
            Positioned(
              bottom: 80,
              left: 24,
              right: 24,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkText,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _toastMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PulsingBell extends StatelessWidget {
  const _PulsingBell({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = math.sin(controller.value * 2 * math.pi) * 0.1 + 0.9;
        return Opacity(
          opacity: value.clamp(0.8, 1.0),
          child: Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: AppColors.vitalityGreen,
          ),
        );
      },
    );
  }
}

class _ReminderCards extends StatelessWidget {
  const _ReminderCards({
    required this.controller,
    required this.selection,
    required this.onSelect,
  });

  final AnimationController controller;
  final ReminderIntensity? selection;
  final ValueChanged<ReminderIntensity> onSelect;

  static const _entries = <_ReminderEntry>[
    _ReminderEntry(
      intensity: ReminderIntensity.light,
      title: 'Light',
      description: 'One reminder per day',
    ),
    _ReminderEntry(
      intensity: ReminderIntensity.standard,
      title: 'Standard',
      description: 'Three reminders per day',
    ),
    _ReminderEntry(
      intensity: ReminderIntensity.silent,
      title: 'Silent',
      description: 'Reminders without sound',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _entries.length; i++)
          FadeTransition(
            opacity: controller.drive(
              CurveTween(
                curve: Interval(0.1 * i, 0.6 + 0.1 * i, curve: Curves.easeOut),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => onSelect(_entries[i].intensity),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: selection == _entries[i].intensity
                        ? const Color(0xFFE6F9ED)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selection == _entries[i].intensity
                          ? AppColors.vitalityGreen
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _entries[i].title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutralText,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _entries[i].description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.mutedText,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: selection == _entries[i].intensity ? 1 : 0,
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.vitalityGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReminderEntry {
  const _ReminderEntry({
    required this.intensity,
    required this.title,
    required this.description,
  });

  final ReminderIntensity intensity;
  final String title;
  final String description;
}

class _EnableButton extends StatefulWidget {
  const _EnableButton({
    required this.enabled,
    required this.onTap,
    required this.label,
  });

  final bool enabled;
  final VoidCallback onTap;
  final String label;

  @override
  State<_EnableButton> createState() => _EnableButtonState();
}

class _EnableButtonState extends State<_EnableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: widget.enabled && _pressed ? 0.97 : 1,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.4,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.vitalityGreen,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                if (widget.enabled)
                  BoxShadow(
                    color: AppColors.vitalityGreen.withValues(alpha: 0.2),
                    blurRadius: 18,
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

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);

  final double t;

  final List<_ConfettiPiece> _pieces = List.generate(
    14,
    (i) => _ConfettiPiece(
      angle: (i / 14) * 2 * math.pi,
      baseOffset: Offset(
        math.cos((i / 14) * 2 * math.pi) * 60,
        -i * 8,
      ),
      color: i.isEven ? AppColors.vitalityGreen : const Color(0xFF7DD3FC),
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0) return;
    final center = size.center(const Offset(0, -120));
    for (final piece in _pieces) {
      final easedInput = (t + piece.offsetSeed).clamp(0.0, 1.0);
      final progress = Curves.easeOut.transform(easedInput);
      final dx = piece.baseOffset.dx * (0.5 + progress);
      final dy = piece.baseOffset.dy * (0.5 + progress) + progress * 140;
      final position = center.translate(dx, dy);
      final rotation = piece.angle + progress * math.pi;
      final paint = Paint()
        ..color =
            piece.color.withValues(alpha: (1 - easedInput).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 8, height: 14),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      (t - oldDelegate.t).abs() > 0.01;
}

class _ConfettiPiece {
  _ConfettiPiece({
    required this.angle,
    required this.baseOffset,
    required this.color,
  }) : offsetSeed = math.Random(angle.hashCode).nextDouble() * 0.3;

  final double angle;
  final Offset baseOffset;
  final Color color;
  final double offsetSeed;
}




