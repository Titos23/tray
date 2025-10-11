import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/protly_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _animationController;
  late AnimationController _ctaController;
  late AnimationController _secondaryController;

  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _ctaOpacity;
  late Animation<Offset> _ctaSlide;
  late Animation<double> _secondaryOpacity;

  bool _showSignInSheet = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Logo fade in from left (0.5s)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Animation loop controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // CTA button animation (fade up + bounce)
    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _ctaOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctaController, curve: Curves.easeInOut));

    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctaController, curve: Curves.elasticOut),
    );

    // Secondary text animation
    _secondaryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _secondaryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _secondaryController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    // 0.0s → Logo fades in
    _logoController.forward();

    // 1.0s → CTA fades up
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) _ctaController.forward();

    // 1.5s → Secondary text appears
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _secondaryController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _animationController.dispose();
    _ctaController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  void _onTryNowPressed() async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Scale animation
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      Navigator.of(context).pushNamed('/try-demo');
    }
  }

  void _showSignInBottomSheet() {
    setState(() {
      _showSignInSheet = true;
    });
  }

  void _hideSignInBottomSheet() {
    setState(() {
      _showSignInSheet = false;
    });
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
                // Logo at top-left
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _logoSlide,
                      child: Opacity(opacity: _logoOpacity.value, child: child),
                    );
                  },
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: size.width * 0.05,
                        top: size.height * 0.05,
                      ),
                      child: Container(
                        width: size.width * 0.15,
                        height: size.width * 0.15,
                        decoration: BoxDecoration(
                          color: ProtlyTheme.vitalityGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_menu,
                            color: ProtlyTheme.pureWhite,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Animation block (center area)
                _buildAnimationBlock(size),

                const Spacer(flex: 1),

                // Primary CTA
                AnimatedBuilder(
                  animation: _ctaController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _ctaSlide,
                      child: Opacity(opacity: _ctaOpacity.value, child: child),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                    child: GestureDetector(
                      onTapDown: (_) {
                        HapticFeedback.lightImpact();
                      },
                      child: ElevatedButton(
                        onPressed: _onTryNowPressed,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 56),
                        ),
                        child: const Text('Essayer maintenant'),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Secondary action
                AnimatedBuilder(
                  animation: _secondaryController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _secondaryOpacity.value,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: _showSignInBottomSheet,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'As-tu déjà un compte ? '),
                            TextSpan(
                              text: 'Se connecter',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                decoration: TextDecoration.underline,
                                color: ProtlyTheme.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Sign-in bottom sheet
          if (_showSignInSheet) _buildSignInSheet(size),
        ],
      ),
    );
  }

  Widget _buildAnimationBlock(Size size) {
    return Container(
      width: size.width * 0.8,
      height: size.height * 0.25,
      decoration: BoxDecoration(
        color: ProtlyTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Simple looping animation simulation
          final progress = _animationController.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Phone outline
              Icon(
                Icons.phone_android,
                size: 80,
                color: ProtlyTheme.darkGray.withOpacity(0.3 + progress * 0.7),
              ),
              // Flash effect
              if (progress > 0.3 && progress < 0.4)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ProtlyTheme.vitalityGreen.withOpacity(0.3),
                  ),
                ),
              // Protein value
              if (progress > 0.5)
                Positioned(
                  bottom: 40,
                  child: Text(
                    '+28 g',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: ProtlyTheme.vitalityGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSignInSheet(Size size) {
    return GestureDetector(
      onTap: _hideSignInBottomSheet,
      child: Container(
        color: Colors.black.withOpacity(0.05),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent tap from closing sheet
            child: Container(
              height: size.height * 0.45,
              decoration: const BoxDecoration(
                color: ProtlyTheme.pureWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ProtlyTheme.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Se connecter',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 32),
                  // Sign-in buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildSignInButton(
                          context,
                          'Continuer avec Apple',
                          Icons.apple,
                          ProtlyTheme.black,
                          ProtlyTheme.pureWhite,
                        ),
                        const SizedBox(height: 12),
                        _buildSignInButton(
                          context,
                          'Continuer avec Google',
                          Icons.g_mobiledata,
                          ProtlyTheme.pureWhite,
                          ProtlyTheme.darkGray,
                          borderColor: ProtlyTheme.lightGray,
                        ),
                        const SizedBox(height: 12),
                        _buildSignInButton(
                          context,
                          'Continuer avec Email',
                          Icons.email_outlined,
                          ProtlyTheme.pureWhite,
                          ProtlyTheme.darkGray,
                          borderColor: ProtlyTheme.lightGray,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(
    BuildContext context,
    String text,
    IconData icon,
    Color backgroundColor,
    Color textColor, {
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border:
            borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // Handle sign-in
          },
          borderRadius: BorderRadius.circular(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
