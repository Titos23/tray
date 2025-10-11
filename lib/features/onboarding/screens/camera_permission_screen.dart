import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';

class CameraPermissionScreen extends StatefulWidget {
  const CameraPermissionScreen({
    super.key,
    required this.model,
    required this.onPermissionRequest,
    required this.onContinue,
    required this.onOpenSettings,
  });

  final OnboardingViewModel model;
  final Future<PermissionStatus> Function() onPermissionRequest;
  final VoidCallback onContinue;
  final VoidCallback onOpenSettings;

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _bulletsController;
  bool _isRequesting = false;
  bool _showDeniedModal = false;
  bool _showRestrictedModal = false;
  String? _successMessage;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _bulletsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    if (widget.model.cameraPermission == PermissionStatus.restricted) {
      _showRestrictedModal = true;
    }
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    _iconController.dispose();
    _bulletsController.dispose();
    super.dispose();
  }

  Future<void> _handleRequest() async {
    if (_isRequesting) return;
    setState(() {
      _isRequesting = true;
      _successMessage = null;
    });
    final result = await widget.onPermissionRequest();
    widget.model.updateCameraPermission(result);

    if (!mounted) return;

    switch (result) {
      case PermissionStatus.granted:
        HapticFeedback.mediumImpact();
        setState(() {
          _successMessage = 'Parfait ! Réglons ton objectif.';
        });
        _successTimer = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          widget.onContinue();
        });
        break;
      case PermissionStatus.denied:
        HapticFeedback.lightImpact();
        setState(() => _showDeniedModal = true);
        break;
      case PermissionStatus.restricted:
        HapticFeedback.lightImpact();
        setState(() => _showRestrictedModal = true);
        break;
      case PermissionStatus.unknown:
        break;
    }
    setState(() => _isRequesting = false);
  }

  void _continueWithoutCamera() {
    widget.model.updateCameraPermission(PermissionStatus.denied);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 32),
                  _PulsingCameraIcon(controller: _iconController),
                  const SizedBox(height: 32),
                  Text(
                    'We need your camera to scan your meals 📷',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _BulletList(controller: _bulletsController),
                  const Spacer(),
                  _PrimaryButton(
                    label: _isRequesting ? 'Demande en cours...' : 'Enable Camera',
                    loading: _isRequesting,
                    onPressed: _handleRequest,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Protly only uses your camera to scan your meals.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_successMessage != null)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.04),
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        _successMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.neutralText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_showDeniedModal)
            _PermissionModal(
              title: 'Without the camera, you won\'t be able to scan your meals.',
              subtitle: 'You can enable it later in your settings.',
              primaryLabel: 'Try Again',
              secondaryLabel: 'Continue without camera',
              onPrimary: () {
                setState(() => _showDeniedModal = false);
                _handleRequest();
              },
              onSecondary: () {
                setState(() => _showDeniedModal = false);
                _continueWithoutCamera();
              },
            ),
          if (_showRestrictedModal)
            _PermissionModal(
              title: 'Camera access is blocked.',
              subtitle:
                  'Protly needs access to your camera to work properly. You can enable it in your device settings.',
              primaryLabel: 'Open Settings',
              secondaryLabel: 'Maybe later',
              onPrimary: () {
                setState(() => _showRestrictedModal = false);
                widget.onOpenSettings();
              },
              onSecondary: () {
                setState(() => _showRestrictedModal = false);
                _continueWithoutCamera();
              },
            ),
        ],
      ),
    );
  }
}

class _PulsingCameraIcon extends StatelessWidget {
  const _PulsingCameraIcon({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = math.sin(controller.value * 2 * math.pi) * 0.1 + 0.9;
        final opacity = math.max(0.8, math.min(1.0, value));
        return Opacity(
          opacity: opacity,
          child: Icon(
            Icons.camera_alt_outlined,
            size: 48,
            color: AppColors.vitalityGreen,
          ),
        );
      },
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final items = const [
      'No manual imports',
      'Instant results',
      'Your data stays private',
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          FadeTransition(
            opacity: controller.drive(
              CurveTween(
                curve: Interval(
                  0.1 * i,
                  0.6 + 0.1 * i,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.vitalityGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    items[i],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutralText,
                          fontWeight: FontWeight.w500,
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
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

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
      onTap: widget.loading ? null : () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        scale: _pressed ? 0.97 : 1.0,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.vitalityGreen,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.vitalityGreen.withValues(alpha: 0.24),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.label,
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

class _PermissionModal extends StatelessWidget {
  const _PermissionModal({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.2),
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutralText,
                    ),
              ),
              const SizedBox(height: 24),
              _DialogButton(
                label: primaryLabel,
                filled: true,
                onTap: onPrimary,
              ),
              const SizedBox(height: 12),
              _DialogButton(
                label: secondaryLabel,
                filled: false,
                onTap: onSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: filled ? AppColors.vitalityGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: filled
              ? null
              : Border.all(
                  color: AppColors.lightBorder,
                ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: filled ? Colors.white : AppColors.neutralText,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
