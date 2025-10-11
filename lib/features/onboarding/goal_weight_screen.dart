import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/protly_theme.dart';

class GoalWeightScreen extends StatefulWidget {
  const GoalWeightScreen({super.key});

  @override
  State<GoalWeightScreen> createState() => _GoalWeightScreenState();
}

class _GoalWeightScreenState extends State<GoalWeightScreen> {
  String _selectedSex = 'Male';
  double _weight = 72.0;
  bool _isKg = true;
  double _height = 170.0;
  bool _skipHeight = false;

  double get _displayWeight => _isKg ? _weight : _weight * 2.20462;
  String get _weightUnit => _isKg ? 'kg' : 'lb';

  void _onSexSelected(String sex) {
    setState(() => _selectedSex = sex);
    HapticFeedback.lightImpact();
  }

  void _onWeightChanged(double value) {
    setState(() => _weight = value);
    HapticFeedback.selectionClick();
  }

  void _toggleWeightUnit() {
    setState(() => _isKg = !_isKg);
    HapticFeedback.lightImpact();
  }

  void _onHeightChanged(double value) {
    setState(() => _height = value);
    HapticFeedback.selectionClick();
  }

  void _onContinuePressed() {
    HapticFeedback.lightImpact();

    final height = _skipHeight ? 170.0 : _height;

    Navigator.of(context).pushNamed(
      '/goal-activity',
      arguments: {'sex': _selectedSex, 'weight': _weight, 'height': height},
    );
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                Center(
                  child: Text(
                    'Let\'s start simple 👇',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),

                const SizedBox(height: 48),

                // Sex selection
                Text(
                  'You are?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSexChip('Male')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSexChip('Female')),
                  ],
                ),

                const SizedBox(height: 40),

                // Weight selector
                Text(
                  'Your weight?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${_displayWeight.toStringAsFixed(1)} $_weightUnit',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: ProtlyTheme.vitalityGreen,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: ProtlyTheme.vitalityGreen,
                    inactiveTrackColor: ProtlyTheme.lightGray,
                    thumbColor: ProtlyTheme.vitalityGreen,
                    overlayColor: ProtlyTheme.vitalityGreen.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _weight,
                    min: 40,
                    max: 130,
                    onChanged: _onWeightChanged,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'kg',
                      style: TextStyle(
                        color:
                            _isKg
                                ? ProtlyTheme.vitalityGreen
                                : ProtlyTheme.mediumGray,
                        fontWeight: _isKg ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Switch(
                      value: !_isKg,
                      onChanged: (value) => _toggleWeightUnit(),
                      activeColor: ProtlyTheme.vitalityGreen,
                    ),
                    Text(
                      'lb',
                      style: TextStyle(
                        color:
                            !_isKg
                                ? ProtlyTheme.vitalityGreen
                                : ProtlyTheme.mediumGray,
                        fontWeight:
                            !_isKg ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Height selector (optional)
                Text(
                  'Your height?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                if (!_skipHeight) ...[
                  Center(
                    child: Text(
                      '${_height.toInt()} cm',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: ProtlyTheme.vitalityGreen,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: ProtlyTheme.vitalityGreen,
                      inactiveTrackColor: ProtlyTheme.lightGray,
                      thumbColor: ProtlyTheme.vitalityGreen,
                      overlayColor: ProtlyTheme.vitalityGreen.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _height,
                      min: 140,
                      max: 200,
                      onChanged: _onHeightChanged,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _skipHeight = !_skipHeight);
                      HapticFeedback.lightImpact();
                    },
                    child: Text(
                      _skipHeight ? 'Add height' : 'I don\'t know',
                      style: TextStyle(
                        color: ProtlyTheme.mediumGray,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Continue button
                ElevatedButton(
                  onPressed: _onContinuePressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Continue'),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSexChip(String sex) {
    final isSelected = _selectedSex == sex;

    return GestureDetector(
      onTap: () => _onSexSelected(sex),
      child: AnimatedContainer(
        duration: ProtlyTheme.shortAnimation,
        curve: ProtlyTheme.defaultCurve,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? ProtlyTheme.vitalityGreen : ProtlyTheme.pureWhite,
          border: Border.all(
            color:
                isSelected ? ProtlyTheme.vitalityGreen : ProtlyTheme.lightGray,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            sex,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isSelected ? ProtlyTheme.pureWhite : ProtlyTheme.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
