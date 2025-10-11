import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';

class GoalWeightScreen extends StatefulWidget {
  const GoalWeightScreen({
    super.key,
    required this.model,
    this.onBack,
    required this.onContinue,
  });

  final OnboardingViewModel model;
  final VoidCallback? onBack;
  final VoidCallback onContinue;

  @override
  State<GoalWeightScreen> createState() => _GoalWeightScreenState();
}

class _GoalWeightScreenState extends State<GoalWeightScreen> {
  late FixedExtentScrollController _cmHeightController;
  late FixedExtentScrollController _kgWeightController;
  late FixedExtentScrollController _feetController;
  late FixedExtentScrollController _inchController;
  late FixedExtentScrollController _lbWeightController;

  static final List<int> _cmHeights = List<int>.generate(61, (i) => 140 + i);
  static final List<int> _kgWeights = List<int>.generate(91, (i) => 40 + i);
  static final List<int> _lbWeights = List<int>.generate(201, (i) => 90 + i);
  static final List<int> _feetValues = [4, 5, 6];
  static final List<int> _inchValues = List<int>.generate(12, (i) => i);

  @override
  void initState() {
    super.initState();
    _cmHeightController = FixedExtentScrollController(initialItem: _cmHeightIndex);
    _kgWeightController = FixedExtentScrollController(initialItem: _kgWeightIndex);
    _feetController = FixedExtentScrollController(initialItem: _feetIndex);
    _inchController = FixedExtentScrollController(initialItem: _inchIndex);
    _lbWeightController = FixedExtentScrollController(initialItem: _lbWeightIndex);
  }

  @override
  void dispose() {
    _cmHeightController.dispose();
    _kgWeightController.dispose();
    _feetController.dispose();
    _inchController.dispose();
    _lbWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.model,
          builder: (context, _) {
            _syncControllers();
            final canContinue = widget.model.sex != null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  const SizedBox(height: 16),
                  Text(
                    'Let us start simple.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('You are?'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ChoiceChip(
                        label: 'Male',
                        selected: widget.model.sex == Sex.male,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.model.updateSex(Sex.male);
                        },
                      ),
                      const SizedBox(width: 12),
                      _ChoiceChip(
                        label: 'Female',
                        selected: widget.model.sex == Sex.female,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.model.updateSex(Sex.female);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _buildUnitToggle(context),
                  const SizedBox(height: 24),
                  _buildPickers(context),
                  const Spacer(),
                  _PrimaryButton(
                    label: 'Continue',
                    enabled: canContinue,
                    onPressed: () {
                      if (!canContinue) return;
                      HapticFeedback.lightImpact();
                      widget.onContinue();
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUnitToggle(BuildContext context) {
    final isMetric = widget.model.weightUnit == WeightUnit.kg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _switchUnit(WeightUnit.lb),
              child: _UnitLabel(
                text: 'Imperial',
                active: !isMetric,
              ),
            ),
          ),
          Switch(
            value: isMetric,
            activeColor: AppColors.vitalityGreen,
            onChanged: (value) {
              final next = value ? WeightUnit.kg : WeightUnit.lb;
              _switchUnit(next);
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _switchUnit(WeightUnit.kg),
              child: _UnitLabel(
                text: 'Metric',
                active: isMetric,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickers(BuildContext context) {
    final isMetric = widget.model.weightUnit == WeightUnit.kg;
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.neutralText,
        );

    final pickers = isMetric ? _metricPickers() : _imperialPickers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Height', style: titleStyle),
            Text('Weight', style: titleStyle),
          ],
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 16 / 7,
          child: Row(
            children: pickers,
          ),
        ),
      ],
    );
  }

  List<Widget> _metricPickers() {
    return [
      Expanded(
        child: CupertinoPicker(
          scrollController: _cmHeightController,
          itemExtent: 44,
          magnification: 1.05,
          onSelectedItemChanged: (index) {
            final cm = _cmHeights[index].toDouble();
            widget.model.updateHeight(cm);
          },
          children: [
            for (final height in _cmHeights)
              Center(child: Text('$height cm')),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: CupertinoPicker(
          scrollController: _kgWeightController,
          itemExtent: 44,
          magnification: 1.05,
          onSelectedItemChanged: (index) {
            final kg = _kgWeights[index].toDouble();
            widget.model.updateWeight(kg, unit: WeightUnit.kg);
          },
          children: [
            for (final weight in _kgWeights)
              Center(child: Text('$weight kg')),
          ],
        ),
      ),
    ];
  }

  List<Widget> _imperialPickers() {
    return [
      Expanded(
        child: Column(
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: _feetController,
                itemExtent: 44,
                magnification: 1.05,
                onSelectedItemChanged: (index) {
                  final feet = _feetValues[index];
                  final inches = _inchValues[_inchController.selectedItem];
                  widget.model.updateHeight(_feetInchesToCm(feet, inches));
                },
                children: [
                  for (final feet in _feetValues) Center(child: Text('$feet ft')),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: _inchController,
                itemExtent: 44,
                magnification: 1.05,
                onSelectedItemChanged: (index) {
                  final feet = _feetValues[_feetController.selectedItem];
                  final inches = _inchValues[index];
                  widget.model.updateHeight(_feetInchesToCm(feet, inches));
                },
                children: [
                  for (final inch in _inchValues) Center(child: Text('$inch in')),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: CupertinoPicker(
          scrollController: _lbWeightController,
          itemExtent: 44,
          magnification: 1.05,
          onSelectedItemChanged: (index) {
            final pounds = _lbWeights[index].toDouble();
            widget.model.updateWeight(pounds, unit: WeightUnit.lb);
          },
          children: [
            for (final weight in _lbWeights)
              Center(child: Text('$weight lb')),
          ],
        ),
      ),
    ];
  }

  void _switchUnit(WeightUnit next) {
    if (widget.model.weightUnit == next) return;
    HapticFeedback.selectionClick();
    widget.model.toggleWeightUnit(next);
    setState(() {
      if (next == WeightUnit.kg) {
        _cmHeightController =
            FixedExtentScrollController(initialItem: _cmHeightIndex);
        _kgWeightController =
            FixedExtentScrollController(initialItem: _kgWeightIndex);
      } else {
        _feetController = FixedExtentScrollController(initialItem: _feetIndex);
        _inchController = FixedExtentScrollController(initialItem: _inchIndex);
        _lbWeightController =
            FixedExtentScrollController(initialItem: _lbWeightIndex);
      }
    });
  }

  void _syncControllers() {
    if (widget.model.weightUnit == WeightUnit.kg) {
      if (_cmHeightController.hasClients) {
        _cmHeightController.jumpToItem(_cmHeightIndex);
      }
      if (_kgWeightController.hasClients) {
        _kgWeightController.jumpToItem(_kgWeightIndex);
      }
    } else {
      if (_feetController.hasClients) {
        _feetController.jumpToItem(_feetIndex);
      }
      if (_inchController.hasClients) {
        _inchController.jumpToItem(_inchIndex);
      }
      if (_lbWeightController.hasClients) {
        _lbWeightController.jumpToItem(_lbWeightIndex);
      }
    }
  }

  int get _cmHeightIndex {
    final value = widget.model.heightCm.round();
    final index = _nearestIndex(_cmHeights, value);
    return index.clamp(0, _cmHeights.length - 1);
  }

  int get _kgWeightIndex {
    final value = widget.model.weightKg.round();
    final index = _nearestIndex(_kgWeights, value);
    return index.clamp(0, _kgWeights.length - 1);
  }

  int get _lbWeightIndex {
    final value = (widget.model.weightKg * 2.20462).round();
    final index = _nearestIndex(_lbWeights, value);
    return index.clamp(0, _lbWeights.length - 1);
  }

  int get _feetIndex {
    final inches = (widget.model.heightCm / 2.54).round();
    final feet = (inches ~/ 12).clamp(_feetValues.first, _feetValues.last);
    final index = _feetValues.indexOf(feet);
    if (index == -1) {
      return _nearestIndex(_feetValues, feet);
    }
    return index;
  }

  int get _inchIndex {
    final inches = (widget.model.heightCm / 2.54).round();
    final remainder = inches % 12;
    return remainder.clamp(0, _inchValues.length - 1);
  }

  double _feetInchesToCm(int feet, int inches) {
    final totalInches = feet * 12 + inches;
    final cm = totalInches * 2.54;
    return cm.clamp(140, 200);
  }

  int _nearestIndex(List<int> values, int target) {
    var closestIndex = 0;
    var smallestDelta = (values.first - target).abs();
    for (var i = 1; i < values.length; i++) {
      final delta = (values[i] - target).abs();
      if (delta < smallestDelta) {
        smallestDelta = delta;
        closestIndex = i;
      }
    }
    return closestIndex;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutralText,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.vitalityGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.vitalityGreen : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? Colors.white : AppColors.neutralText,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _UnitLabel extends StatelessWidget {
  const _UnitLabel({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? AppColors.darkText : AppColors.mutedText,
          ) ??
          const TextStyle(),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

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

