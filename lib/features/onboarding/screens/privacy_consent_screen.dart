import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';

class PrivacyConsentScreen extends StatefulWidget {
  const PrivacyConsentScreen({
    super.key,
    required this.model,
    this.onBack,
    required this.onOpenSettings,
    required this.onFinish,
  });

  final OnboardingViewModel model;
  final VoidCallback? onBack;
  final VoidCallback onOpenSettings;
  final VoidCallback onFinish;

  @override
  State<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends State<PrivacyConsentScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _iconController;
  bool _infoSheetVisible = false;
  bool _isExiting = false;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _entryController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _finish() {
    if (_isExiting) return;
    _isExiting = true;
    HapticFeedback.lightImpact();
    _entryController.reverse();
    _exitTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      widget.onFinish();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cameraDenied = widget.model.cameraPermission == PermissionStatus.denied ||
        widget.model.cameraPermission == PermissionStatus.restricted;
    final notificationsDenied =
        widget.model.notificationPermission == PermissionStatus.denied;

    final title = cameraDenied
        ? 'We will need your camera later.'
        : 'You stay in control.';

    final bullets = cameraDenied
        ? const [
            'Protly works best when you can scan your meals.',
            'You can allow camera access anytime in Settings.',
          ]
        : const [
            'You can edit or correct any scan.',
            'You can delete your data anytime.',
            'We never display calories, only proteins.',
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _entryController,
            child: SafeArea(
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
                      const SizedBox(height: 16),
                    if (widget.model.isOffline) ...[
                      const SizedBox(height: 12),
                      _OfflineBanner(controller: _entryController),
                    ] else
                      const SizedBox(height: 32),
                    _PulsingIcon(controller: _iconController),
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _entryController.drive(
                        CurveTween(curve: const Interval(0.2, 0.5)),
                      ),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _BulletColumn(
                      bullets: bullets,
                      controller: _entryController,
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _entryController.drive(
                        CurveTween(curve: const Interval(0.5, 0.8)),
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _infoSheetVisible = true),
                        child: Text(
                          'Learn more about how we protect your data.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.mutedText,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (notificationsDenied && !cameraDenied)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Notifications are off. You can enable them later in Settings.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedText,
                              ),
                        ),
                      ),
                    _PrimaryButton(
                      label: cameraDenied ? 'Continue without camera' : 'Continue',
                      onPressed: _finish,
                      enabled: !widget.model.isOffline,
                    ),
                    if (cameraDenied)
                      TextButton(
                        onPressed: widget.onOpenSettings,
                        child: const Text('Open Settings'),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (_infoSheetVisible)
            _InfoSheet(
              onDismiss: () => setState(() => _infoSheetVisible = false),
            ),
        ],
      ),
    );
  }
}

class _PulsingIcon extends StatelessWidget {
  const _PulsingIcon({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final scale = math.sin(controller.value * 2 * math.pi) * 0.05 + 1.0;
        return Transform.scale(
          scale: scale,
          child: Icon(
            Icons.verified_user_outlined,
            size: 48,
            color: AppColors.vitalityGreen,
          ),
        );
      },
    );
  }
}

class _BulletColumn extends StatelessWidget {
  const _BulletColumn({required this.bullets, required this.controller});

  final List<String> bullets;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < bullets.length; i++)
          FadeTransition(
            opacity: controller.drive(
              CurveTween(
                curve: Interval(
                  0.3 + i * 0.1,
                  0.6 + i * 0.1,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.vitalityGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bullets[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutralText,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.enabled,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;

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
        scale: widget.enabled && _pressed ? 0.97 : 1.0,
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

class _InfoSheet extends StatefulWidget {
  const _InfoSheet({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<_InfoSheet> createState() => _InfoSheetState();
}

class _InfoSheetState extends State<_InfoSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 260),
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
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onDismiss,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: 0.1,
              child: Container(color: Colors.black),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _controller.drive(
                Tween(begin: const Offset(0, 0.2), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: FadeTransition(
                opacity: _controller,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(
                        'How Protly protects your data',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '- Encrypted scans stored on-device first.\n'
                        '- You can trigger deletion at any time from Settings.\n'
                        '- We never sell or share personal data.\n'
                        '- Only protein insights are displayed to limit pressure.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.neutralText,
                              height: 1.4,
                            ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: widget.onDismiss,
                          child: const Text('Close'),
                        ),
                      ),
                    ],
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

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: controller.drive(
        Tween(begin: const Offset(0, -0.3), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutBack)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4D6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off, color: Color(0xFFB08900)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You are offline. Some features may be limited.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7A5C00),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


