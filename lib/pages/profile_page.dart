import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';
import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _section;
  File?   _avatar;

  Future<void> _pickImage() async {
    final p = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (p != null) setState(() => _avatar = File(p.path));
  }

  @override
  Widget build(BuildContext context) {
    if (_section == 'settings') {
      return _SettingsSection(onBack: () => setState(() => _section = null));
    }
    if (_section == 'payment') {
      return _PaymentSection(onBack: () => setState(() => _section = null));
    }
    if (_section == 'notif') {
      return _NotifSection(onBack: () => setState(() => _section = null));
    }
    if (_section == 'help') {
      return _HelpSection(onBack: () => setState(() => _section = null));
    }

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.iconColor(context)),
                onPressed: () =>
                    context.read<AppProvider>().setProfileOpen(false),
              ),
              Expanded(
                child: Text('Profile',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary(context))),
              ),
              const SizedBox(width: 48),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Column(children: [
                Stack(clipBehavior: Clip.none, children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.appAccent.withOpacity(0.20),
                      border: Border.all(
                          color: AppColors.appAccent.withOpacity(0.50),
                          width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _avatar != null
                        ? Image.file(_avatar!, fit: BoxFit.cover)
                        : const Icon(Icons.person_outline_rounded,
                            size: 40, color: AppColors.appAccent),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.appAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.appAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.appAccent, blurRadius: 6)
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Online',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.appAccent,
                          fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 8),
                Text('Alex Johnson',
                    style: AppTextStyles.heading2.copyWith(
                        color: AppTheme.textPrimary(context))),
                Text('alex.j@example.com',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textSecondary(context))),
                const SizedBox(height: 32),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Account Settings',
                  onTap: () => setState(() => _section = 'settings'),
                ),
                _MenuItem(
                  icon: Icons.credit_card_outlined,
                  label: 'Payment Methods',
                  onTap: () => setState(() => _section = 'payment'),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => setState(() => _section = 'notif'),
                ),
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () => setState(() => _section = 'help'),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.read<AppProvider>().logout(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.red400.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.red400.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: AppColors.red400, size: 18),
                        const SizedBox(width: 10),
                        Text('Log Out',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.red400,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.appAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.appAccent2, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label,
              style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary(context)))),
          Icon(Icons.arrow_forward_ios_rounded,
              color: AppTheme.textSecondary(context), size: 14),
        ]),
      ),
    );
  }
}

class _SubShell extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget child;
  const _SubShell({required this.title, required this.onBack, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.iconColor(context)),
                onPressed: onBack,
              ),
              Expanded(child: Text(title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary(context)))),
              const SizedBox(width: 48),
            ]),
          ),
          Expanded(child: child),
        ]),
      ),
    );
  }
}

class _SettingsSection extends StatefulWidget {
  final VoidCallback onBack;
  const _SettingsSection({required this.onBack});

  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  final _nameCtrl  = TextEditingController(text: 'Alex Johnson');
  final _emailCtrl = TextEditingController(text: 'alex.j@example.com');
  final _phoneCtrl = TextEditingController(text: '+94 77 123 4567');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app    = context.watch<AppProvider>();
    final isDark = app.isDarkMode;

    return _SubShell(
      title: 'Account Settings',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          _SectionCard(
            title: 'Appearance',
            child: Row(children: [
              Expanded(
                child: _ThemeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  isSelected: isDark,
                  onTap: () => app.setDarkMode(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ThemeOption(
                  label: 'Light',
                  icon: Icons.light_mode_rounded,
                  isSelected: !isDark,
                  onTap: () => app.setDarkMode(false),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Personal Information',
            child: Column(children: [
              _InputField(
                controller: _nameCtrl,
                hint: 'Full Name',
                label: 'Full Name',
              ),
              const SizedBox(height: 12),
              _InputField(
                controller: _emailCtrl,
                hint: 'Email Address',
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _InputField(
                controller: _phoneCtrl,
                hint: 'Phone Number',
                label: 'Phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Changes saved successfully'),
                        backgroundColor: AppColors.appAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Save Changes',
                      style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Security',
            child: Column(children: [
              _ArrowRow(label: 'Change Password'),
              _ArrowRow(label: 'Two-Factor Authentication'),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.appAccent.withOpacity(0.12)
              : AppTheme.surfaceVariant(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.appAccent.withOpacity(0.55)
                : AppTheme.dividerColor(context),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.appAccent.withOpacity(0.15),
                    blurRadius: 15,
                  )
                ]
              : [],
        ),
        child: Column(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.appAccent.withOpacity(0.20)
                  : AppTheme.surfaceVariant(context),
            ),
            child: Icon(icon,
                size: 24,
                color: isSelected
                    ? AppColors.appAccent
                    : AppTheme.textSecondary(context)),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.body.copyWith(
                  color: isSelected
                      ? AppTheme.textPrimary(context)
                      : AppTheme.textSecondary(context),
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400)),
          const SizedBox(height: 6),
          if (isSelected)
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(
                color: AppColors.appAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 14, color: Colors.white),
            )
          else
            const SizedBox(height: 22),
        ]),
      ),
    );
  }
}

class _SavedCard {
  final String id, brand, lastFour, holder, expires;
  _SavedCard({
    required this.id,
    required this.brand,
    required this.lastFour,
    required this.holder,
    required this.expires,
  });
}

class _PaymentSection extends StatefulWidget {
  final VoidCallback onBack;
  const _PaymentSection({required this.onBack});

  @override
  State<_PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<_PaymentSection> {
  final List<_SavedCard> _cards = [
    _SavedCard(
      id: '1', brand: 'Visa', lastFour: '4289',
      holder: 'Alex Johnson', expires: '09/27',
    ),
  ];

  final _numCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _numCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _deleteCard(String id) =>
      setState(() => _cards.removeWhere((c) => c.id == id));

  void _addCard() {
    if (_numCtrl.text.length >= 4) {
      final lastFour = _numCtrl.text.replaceAll(' ', '');
      setState(() {
        _cards.add(_SavedCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          brand: 'Visa',
          lastFour: lastFour.length >= 4
              ? lastFour.substring(lastFour.length - 4)
              : lastFour,
          holder: 'Alex Johnson',
          expires: _expCtrl.text.isNotEmpty ? _expCtrl.text : 'N/A',
        ));
        _numCtrl.clear();
        _expCtrl.clear();
        _cvvCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SubShell(
      title: 'Payment Methods',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          ..._cards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CreditCardWidget(
                  card: card,
                  onDelete: () => _deleteCard(card.id),
                ),
              )),
          _SectionCard(
            title: 'Add New Card',
            child: Column(children: [
              _InputField(
                controller: _numCtrl,
                hint: '1234 5678 9012 3456',
                label: 'Card Number',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _InputField(
                  controller: _expCtrl,
                  hint: 'MM/YY',
                  label: 'Expiry',
                )),
                const SizedBox(width: 12),
                Expanded(child: _InputField(
                  controller: _cvvCtrl,
                  hint: '123',
                  label: 'CVV',
                  obscure: true,
                )),
              ]),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text('Add Card',
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Other Methods',
            child: Column(children: [
              _ArrowRowWithIcon(
                  icon: Icons.smartphone_rounded,
                  label: 'Mobile Banking'),
              _ArrowRowWithIcon(
                  icon: Icons.account_balance_rounded,
                  label: 'Bank Transfer'),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _CreditCardWidget extends StatefulWidget {
  final _SavedCard card;
  final VoidCallback onDelete;
  const _CreditCardWidget({required this.card, required this.onDelete});

  @override
  State<_CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<_CreditCardWidget> {
  bool _confirmDelete = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _confirmDelete
              ? [const Color(0xFF7F1D1D), const Color(0xFF991B1B)]
              : [const Color(0xFF0F4C3A), const Color(0xFF0A3025)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_confirmDelete ? AppColors.red400 : AppColors.appAccent)
                .withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _confirmDelete
          ? _DeleteConfirm(
              onCancel: () => setState(() => _confirmDelete = false),
              onConfirm: widget.onDelete,
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.card.brand,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70)),
                  GestureDetector(
                    onTap: () => setState(() => _confirmDelete = true),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white70, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('•••• •••• •••• ${widget.card.lastFour}',
                  style: AppTextStyles.heading3.copyWith(letterSpacing: 4)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('CARDHOLDER',
                        style: AppTextStyles.label
                            .copyWith(color: Colors.white54, letterSpacing: 1.2)),
                    Text(widget.card.holder, style: AppTextStyles.body),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('EXPIRES',
                        style: AppTextStyles.label
                            .copyWith(color: Colors.white54, letterSpacing: 1.2)),
                    Text(widget.card.expires, style: AppTextStyles.body),
                  ]),
                ],
              ),
            ]),
    );
  }
}

class _DeleteConfirm extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  const _DeleteConfirm({required this.onCancel, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Icon(Icons.warning_amber_rounded, color: Colors.white70, size: 28),
      const SizedBox(height: 8),
      const Text('Remove this card?',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.30)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Cancel'),
        )),
        const SizedBox(width: 10),
        Expanded(child: ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Remove'),
        )),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATIONS – with icons per category
// ─────────────────────────────────────────────────────────────────────────────

class _NotifSection extends StatefulWidget {
  final VoidCallback onBack;
  const _NotifSection({required this.onBack});

  @override
  State<_NotifSection> createState() => _NotifSectionState();
}

class _NotifSectionState extends State<_NotifSection> {
  bool _bookings   = true;
  bool _promos     = false;
  bool _reminders  = true;
  bool _newsletter = false;

  @override
  Widget build(BuildContext context) {
    return _SubShell(
      title: 'Notifications',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _SectionCard(
          title: 'Push Notifications',
          child: Column(
            children: [
              _ToggleRowWithIcon(
                icon: Icons.notifications_rounded,
                label: 'Booking Updates',
                sub: 'Confirmations, changes, reminders',
                value: _bookings,
                onToggle: (v) => setState(() => _bookings = v),
              ),
              _ToggleRowWithIcon(
                icon: Icons.message_rounded,
                label: 'Promotions',
                sub: 'Deals, offers, discounts',
                value: _promos,
                onToggle: (v) => setState(() => _promos = v),
              ),
              _ToggleRowWithIcon(
                icon: Icons.access_time_rounded,
                label: 'Reminders',
                sub: 'Upcoming bookings, check-ins',
                value: _reminders,
                onToggle: (v) => setState(() => _reminders = v),
              ),
              _ToggleRowWithIcon(
                icon: Icons.mail_outline_rounded,
                label: 'Newsletter',
                sub: 'Weekly updates, new spaces',
                value: _newsletter,
                onToggle: (v) => setState(() => _newsletter = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Toggle row with icon (replaces the old _ToggleRow) ──────────────────────
class _ToggleRowWithIcon extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final bool value;
  final ValueChanged<bool> onToggle;

  const _ToggleRowWithIcon({
    required this.icon,
    required this.label,
    required this.sub,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.appAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.appAccent2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body.copyWith(color: AppTheme.textPrimary(context))),
                const SizedBox(height: 2),
                Text(sub, style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onToggle,
            activeThumbColor: AppColors.appAccent,
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatefulWidget {
  final VoidCallback onBack;
  const _HelpSection({required this.onBack});

  @override
  State<_HelpSection> createState() => _HelpSectionState();
}

class _HelpSectionState extends State<_HelpSection> {
  int? _expanded;

  static const _faqs = [
    ('How do I book a workspace?',
      'Browse available spaces on the Map or Spaces tab, select a space, choose your package and time slot, then confirm your booking.'),
    ('Can I cancel a booking?',
      'Yes, you can cancel up to 2 hours before your booking time from the Activity tab. Refunds are processed within 3-5 business days.'),
    ('How do QR check-ins work?',
      'When you arrive, open your booking in the Activity tab and show the QR code at the entrance. The space admin will scan it to check you in.'),
    ('How do loyalty points work?',
      'You earn 10 points per LKR 100 spent. Points can be redeemed for discounts on future bookings. Check your balance on the Activity tab.'),
  ];

  @override
  Widget build(BuildContext context) {
    return _SubShell(
      title: 'Help & Support',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          _SectionCard(
            title: 'Frequently Asked Questions',
            child: Column(
              children: List.generate(_faqs.length, (i) {
                final isOpen = _expanded == i;
                return Column(children: [
                  GestureDetector(
                    onTap: () => setState(() => _expanded = isOpen ? null : i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(children: [
                        Expanded(child: Text(_faqs[i].$1,
                            style: AppTextStyles.body.copyWith(
                                color: AppTheme.textPrimary(context)))),
                        AnimatedRotation(
                          turns: isOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textSecondary(context)),
                        ),
                      ]),
                    ),
                  ),
                  if (isOpen)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(_faqs[i].$2,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.textSecondary(context))),
                    ),
                  if (i < _faqs.length - 1)
                    Divider(color: AppTheme.dividerColor(context)),
                ]);
              }),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Contact Us',
            child: Column(children: [
              _ContactRow(
                icon: Icons.mail_outline_rounded,
                text: 'support@hotspot.lk',
                color: AppColors.appAccent2,
              ),
              SizedBox(height: 8),
              _ContactRow(
                icon: Icons.phone_outlined,
                text: '+94 11 234 5678',
                color: AppColors.appAccent2,
              ),
              SizedBox(height: 8),
              _ContactRow(
                icon: Icons.description_outlined,
                text: 'Terms & Privacy Policy',
                color: AppColors.appAccent2,
                isLink: true,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isLink;
  const _ContactRow({
    required this.icon,
    required this.text,
    required this.color,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor(context)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: AppTextStyles.body.copyWith(
                  color: isLink
                      ? AppColors.appAccent
                      : AppTheme.textPrimary(context))),
        ),
        if (isLink)
          Icon(Icons.open_in_new_rounded,
              color: AppTheme.textSecondary(context), size: 14),
      ]),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(context))),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint, label;
  final TextInputType keyboardType;
  final bool obscure;
  const _InputField({
    required this.controller,
    required this.hint,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppTextStyles.label.copyWith(
              color: AppTheme.textSecondary(context))),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: AppTextStyles.body
            .copyWith(color: AppTheme.textPrimary(context)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(
              color: AppTheme.textMuted(context)),
          filled: true,
          fillColor: AppTheme.inputFill(context),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppTheme.inputBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppTheme.inputBorder(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.appAccent),
          ),
        ),
      ),
    ]);
  }
}

class _ArrowRow extends StatelessWidget {
  final String label;
  const _ArrowRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor(context)),
      ),
      child: Row(children: [
        Expanded(child: Text(label,
            style: AppTextStyles.body.copyWith(
                color: AppTheme.textPrimary(context)))),
        Icon(Icons.arrow_forward_ios_rounded,
            color: AppTheme.textSecondary(context), size: 14),
      ]),
    );
  }
}

class _ArrowRowWithIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ArrowRowWithIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor(context)),
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.appAccent2, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(label,
            style: AppTextStyles.body.copyWith(
                color: AppTheme.textPrimary(context)))),
        Icon(Icons.arrow_forward_ios_rounded,
            color: AppTheme.textSecondary(context), size: 14),
      ]),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label, sub;
  final bool value;
  final ValueChanged<bool> onToggle;
  const _ToggleRow({
    required this.label,
    required this.sub,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.body.copyWith(
                    color: AppTheme.textPrimary(context))),
            Text(sub,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textSecondary(context))),
          ],
        )),
        Switch(
          value: value,
          onChanged: onToggle,
          activeThumbColor: AppColors.appAccent,
        ),
      ]),
    );
  }
}