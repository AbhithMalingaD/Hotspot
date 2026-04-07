import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bottom_nav.dart';

// Tabs
import 'home_page.dart';
import 'spaces_page.dart';
import 'activity_page.dart';
import 'saved_page.dart';

// Overlays
import 'space_details_page.dart';
import 'booking_form_page.dart';
import 'directions_page.dart';
import 'my_qr_code_page.dart';
import 'profile_page.dart';
import '../widgets/notification_panel.dart';

class UserAppShell extends StatelessWidget {
  const UserAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // ── Tab content ─────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _tabContent(app.activeTab),
              ),

              // ── Bottom nav ──────────────────────────────────────────
              const Positioned(
                bottom: 0, left: 0, right: 0,
                child: BottomNav(),
              ),

              // ── Notification panel ──────────────────────────────────
              if (app.isNotificationOpen)
                const _Overlay(child: NotificationPanel()),

              // ── Space details ───────────────────────────────────────
              if (app.selectedSpaceId != null &&
                  !app.isBookingFormOpen &&
                  !app.isDirectionsOpen)
                _SlideOverlay(
                  child: SpaceDetailsPage(
                      spaceId: app.selectedSpaceId!),
                ),

              // ── Booking form ────────────────────────────────────────
              if (app.isBookingFormOpen)
                const _SlideOverlay(child: BookingFormPage()),

              // ── Directions ──────────────────────────────────────────
              if (app.isDirectionsOpen)
                const _SlideOverlay(child: DirectionsPage()),

              // ── QR code ─────────────────────────────────────────────
              if (app.selectedQRCode != null)
                _SlideOverlay(
                  child: MyQRCodePage(
                      bookingDetails: app.selectedQRCode!),
                ),

              // ── Profile ─────────────────────────────────────────────
              if (app.isProfileOpen)
                const _SlideOverlay(child: ProfilePage()),
            ],
          ),
        );
      },
    );
  }

  Widget _tabContent(AppTab tab) {
    switch (tab) {
      case AppTab.map:
        return const HomePage(key: ValueKey('map'));
      case AppTab.space:
        return const SpacesPage(key: ValueKey('space'));
      case AppTab.activity:
        return const ActivityPage(key: ValueKey('activity'));
      case AppTab.saved:
        return const SavedPage(key: ValueKey('saved'));
    }
  }
}

// ── Fade overlay (notification panel) ───────────────────────────────────────

class _Overlay extends StatelessWidget {
  final Widget child;
  const _Overlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        onTap: () =>
            context.read<AppProvider>().setNotificationOpen(false),
        child: Container(color: Colors.black.withOpacity(0.40)),
      ),
      child,
    ]);
  }
}

// ── Slide-up overlay ─────────────────────────────────────────────────────────

class _SlideOverlay extends StatefulWidget {
  final Widget child;
  const _SlideOverlay({required this.child});

  @override
  State<_SlideOverlay> createState() => _SlideOverlayState();
}

class _SlideOverlayState extends State<_SlideOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: widget.child,
    );
  }
}