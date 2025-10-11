import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/protly_theme.dart';

class PrivacyConsentScreen extends StatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  State<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends State<PrivacyConsentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _onContinuePressed() async {
    HapticFeedback.mediumImpact();

    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Fade transition to main app
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // Navigate to main app (replace with actual home screen)
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  void _onLearnMorePressed() {
    // Show info sheet about data protection
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInfoSheet(),
    );
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
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Shield icon with pulse
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(scale: _pulseScale.value, child: child);
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ProtlyTheme.vitalityGreen.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 50,
                  color: ProtlyTheme.vitalityGreen,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Main title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'You stay in control.',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(flex: 1),

            // Three bullet points
            _buildStaggeredBullets(),

            const Spacer(flex: 1),

            // Optional link
            GestureDetector(
              onTap: _onLearnMorePressed,
              child: Text(
                'Learn more about how we protect your data.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Primary CTA
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: ElevatedButton(
                onPressed: _onContinuePressed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Continue'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredBullets() {
    return Column(
      children: [
        _buildBulletPoint('You can edit or correct any scan.', 0),
        const SizedBox(height: 16),
        _buildBulletPoint('You can delete your data anytime.', 200),
        const SizedBox(height: 16),
        _buildBulletPoint('We never display calories — only proteins.', 400),
      ],
    );
  }

  Widget _buildBulletPoint(String text, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.check_circle,
                color: ProtlyTheme.vitalityGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ProtlyTheme.darkGray,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: ProtlyTheme.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ProtlyTheme.lightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How we protect your data',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              'Local Storage',
              'Your meal data is stored locally on your device. We never upload your photos to our servers.',
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              'Privacy First',
              'We only collect anonymous usage statistics to improve the app. No personal information is shared with third parties.',
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              'Full Control',
              'You can delete all your data at any time from the Settings page. Once deleted, it\'s gone forever.',
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              'No Calories',
              'We believe in focusing on what matters. Protly only shows protein data, never calorie counts.',
            ),
            const SizedBox(height: 32),
            Center(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: ProtlyTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}
