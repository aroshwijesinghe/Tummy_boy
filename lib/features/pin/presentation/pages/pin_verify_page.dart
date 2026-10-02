import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glow_icon.dart';
import '../../../../shared/widgets/neumorphic_button.dart';
import '../../data/pin_service.dart';

class PinVerifyPage extends StatefulWidget {
  final VoidCallback onVerified;

  const PinVerifyPage({super.key, required this.onVerified});

  @override
  State<PinVerifyPage> createState() => _PinVerifyPageState();
}

class _PinVerifyPageState extends State<PinVerifyPage> with SingleTickerProviderStateMixin {
  String _pin = '';
  int _attempts = 0;
  bool _isLockedOut = false;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;
  String? _errorMessage;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    if (_isLockedOut) return;

    setState(() {
      _errorMessage = null;
      if (key == 'back') {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else if (_pin.length < 4) {
        _pin += key;
        if (_pin.length == 4) {
          _verifyPin();
        }
      }
    });
  }

  Future<void> _verifyPin() async {
    final isValid = await PinService.verifyPin(_pin);
    if (isValid) {
      widget.onVerified();
    } else {
      _shakeController.forward(from: 0).then((_) => _shakeController.reset());
      setState(() {
        _pin = '';
        _attempts++;
        if (_attempts >= 3) {
          _startLockout();
        } else {
          _errorMessage = 'Incorrect PIN. Please try again.';
        }
      });
    }
  }

  void _startLockout() {
    setState(() {
      _isLockedOut = true;
      _lockoutSeconds = 30;
      _errorMessage = 'Too many attempts. System locked.';
    });

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_lockoutSeconds > 0) {
          _lockoutSeconds--;
        } else {
          _isLockedOut = false;
          _attempts = 0;
          _errorMessage = null;
          timer.cancel();
        }
      });
    });
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
      onPressed: _isLockedOut ? () {} : (onPressed ?? () => _onKeyPressed(label)),
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
              'Security Access',
              style: TextStyle(
                color: textCol,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your 4-digit PIN to access deck',
              style: TextStyle(color: subCol, fontSize: 13),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final offset = _shakeAnimation.value * (_shakeAnimation.status == AnimationStatus.forward ? 1 : -1);
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => _buildDot(index < _pin.length, isDark),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            if (_isLockedOut)
              Text(
                'Access locked: $_lockoutSeconds s remaining',
                style: const TextStyle(
                  color: AppColors.staminaLow,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.staminaLow,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                  const SizedBox(),
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
