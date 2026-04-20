import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/primary_button.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../../data/services/auth_service.dart';

class RetailerVerifyCodeScreen extends StatefulWidget {
  final String email;
  final String password;

  const RetailerVerifyCodeScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<RetailerVerifyCodeScreen> createState() =>
      _RetailerVerifyCodeScreenState();
}

class _RetailerVerifyCodeScreenState extends State<RetailerVerifyCodeScreen> {
  final int _codeLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getCode() {
    final buffer = StringBuffer();
    for (final c in _controllers) {
      buffer.write(c.text);
    }
    return buffer.toString().trim();
  }

  void _onBoxChanged(String value, int index) {
    if (value.length == 1 && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await sl<AuthService>().sendBuild4AllVerification(
        email: widget.email,
        password: widget.password,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent again')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _verify() async {
    final code = _getCode();

    if (code.length != _codeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final pendingId = await sl<AuthService>().verifyBuild4AllEmailCode(
        email: widget.email,
        code: code,
      );

      if (!mounted) return;

      context.push(
        '/signup/complete-profile',
        extra: {
          'pendingId': pendingId,
          'email': widget.email,
          'password': widget.password,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusLarge,
                  ),
                  side: const BorderSide(color: AppThemeTokens.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Enter verification code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We sent a code to your email.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppThemeTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_codeLength, (index) {
                          return SizedBox(
                            width: 46,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                counterText: '',
                              ),
                              onChanged: (value) => _onBoxChanged(value, index),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Verify',
                        isLoading: _isVerifying,
                        onPressed: _verify,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isResending ? null : _resendCode,
                        child: Text(
                          _isResending ? 'Resending...' : 'Resend code',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}