import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/protly_theme.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseOpacity;

  String? _selectedMode;

  final List<ReminderMode> _modes = [
    ReminderMode(
      emoji: '🌿',
      title: 'Light',
      description: 'one reminder per day',
    ),
    ReminderMode(
      emoji: '⚡',
      title: 'Standard',
      description: 'three reminders per day',
    ),
    ReminderMode(
      emoji: '💤',
      title: 'Silent',
      description: 'reminders without sound',
    ),
  ];

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
    final status = await Permission.notification.status;
    if (status.isGranted) {
      // Skip screen if already granted
      _navigateToNextScreen();
    }
  }

  void _onModeSelected(String mode) {
    setState(() => _selectedMode = mode);
    HapticFeedback.lightImpact();
  }

  Future<void> _onEnableRemindersPressed() async {
    if (_selectedMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a reminder mode'),
          backgroundColor: ProtlyTheme.mediumGray,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    // Show confetti/bell animation (placeholder)
    // In production, use a package like confetti

    // Request permission
    final status = await Permission.notification.request();

    if (status.isGranted) {
      // Case 1 – Permission accepted
      _showSuccessToast();
      await Future.delayed(const Duration(milliseconds: 1500));
      _navigateToNextScreen();
    } else {
      // Case 2 – Permission denied
      _showDeniedToast();
      await Future.delayed(const Duration(milliseconds: 2000));
      _navigateToNextScreen();
    }
  }

  void _showSuccessToast() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Great! We\'ll keep you on track 💪'),
          backgroundColor: ProtlyTheme.vitalityGreen,
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showDeniedToast() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No worries — you can enable notifications later 😉',
          ),
          backgroundColor: ProtlyTheme.mediumGray,
          duration: const Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _navigateToNextScreen() {
    if (mounted) {
      Navigator.of(context).pushNamed('/privacy-consent');
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Bell icon with pulse
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(opacity: _pulseOpacity.value, child: child);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ProtlyTheme.vitalityGreen,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      size: 40,
                      color: ProtlyTheme.vitalityGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Gentle reminders to complete your bar 🟩',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(height: 1.4),
                ),

                const SizedBox(height: 40),

                // Selectable cards
                ..._modes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mode = entry.value;

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReminderCard(mode),
                    ),
                  );
                }),

                const SizedBox(height: 40),

                // Primary CTA
                ElevatedButton(
                  onPressed: _onEnableRemindersPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Enable my reminders'),
                ),

                const SizedBox(height: 16),

                // Reassurance text
                Text(
                  'You can change this anytime.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(ReminderMode mode) {
    final isSelected = _selectedMode == mode.title;

    return GestureDetector(
      onTap: () => _onModeSelected(mode.title),
      child: AnimatedContainer(
        duration: ProtlyTheme.mediumAnimation,
        curve: ProtlyTheme.defaultCurve,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected ? ProtlyTheme.lightGreenTint : ProtlyTheme.pureWhite,
          border: Border.all(
            color:
                isSelected ? ProtlyTheme.vitalityGreen : ProtlyTheme.lightGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Text(mode.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ProtlyTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: ProtlyTheme.vitalityGreen,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

class ReminderMode {
  final String emoji;
  final String title;
  final String description;

  ReminderMode({
    required this.emoji,
    required this.title,
    required this.description,
  });
}
