import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  static const _items = [
    _NotifItem(
      message: 'Your booking at The Hive has been confirmed',
      time: '2 hrs ago',
      dotColor: AppColors.appAccent,
    ),
    _NotifItem(
      message: 'Urban Hub posted a 20% weekend offer',
      time: 'Yesterday',
      dotColor: AppColors.orange500,
    ),
    _NotifItem(
      message: 'Your QR code for Cafe Works has expired',
      time: 'Mar 12',
      dotColor: AppColors.grey500,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.appBg.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28)),
          border: Border(
              bottom: BorderSide(
                  color: Colors.white.withOpacity(0.10))),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notifications',
                        style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.grey400, size: 18),
                      onPressed: () => context
                          .read<AppProvider>()
                          .setNotificationOpen(false),
                    ),
                  ],
                ),
              ),
              ..._items.map((item) => _NotifTile(item: item)),
              TextButton(
                onPressed: () => context
                    .read<AppProvider>()
                    .setNotificationOpen(false),
                child: Center(
                  child: Text('Mark all as read',
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.appAccent)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifItem {
  final String message;
  final String time;
  final Color dotColor;
  const _NotifItem(
      {required this.message,
      required this.time,
      required this.dotColor});
}

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  const _NotifTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: item.dotColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.message,
                    style: AppTextStyles.body),
                const SizedBox(height: 4),
                Text(item.time,
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}