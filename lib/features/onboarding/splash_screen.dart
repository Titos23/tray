import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/protly_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Logo animation (0.5s)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Text animation (0.3s delay, then 0.4s duration)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Pulse animation (0.3s)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.03), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    // Start logo animation immediately
    _logoController.forward();

    // Start text animation after 300ms
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _textController.forward();

    // Start pulse after logo and text are done
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _pulseController.forward();

    // Wait for pulse to complete, then navigate
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      // Fade out transition
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProtlyTheme.pureWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade-in and scale animation
            AnimatedBuilder(
              animation: Listenable.merge([_logoController, _pulseController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScale.value * _pulseScale.value,
                  child: Opacity(opacity: _logoOpacity.value, child: child),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.width * 0.35,
                decoration: BoxDecoration(
                  color: ProtlyTheme.vitalityGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: ProtlyTheme.pureWhite,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Text with fade-in and slide-up animation
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return SlideTransition(
                  position: _textSlide,
                  child: Opacity(opacity: _textOpacity.value, child: child),
                );
              },
              child: Text(
                'Protly',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: ProtlyTheme.darkGray,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
