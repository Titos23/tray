import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/protly_theme.dart';

class TryDemoScreen extends StatefulWidget {
  const TryDemoScreen({super.key});

  @override
  State<TryDemoScreen> createState() => _TryDemoScreenState();
}

class _TryDemoScreenState extends State<TryDemoScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _plateController;
  late AnimationController _breathingController;
  late AnimationController _scanController;
  late AnimationController _resultController;
  late AnimationController _progressController;
  late AnimationController _ctaController;

  late Animation<double> _headerOpacity;
  late Animation<double> _plateScale;
  late Animation<double> _glowOpacity;
  late Animation<double> _scanProgress;
  late Animation<double> _resultOpacity;
  late Animation<Offset> _resultSlide;
  late Animation<double> _progressValue;
  late Animation<double> _ctaOpacity;

  bool _hasInteracted = false;
  bool _showCTA = false;
  String _feedbackText = '';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startInitialSequence();
  }

  void _initAnimations() {
    // Header animation
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeInOut),
    );

    // Plate idle breathing animation
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _plateScale = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Interaction animations
    _plateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _plateController, curve: Curves.easeInOut),
    );

    // Scan beam animation
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scanProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // Result text animation
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _resultOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeInOut),
    );

    _resultSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOut),
    );

    // Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // CTA animation
    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _ctaOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctaController, curve: Curves.easeInOut));
  }

  void _startInitialSequence() async {
    // Page fade-in
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _headerController.forward();

    // Show CTA after 2s timeout if no tap
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted && !_hasInteracted) {
      setState(() => _showCTA = true);
      _ctaController.forward();
    }
  }

  void _onPlateTapped() async {
    if (_scanController.isAnimating) return;

    setState(() {
      _hasInteracted = true;
      _feedbackText = '';
    });

    HapticFeedback.lightImpact();

    // 1. Glow effect (0.2s)
    _plateController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _plateController.reverse();

    // 2. Scan beam (0.8s)
    _scanController.forward(from: 0.0);
    await Future.delayed(const Duration(milliseconds: 800));

    // 3. Show result text (0.5s)
    if (mounted) {
      HapticFeedback.mediumImpact();
      _resultController.forward(from: 0.0);
    }

    // 4. Fill progress bar (1.0s)
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _progressController.forward(from: 0.0);

    // 5. Show feedback text
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _feedbackText = 'Simple, non ? 📈');

      // Show CTA after feedback
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && !_showCTA) {
        setState(() => _showCTA = true);
        _ctaController.forward();
      }
    }
  }

  void _onActivateCameraPressed() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      Navigator.of(context).pushNamed('/camera-permission');
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _plateController.dispose();
    _breathingController.dispose();
    _scanController.dispose();
    _resultController.dispose();
    _progressController.dispose();
    _ctaController.dispose();
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
            const Spacer(flex: 1),

            // Header text
            AnimatedBuilder(
              animation: _headerController,
              builder: (context, child) {
                return Opacity(opacity: _headerOpacity.value, child: child);
              },
              child: Text(
                'Essaie 👇',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: ProtlyTheme.darkGray,
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Center interaction area
            SizedBox(
              height: size.height * 0.35,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Plate with animations
                  GestureDetector(
                    onTap: _onPlateTapped,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _breathingController,
                        _plateController,
                      ]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _plateScale.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow halo
                              if (_glowOpacity.value > 0)
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: ProtlyTheme.vitalityGreen
                                            .withOpacity(
                                              _glowOpacity.value * 0.5,
                                            ),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              // Plate icon
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ProtlyTheme.lightGray.withOpacity(0.3),
                                  border: Border.all(
                                    color: ProtlyTheme.vitalityGreen
                                        .withOpacity(0.5),
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  size: 70,
                                  color: ProtlyTheme.vitalityGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Scan beam overlay
                  AnimatedBuilder(
                    animation: _scanController,
                    builder: (context, child) {
                      if (_scanProgress.value == 0) {
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: CustomPaint(
                          painter: ScanBeamPainter(_scanProgress.value),
                        ),
                      );
                    },
                  ),

                  // Result text above plate
                  Positioned(
                    top: 20,
                    child: AnimatedBuilder(
                      animation: _resultController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _resultSlide,
                          child: Opacity(
                            opacity: _resultOpacity.value,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        '+28 g',
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(
                          color: ProtlyTheme.vitalityGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Progress bar below
                  Positioned(
                    bottom: 40,
                    left: 60,
                    right: 60,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _progressValue.value,
                                minHeight: 8,
                                backgroundColor: ProtlyTheme.lightGray,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  ProtlyTheme.vitalityGreen,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Feedback text
                  if (_feedbackText.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      child: Text(
                        _feedbackText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ProtlyTheme.darkGray,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // CTA button
            if (_showCTA)
              AnimatedBuilder(
                animation: _ctaController,
                builder: (context, child) {
                  return Opacity(opacity: _ctaOpacity.value, child: child);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: ElevatedButton(
                    onPressed: _onActivateCameraPressed,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text('Activer la caméra'),
                  ),
                ),
              ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class ScanBeamPainter extends CustomPainter {
  final double progress;

  ScanBeamPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = ProtlyTheme.vitalityGreen.withOpacity(0.3)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 75.0;

    // Draw scanning arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start from top
      progress * 6.28, // Full circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanBeamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
