import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // 붙여넣기 처리
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final next = (digits.length - 1).clamp(0, 5);
      _focusNodes[next].requestFocus();
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _handleVerify() async {
    if (_code.length < 6) {
      _showSnackBar('6자리 인증 코드를 모두 입력해 주세요.');
      return;
    }
    try {
      await ref.read(authProvider.notifier).verifyCode(widget.email, _code);
      if (!mounted) return;
      context.go(AppRoutes.snippet);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showSnackBar(msg);
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      setState(() {});
    }
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0) return;
    try {
      await ref.read(authProvider.notifier).sendVerificationCode(widget.email);
      _startCooldown();
      if (!mounted) return;
      _showSnackBar('인증 코드를 재발송했습니다.');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showSnackBar(msg);
    }
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) t.cancel();
      });
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: DesignTokens.space16,
          right: DesignTokens.space16,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Snippet', style: AppTypography.brand),
                  const SizedBox(height: DesignTokens.space40),
                  GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('이메일 인증', style: AppTypography.h3),
                        const SizedBox(height: DesignTokens.space8),
                        Text(
                          '${widget.email}\n으로 발송된 6자리 코드를 입력해 주세요.',
                          style: AppTypography.withColor(
                            AppTypography.bodySmall,
                            Colors.black54,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.space32),

                        // 6자리 입력 박스
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (i) {
                            return SizedBox(
                              width: 44,
                              height: 56,
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (e) => _onKeyEvent(i, e),
                                child: TextFormField(
                                  controller: _controllers[i],
                                  focusNode: _focusNodes[i],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 6,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: AppTypography.h3,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.5,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        DesignTokens.radiusMd,
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) => _onChanged(i, v),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: DesignTokens.space24),

                        ElevatedButton(
                          onPressed:
                              authState.isLoading ? null : _handleVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignTokens.primaryMain,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: DesignTokens.space16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radiusMd,
                              ),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('인증 완료'),
                        ),

                        const SizedBox(height: DesignTokens.space16),

                        TextButton(
                          onPressed: _resendCooldown > 0 ? null : _handleResend,
                          child: Text(
                            _resendCooldown > 0
                                ? '재발송 (${_resendCooldown}초 후 가능)'
                                : '인증 코드 재발송',
                            style: TextStyle(
                              color: _resendCooldown > 0
                                  ? Colors.black38
                                  : DesignTokens.primaryMain,
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed: () => context.go(AppRoutes.register),
                          child: const Text(
                            '다른 이메일로 가입하기',
                            style: TextStyle(color: Colors.black45),
                          ),
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
}
