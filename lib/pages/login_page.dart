import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_input.dart';
import '../widgets/google_logo.dart';
import '../widgets/gradient_button.dart';

class LoginPage extends StatefulWidget {
  final AppRole role;
  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool  _showPass = false;

  bool get _isAdmin => widget.role == AppRole.admin;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isAdmin ? AppColors.adminAccent : AppColors.appAccent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              _BrandHeader(isAdmin: _isAdmin),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: AppTheme.dividerColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome Back',
                        style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      _isAdmin
                          ? 'Sign in to your space dashboard.'
                          : 'Sign in to find your workspace.',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 24),

                    GlassInput(
                      controller: _email,
                      hint: 'Email Address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    GlassInput(
                      controller: _password,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_showPass,
                      suffix: IconButton(
                        icon: Icon(
                          _showPass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.grey500,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _showPass = !_showPass),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Forgot Password?',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: accent)),
                    ),
                    const SizedBox(height: 20),

                    GradientButton(
                      label: 'Sign In',
                      isAdmin: _isAdmin,
                      onTap: () =>
                          context.read<AppProvider>().login(),
                    ),
                    const SizedBox(height: 20),

                    _OrDivider(),
                    const SizedBox(height: 16),

                    _GoogleButton(
                      onTap: () =>
                          context.read<AppProvider>().login(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _BottomLink(
                question: "Don't have an account? ",
                action: 'Sign Up',
                accent: accent,
                onTap: () =>
                    context.read<AppProvider>().goToSignup(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets used by both auth pages ───────────────────────────────────

class _BrandHeader extends StatelessWidget {
  final bool isAdmin;
  const _BrandHeader({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final accent =
        isAdmin ? AppColors.adminAccent : AppColors.appAccent;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withOpacity(0.30)),
          ),
          child: Icon(Icons.wifi_rounded, color: accent, size: 26),
        ),
        const SizedBox(height: 12),
        Text('HOTSPOT', style: AppTextStyles.brandTitle),
        const SizedBox(height: 4),
        Text('Co-working marketplace',
            style: AppTextStyles.label
                .copyWith(letterSpacing: 3.0)),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Divider(color: Colors.white.withOpacity(0.10))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('or sign in with',
            style: AppTextStyles.label
                .copyWith(letterSpacing: 2.0)),
      ),
      Expanded(
          child: Divider(color: Colors.white.withOpacity(0.10))),
    ]);
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant(context),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GoogleLogo(size: 18),
            const SizedBox(width: 10),
            Text('Continue with Google',
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _BottomLink extends StatelessWidget {
  final String question;
  final String action;
  final Color accent;
  final VoidCallback onTap;

  const _BottomLink({
    required this.question,
    required this.action,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(TextSpan(
        text: question,
        style: AppTextStyles.bodySmall,
        children: [
          TextSpan(
            text: action,
            style: AppTextStyles.bodySmall.copyWith(
                color: accent, fontWeight: FontWeight.w600),
          ),
        ],
      )),
    );
  }
}
