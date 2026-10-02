import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glow_icon.dart';
import '../../../../shared/widgets/neumorphic_button.dart';
import '../../data/pin_service.dart';

class PinSetupPage extends StatefulWidget {
  final VoidCallback onPinSet;

  const PinSetupPage({super.key, required this.onPinSet});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

enum SetupStep { enter, confirm }

class _PinSetupPageState extends State<PinSetupPage> {
  SetupStep _step = SetupStep.enter;
  String _pin = '';
  String _confirmPin = '';
  String? _errorMessage;

  void _onKeyPressed(String key) {
    setState(() {
      _errorMessage = null;
      if (key == 'back') {
        if (_step == SetupStep.enter && _pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        } else if (_step == SetupStep.confirm && _confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else if (key == 'clear') {
        if (_step == SetupStep.enter) {
          _pin = '';
        } else {
          _confirmPin = '';
        }
      } else if (_pin.length < 4 || (_step == SetupStep.confirm && _confirmPin.length < 4)) {
        if (_step == SetupStep.enter) {
          _pin += key;
          if (_pin.length == 4) {
            _step = SetupStep.confirm;
          }
        } else {
          _confirmPin += key;
          if (_confirmPin.length == 4) {
            _verifyAndSave();
          }
        }
      }
    });
  }

  Future<void> _verifyAndSave() async {
    if (_pin == _confirmPin) {
      await PinService.setupPin(_pin);
      widget.onPinSet();
    } else {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _pin = '';
        _confirmPin = '';
        _step = SetupStep.enter;
      });
    }
  }

  Widget _buildDot(bool isFilled, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled
            ? AppColors.neonCyan
            : (isDark ? const Color(0xFF0F121A) : const Color(0xFFCBD5E1)),
        border: Border.all(
          color: isFilled
              ? AppColors.neonCyan
              : (isDark ? const Color(0xFF283246) : const Color(0xFF94A3B8)),
          width: 1.5,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: isDark ? 0.6 : 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
    );
  }

  Widget _buildKeypadButton(String label, bool isDark, {IconData? icon, VoidCallback? onPressed}) {
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    return NeumorphicButton(
      isCircular: true,
      size: 70,
      onPressed: onPressed ?? () => _onKeyPressed(label),
      child: Center(
        child: icon != null
            ? Icon(icon, color: textCol, size: 26)
            : Text(
                label,
                style: TextStyle(
                  color: textCol,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? AppColors.bgDeepDark : AppColors.bgDeepLight;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);
    final currentInput = _step == SetupStep.enter ? _pin : _confirmPin;

    return Scaffold(
      backgroundColor: bgCol,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const GlowIcon(
              icon: Icons.lock_outline_rounded,
              size: 52,
              color: AppColors.neonCyan,
              glowRadius: 16,
            ),
            const SizedBox(height: 20),
            Text(
              _step == SetupStep.enter ? 'Calibrate PIN' : 'Confirm PIN Code',
              style: TextStyle(
                color: textCol,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hardware-level lock for your fitness records',
              style: TextStyle(color: subCol, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => _buildDot(index < currentInput.length, isDark),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.staminaLow,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 1; i <= 9; i++) _buildKeypadButton(i.toString(), isDark),
                  _buildKeypadButton('clear', isDark, icon: Icons.clear_rounded, onPressed: () => _onKeyPressed('clear')),
                  _buildKeypadButton('0', isDark),
                  _buildKeypadButton('back', isDark, icon: Icons.backspace_outlined, onPressed: () => _onKeyPressed('back')),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
