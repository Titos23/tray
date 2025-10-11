import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/protly_theme.dart';

class GoalSummaryScreen extends StatefulWidget {
  const GoalSummaryScreen({super.key});

  @override
  State<GoalSummaryScreen> createState() => _GoalSummaryScreenState();
}

class _GoalSummaryScreenState extends State<GoalSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _numberController;
  late AnimationController _ringController;
  late AnimationController _motivationController;

  late Animation<double> _numberOpacity;
  late Animation<double> _numberScale;
  late Animation<double> _ringScale;
  late Animation<double> _motivationOpacity;

  int _proteinGoal = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _proteinGoal = args?['proteinGoal'] as int? ?? 130;

    _startAnimationSequence();
  }

  void _initAnimations() {
    // Number animation (fade + scale)
    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _numberOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.easeInOut),
    );

    _numberScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.elasticOut),
    );

    // Ring pulse animation
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _ringScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );

    // Motivation text animation
    _motivationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _motivationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _motivationController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      // Show number with haptic
      HapticFeedback.mediumImpact();
      _numberController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // Ring pulse
      _ringController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      // Show motivation text
      _motivationController.forward();
    }
  }

  void _onContinuePressed() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed('/notification-permission');
  }

  @override
  void dispose() {
    _numberController.dispose();
    _ringController.dispose();
    _motivationController.dispose();
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
            const SizedBox(height: 40),

            // Progress indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: ProtlyTheme.vitalityGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: ProtlyTheme.vitalityGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step 2 of 2',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Main title
            Text(
              'Here\'s your daily goal 🎯',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 1),

            // Dynamic result block
            AnimatedBuilder(
              animation: _numberController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _numberScale.value,
                  child: Opacity(opacity: _numberOpacity.value, child: child),
                );
              },
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$_proteinGoal g',
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: ProtlyTheme.vitalityGreen,
                          ),
                        ),
                        TextSpan(
                          text: '\nof protein per day',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: ProtlyTheme.darkText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '≈ ${(_proteinGoal / 2.2).toStringAsFixed(1)} g per lb of body weight',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Progress visual
            AnimatedBuilder(
              animation: _ringController,
              builder: (context, child) {
                return Transform.scale(scale: _ringScale.value, child: child);
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ProtlyTheme.lightGray, width: 8),
                ),
                child: Center(
                  child: Text(
                    '0%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: ProtlyTheme.mediumGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Motivational line
            AnimatedBuilder(
              animation: _motivationController,
              builder: (context, child) {
                return Opacity(opacity: _motivationOpacity.value, child: child);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'You\'re all set 💪 We\'ll help you get there.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: ProtlyTheme.darkGray),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Continue button
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
}
