import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/protly_theme.dart';

class CameraPermissionScreen extends StatefulWidget {
  const CameraPermissionScreen({super.key});

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseOpacity;
  bool _showModal = false;
  String _modalTitle = '';
  String _modalMessage = '';
  List<ModalButton> _modalButtons = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkExistingPermission();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseOpacity = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkExistingPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      // Case 3 – Permission previously granted (skip screen)
      _navigateToNextScreen();
    }
  }

  Future<void> _requestCameraPermission() async {
    HapticFeedback.lightImpact();

    final status = await Permission.camera.request();

    if (status.isGranted) {
      // Case 1 – Permission granted
      _showSuccessAndNavigate();
    } else if (status.isDenied) {
      // Case 2 – Permission denied
      _showDeniedModal();
    } else if (status.isPermanentlyDenied) {
      // Case 4 – Permission blocked at OS level
      _showBlockedModal();
    }
  }

  void _showSuccessAndNavigate() async {
    HapticFeedback.mediumImpact();

    // Show success message briefly
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfect 🎯 Let\'s set your daily goal.'),
          backgroundColor: ProtlyTheme.vitalityGreen,
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 800));
    _navigateToNextScreen();
  }

  void _showDeniedModal() {
    setState(() {
      _showModal = true;
      _modalTitle =
          'Without the camera, you won\'t be able to scan your meals.';
      _modalMessage = 'You can enable it later in your settings.';
      _modalButtons = [
        ModalButton(
          text: 'Try Again',
          isPrimary: true,
          onPressed: () {
            setState(() => _showModal = false);
            _requestCameraPermission();
          },
        ),
        ModalButton(
          text: 'Continue without camera',
          isPrimary: false,
          onPressed: () {
            setState(() => _showModal = false);
            _navigateToNextScreen();
          },
        ),
      ];
    });
  }

  void _showBlockedModal() {
    setState(() {
      _showModal = true;
      _modalTitle = 'Camera access is blocked.';
      _modalMessage =
          'Protly needs access to your camera to work properly. You can enable it in your device settings.';
      _modalButtons = [
        ModalButton(
          text: 'Open Settings',
          isPrimary: true,
          onPressed: () {
            openAppSettings();
            setState(() => _showModal = false);
          },
        ),
        ModalButton(
          text: 'Maybe later',
          isPrimary: false,
          onPressed: () {
            setState(() => _showModal = false);
            _navigateToNextScreen();
          },
        ),
      ];
    });
  }

  void _navigateToNextScreen() {
    if (mounted) {
      Navigator.of(context).pushNamed('/goal-weight');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ProtlyTheme.pureWhite,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Camera icon with pulse
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(opacity: _pulseOpacity.value, child: child);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ProtlyTheme.vitalityGreen,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 50,
                      color: ProtlyTheme.vitalityGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Title text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'We need your camera to scan your meals 📸',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(height: 1.4),
                  ),
                ),

                const SizedBox(height: 32),

                // Bullet points
                _buildStaggeredBullets(),

                const Spacer(flex: 2),

                // Main CTA
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: ElevatedButton(
                    onPressed: _requestCameraPermission,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text('Enable Camera'),
                  ),
                ),

                const SizedBox(height: 16),

                // Reassurance text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Protly only uses your camera to scan your meals.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),

          // Modal overlay
          if (_showModal) _buildModal(size),
        ],
      ),
    );
  }

  Widget _buildStaggeredBullets() {
    return Column(
      children: [
        _buildBulletPoint('No manual imports', 0),
        const SizedBox(height: 12),
        _buildBulletPoint('Instant results', 100),
        const SizedBox(height: 12),
        _buildBulletPoint('Your data stays private', 200),
      ],
    );
  }

  Widget _buildBulletPoint(String text, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: ProtlyTheme.vitalityGreen,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: ProtlyTheme.darkGray),
          ),
        ],
      ),
    );
  }

  Widget _buildModal(Size size) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ProtlyTheme.pureWhite,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _modalTitle,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Text(
                _modalMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ..._modalButtons.map(
                (button) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child:
                        button.isPrimary
                            ? ElevatedButton(
                              onPressed: button.onPressed,
                              child: Text(button.text),
                            )
                            : OutlinedButton(
                              onPressed: button.onPressed,
                              child: Text(button.text),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModalButton {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  ModalButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });
}
