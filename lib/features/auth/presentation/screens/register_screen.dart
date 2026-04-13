import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _codeSent = false;
  bool _isSendingCode = false;
  int _cooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _codeControllers) { c.dispose(); }
    for (final f in _codeFocusNodes) { f.dispose(); }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  void _onEmailChanged(String _) {
    if (_codeSent) {
      setState(() {
        _codeSent = false;
        for (final c in _codeControllers) { c.clear(); }
        _cooldown = 0;
        _cooldownTimer?.cancel();
      });
    }
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('올바른 이메일을 입력해 주세요.');
      return;
    }
    setState(() => _isSendingCode = true);
    try {
      await ref.read(authProvider.notifier).sendEmailCode(email);
      setState(() {
        _codeSent = true;
        _cooldown = 60;
      });
      _startCooldown();
      for (final c in _codeControllers) { c.clear(); }
      Future.delayed(const Duration(milliseconds: 100), () {
        _codeFocusNodes[0].requestFocus();
      });
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isSendingCode = false);
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _cooldown--;
        if (_cooldown <= 0) t.cancel();
      });
    });
  }

  void _onCodeChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _codeControllers[i].text = digits[i];
      }

      final next = (digits.length - 1).clamp(0, 5);
      _codeFocusNodes[next].requestFocus();
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _codeFocusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onCodeKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _codeControllers[index].text.isEmpty &&
        index > 0) {
      _codeFocusNodes[index - 1].requestFocus();
      _codeControllers[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_codeSent) {
      _showSnackBar('이메일 인증을 먼저 진행해 주세요.');
      return;
    }
    if (_code.length < 6) {
      _showSnackBar('6자리 인증 코드를 입력해 주세요.');
      return;
    }
    try {
      await ref.read(authProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
            _code,
          );
      if (!mounted) return;
      context.go(AppRoutes.snippet);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignTokens.errorMain,
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                        child: Padding(
                          padding: const EdgeInsets.all(DesignTokens.space16),
                          child: Image.asset(
                            'images/snippetbook.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Text('Snippet', style: AppTypography.brand),
                    const SizedBox(height: DesignTokens.space40),
                    GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Create Account', style: AppTypography.h3),
                          const SizedBox(height: DesignTokens.space24),

                          // 이름
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.5),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? '이름을 입력해 주세요' : null,
                          ),
                          const SizedBox(height: DesignTokens.space16),

                          // 이메일 + 인증코드 발송 버튼
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onChanged: _onEmailChanged,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return '이메일을 입력해 주세요';
                                    if (!v.contains('@')) return '올바른 이메일을 입력해 주세요';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: DesignTokens.space8),
                              SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: (_isSendingCode || _cooldown > 0)
                                      ? null
                                      : _handleSendCode,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: DesignTokens.space12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                    ),
                                  ),
                                  child: Text(
                                    _isSendingCode
                                        ? '발송 중'
                                        : _cooldown > 0
                                            ? '$_cooldown초'
                                            : _codeSent
                                                ? '재발송'
                                                : '인증코드\n발송',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // 인증코드 입력 (발송 후 표시)
                          if (_codeSent) ...[
                            const SizedBox(height: DesignTokens.space12),
                            Text(
                              '이메일로 발송된 6자리 코드를 입력하세요',
                              style: AppTypography.withColor(
                                AppTypography.caption,
                                Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: DesignTokens.space8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (i) {
                                return SizedBox(
                                  width: 44,
                                  height: 52,
                                  child: KeyboardListener(
                                    focusNode: FocusNode(),
                                    onKeyEvent: (e) => _onCodeKeyDown(i, e),
                                    child: TextFormField(
                                      controller: _codeControllers[i],
                                      focusNode: _codeFocusNodes[i],
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
                                        fillColor: Colors.white.withValues(alpha: 0.5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                        ),
                                      ),
                                      onChanged: (v) => _onCodeChanged(i, v),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],

                          const SizedBox(height: DesignTokens.space16),

                          // 비밀번호
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _isPasswordVisible = !_isPasswordVisible),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.5),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? '비밀번호를 입력해 주세요' : null,
                          ),
                          const SizedBox(height: DesignTokens.space16),

                          // 비밀번호 확인
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleRegister(),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_isConfirmPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(() =>
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.5),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return '비밀번호를 다시 입력해 주세요';
                              if (v != _passwordController.text) return '비밀번호가 일치하지 않습니다';
                              return null;
                            },
                          ),
                          const SizedBox(height: DesignTokens.space24),

                          AppButton(
                            text: 'Register',
                            onPressed: _handleRegister,
                            variant: AppButtonVariant.primary,
                            size: AppButtonSize.large,
                            isFullWidth: true,
                            isLoading: authState.isLoading,
                          ),
                          const SizedBox(height: DesignTokens.space16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: DesignTokens.primaryMain,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
