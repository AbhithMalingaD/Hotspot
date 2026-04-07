import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class BookingRequestsPage extends StatefulWidget {
  const BookingRequestsPage({super.key});

  @override
  State<BookingRequestsPage> createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  String  _tab       = 'All';
  String? _expanded;
  String? _rejecting;
  final   _reasonCtrl = TextEditingController();

  static const _tabs = ['All', 'Pending', 'Confirmed', 'Rejected'];

  static final _requests = [
    const _Req('1', 'Kasun Perera',    'KP', 'Event Space',   'Mar 18 · 9:00 AM - 5:00 PM', 'LKR 64,000', 'Pending',   '+94 77 123 4567', '8 hours',  null),
    const _Req('2', 'Nimasha De Silva','ND', 'Private Room',  'Mar 15 · 2:00 PM - 4:00 PM', 'LKR 3,000',  'Confirmed',  '+94 71 987 6543', '2 hours',  null),
    const _Req('3', 'Amal Fernando',   'AF', 'Board Room',    'Mar 14 · 10:00 AM - 1:00 PM','LKR 10,500', 'Rejected',  '+94 76 543 2109', '3 hours',  'Space unavailable due to maintenance'),
  ];

  final Map<String, String> _statuses = {};

  List<_Req> get _filtered => _tab == 'All'
      ? _requests
      : _requests
          .where((r) => (_statuses[r.id] ?? r.status) == _tab)
          .toList();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isDark = app.isDarkMode;

    return Scaffold(
      backgroundColor: app.adminBg,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: app.adminTextPrimary),
                onPressed: () => context
                    .read<AppProvider>()
                    .setBookingRequestsOpen(false),
              ),
              Expanded(
                child: Text('Booking Requests',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                        color: app.adminTextPrimary)),
              ),
              const SizedBox(width: 48),
            ]),
          ),

          // Tab bar
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _tabs.length,
              itemBuilder: (_, i) {
                final t = _tabs[i];
                final active = _tab == t;
                return GestureDetector(
                  onTap: () => setState(() {
                    _tab = t;
                    _expanded = null;
                    _rejecting = null;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? app.adminAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: active
                          ? null
                          : Border.all(color: app.adminBorder.withOpacity(0.5)),
                    ),
                    child: Text(t,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: active
                              ? Colors.white
                              : app.adminTextSecondary,
                        )),
                  ),
                );
              },
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final req = _filtered[i];
                final status = _statuses[req.id] ?? req.status;
                final isExpanded = _expanded == req.id;
                final isRejecting = _rejecting == req.id;

                return _RequestCard(
                  req: req,
                  status: status,
                  isExpanded: isExpanded,
                  isRejecting: isRejecting,
                  reasonCtrl: _reasonCtrl,
                  onTap: () => setState(() {
                    _expanded = isExpanded ? null : req.id;
                    _rejecting = null;
                  }),
                  onConfirm: () => setState(() {
                    _statuses[req.id] = 'Confirmed';
                    _expanded = null;
                  }),
                  onRejectTap: () => setState(() => _rejecting = req.id),
                  onRejectCancel: () => setState(() => _rejecting = null),
                  onRejectConfirm: () => setState(() {
                    _statuses[req.id] = 'Rejected';
                    _expanded = null;
                    _rejecting = null;
                    _reasonCtrl.clear();
                  }),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _Req {
  final String id, name, initials, type, date, amount, status, phone, duration;
  final String? reason;

  const _Req(this.id, this.name, this.initials, this.type, this.date,
      this.amount, this.status, this.phone, this.duration, this.reason);
}

class _RequestCard extends StatelessWidget {
  final _Req req;
  final String status;
  final bool isExpanded, isRejecting;
  final TextEditingController reasonCtrl;
  final VoidCallback onTap, onConfirm, onRejectTap, onRejectCancel, onRejectConfirm;

  const _RequestCard({
    required this.req, required this.status,
    required this.isExpanded, required this.isRejecting,
    required this.reasonCtrl, required this.onTap,
    required this.onConfirm, required this.onRejectTap,
    required this.onRejectCancel, required this.onRejectConfirm,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'Pending':   return AppColors.orange400;
      case 'Confirmed': return AppColors.appAccent;
      case 'Rejected':  return AppColors.red400;
      default:          return AppColors.grey400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final c = _statusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isExpanded ? app.adminCard.withOpacity(0.8) : app.adminCard.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpanded ? app.adminAccent.withOpacity(0.50) : app.adminBorder.withOpacity(0.5),
          ),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: app.adminAccent.withOpacity(0.20),
                  border: Border.all(color: app.adminAccent.withOpacity(0.30)),
                ),
                child: Center(
                  child: Text(req.initials,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: app.adminAccent,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.name,
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                            color: app.adminTextPrimary)),
                    Text(req.type,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: app.adminTextSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.withOpacity(0.30)),
                ),
                child: Text(status,
                    style: AppTextStyles.label.copyWith(color: c)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(req.date, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                Text(req.amount,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: app.adminTextPrimary)),
              ],
            ),
          ),

          // Expanded
          if (isExpanded) ...[
            Divider(color: app.adminBorder.withOpacity(0.5), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.phone_outlined,
                      size: 14, color: AppColors.adminAccent),
                  const SizedBox(width: 8),
                  Text(req.phone,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: app.adminTextSecondary)),
                  const SizedBox(width: 20),
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: AppColors.adminAccent),
                  const SizedBox(width: 8),
                  Text(req.duration,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: app.adminTextSecondary)),
                ]),
                if (req.reason != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red400.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.red400.withOpacity(0.20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reason for rejection:',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.red400,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(req.reason!,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: app.adminTextSecondary)),
                      ],
                    ),
                  ),
                if (status == 'Pending') ...[
                  const SizedBox(height: 12),
                  if (!isRejecting)
                    Row(children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.appAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Confirm',
                              style: AppTextStyles.body.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onRejectTap,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: AppColors.red400.withOpacity(0.50)),
                            foregroundColor: AppColors.red400,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Reject',
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.red400,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ])
                  else
                    Column(children: [
                      TextField(
                        controller: reasonCtrl,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: app.adminTextPrimary),
                        decoration: InputDecoration(
                          hintText: 'Reason (optional)',
                          hintStyle: AppTextStyles.bodySmall
                              .copyWith(color: app.adminTextSecondary),
                          filled: true,
                          fillColor: app.adminCard.withOpacity(0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: app.adminBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: app.adminBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onRejectCancel,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: app.adminBorder),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Cancel',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: app.adminTextSecondary)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onRejectConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Confirm Reject',
                                style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ]),
                    ]),
                ],
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}