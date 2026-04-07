import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_input.dart';
import '../widgets/google_logo.dart';
import '../widgets/gradient_button.dart';

class SignupPage extends StatefulWidget {
  final AppRole role;
  const SignupPage({super.key, required this.role});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _fullName      = TextEditingController();
  final _businessName  = TextEditingController();
  final _email         = TextEditingController();
  final _phone         = TextEditingController();
  final _password      = TextEditingController();
  bool _showPass       = false;
  bool _agreed         = false;

  bool get _isAdmin => widget.role == AppRole.admin;

  @override
  void dispose() {
    _fullName.dispose();
    _businessName.dispose();
    _email.dispose();
    _phone.dispose();
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
              // ── Brand ──────────────────────────────────────────────────
              _BrandHeader(isAdmin: _isAdmin),
              const SizedBox(height: 24),

              // ── Form card ──────────────────────────────────────────────
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
                    Text('Create Account',
                        style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      _isAdmin
                          ? 'Set up your space management account.'
                          : 'Join the community of remote workers.',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 24),

                    GlassInput(
                      controller: _fullName,
                      hint: 'Full Name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    if (_isAdmin) ...[
                      GlassInput(
                        controller: _businessName,
                        hint: 'Business Name',
                        icon: Icons.business_rounded,
                      ),
                      const SizedBox(height: 14),
                      GlassInput(
                        controller: _phone,
                        hint: 'Contact Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                    ],

                    GlassInput(
                      controller: _email,
                      hint: 'Email Address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    if (!_isAdmin) ...[
                      GlassInput(
                        controller: _phone,
                        hint: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                    ],

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
                    const SizedBox(height: 16),

                    // ── Terms checkbox ──────────────────────────────────
                    GestureDetector(
                      onTap: () =>
                          setState(() => _agreed = !_agreed),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _agreed
                                  ? accent
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(5),
                              border: Border.all(
                                color: _agreed
                                    ? accent
                                    : Colors.white
                                        .withOpacity(0.20),
                              ),
                            ),
                            child: _agreed
                                ? const Icon(Icons.check,
                                    size: 12,
                                    color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text.rich(TextSpan(
                            text: 'I agree to the ',
                            style: AppTextStyles.bodySmall,
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: accent),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    GradientButton(
                      label: 'Create Account',
                      isAdmin: _isAdmin,
                      onTap: () =>
                          context.read<AppProvider>().signup(),
                    ),
                    const SizedBox(height: 20),

                    // ── Divider ─────────────────────────────────────────
                    _OrDivider(),
                    const SizedBox(height: 16),

                    // ── Google button ───────────────────────────────────
                    _GoogleButton(
                      onTap: () =>
                          context.read<AppProvider>().signup(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _BottomLink(
                question: 'Already have an account? ',
                action: 'Sign In',
                accent: accent,
                onTap: () =>
                    context.read<AppProvider>().goToLogin(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget Builders ────────────────────────────────────────────
  
  Widget _BrandHeader({required bool isAdmin}) {
    return Column(
      children: [
        Text(
          isAdmin ? 'Business Setup' : 'Join Hotspot',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(height: 8),
        Text(
          isAdmin ? 'Create your business account' : 'Find your perfect space',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
        ),
      ],
    );
  }

  Widget _OrDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.dividerColor(context))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTheme.dividerColor(context))),
      ],
    );
  }

  Widget _GoogleButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GoogleLogo(size: 18),
            const SizedBox(width: 8),
            Text('Continue with Google', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  Widget _BottomLink({
    required String question,
    required String action,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            text: question,
            style: AppTextStyles.bodySmall,
            children: [
              TextSpan(
                text: action,
                style: AppTextStyles.bodySmall.copyWith(color: accent, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
