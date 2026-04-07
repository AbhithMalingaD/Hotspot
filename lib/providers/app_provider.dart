import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/review_model.dart';
import '../models/booking_model.dart';
import '../models/space_model.dart';

class _AdminColors {
  static const Color _adminBgDark = Color(0xFF0F0C29);
  static const Color _adminCardDark = Color(0xFF1A1638);
  static const Color _adminBorderDark = Color(0xFF2D2442);
  static const Color _adminAccentDark = Color(0xFF8B5CF6);
  static const Color _adminAccent2Dark = Color(0xFF6366F1);

  static const Color _adminBgLight = Color(0xFFF1F5F9);
  static const Color _adminCardLight = Color(0xFFFFFFFF);
  static const Color _adminBorderLight = Color(0xFFE2E8F0);
  static const Color _adminAccentLight = Color(0xFF7C3AED);
  static const Color _adminAccent2Light = Color(0xFF6366F1);

  static Color bg(bool isDark) => isDark ? _adminBgDark : _adminBgLight;
  static Color card(bool isDark) => isDark ? _adminCardDark : _adminCardLight;
  static Color border(bool isDark) => isDark ? _adminBorderDark : _adminBorderLight;
  static Color accent(bool isDark) => isDark ? _adminAccentDark : _adminAccentLight;
  static Color accent2(bool isDark) => isDark ? _adminAccent2Dark : _adminAccent2Light;
}

enum AppScreen { roleSelect, signup, login, spaceSetup, userApp, adminApp }
enum AppRole   { user, admin }
enum AppTab    { map, space, activity, saved }

class AppProvider extends ChangeNotifier {

  // ── Theme state ───────────────────────────────────────────────────────────
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // ── Admin theme helpers ────────────────────────────────────────────────────
  Color get adminBg => _AdminColors.bg(_isDarkMode);
  Color get adminCard => _AdminColors.card(_isDarkMode);
  Color get adminBorder => _AdminColors.border(_isDarkMode);
  Color get adminAccent => _AdminColors.accent(_isDarkMode);
  Color get adminAccent2 => _AdminColors.accent2(_isDarkMode);
  Color get adminTextPrimary => _isDarkMode ? Colors.white : const Color(0xFF1E293B);
  Color get adminTextSecondary => _isDarkMode ? AppColors.grey400 : const Color(0xFF475569);
  Color get adminTextMuted => _isDarkMode ? AppColors.grey500 : const Color(0xFF64748B);

  // ── Navigation state ───────────────────────────────────────────────────────
  AppScreen _screen = AppScreen.roleSelect;
  AppScreen get screen => _screen;

  AppRole? _role;
  AppRole? get role => _role;

  AppTab _activeTab = AppTab.map;
  AppTab get activeTab => _activeTab;

  // ── Overlay flags ──────────────────────────────────────────────────────────
  String? _selectedSpaceId;
  String? get selectedSpaceId => _selectedSpaceId;

  bool _isBookingFormOpen = false;
  bool get isBookingFormOpen => _isBookingFormOpen;

  bool _isDirectionsOpen = false;
  bool get isDirectionsOpen => _isDirectionsOpen;

  bool _isProfileOpen = false;
  bool get isProfileOpen => _isProfileOpen;

  bool _isNotificationOpen = false;
  bool get isNotificationOpen => _isNotificationOpen;

  bool _isScanQROpen = false;
  bool get isScanQROpen => _isScanQROpen;

  bool _isBookingRequestsOpen = false;
  bool get isBookingRequestsOpen => _isBookingRequestsOpen;

  // ── Booking form data ──────────────────────────────────────────────────────
  String _bookingSpaceName = 'Urban Hub';
  String get bookingSpaceName => _bookingSpaceName;

  String _bookingPackageId = 'p1';
  String get bookingPackageId => _bookingPackageId;

  Map<String, dynamic>? _selectedQRCode;
  Map<String, dynamic>? get selectedQRCode => _selectedQRCode;

  // ── Auth actions ───────────────────────────────────────────────────────────

  void selectRole(AppRole role) {
    _role = role;
    _screen = AppScreen.signup;
    notifyListeners();
  }

  void signup() {
    _screen = _role == AppRole.admin
        ? AppScreen.spaceSetup
        : AppScreen.userApp;
    notifyListeners();
  }

  void login() {
    _screen = _role == AppRole.admin
        ? AppScreen.adminApp
        : AppScreen.userApp;
    notifyListeners();
  }

  void goToLogin() {
    _screen = AppScreen.login;
    notifyListeners();
  }

  void goToSignup() {
    _screen = AppScreen.signup;
    notifyListeners();
  }

  void completeSpaceSetup() {
    _screen = AppScreen.adminApp;
    notifyListeners();
  }

  void logout() {
    _screen = AppScreen.roleSelect;
    _role = null;
    _activeTab = AppTab.map;
    _selectedSpaceId = null;
    _isProfileOpen = false;
    _isBookingFormOpen = false;
    _isDirectionsOpen = false;
    _selectedQRCode = null;
    _isScanQROpen = false;
    _isBookingRequestsOpen = false;
    _isNotificationOpen = false;
    notifyListeners();
  }

  // ── Tab ────────────────────────────────────────────────────────────────────

  void setTab(AppTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  // ── Overlays ───────────────────────────────────────────────────────────────

  void selectSpace(String id) {
    _selectedSpaceId = id;
    notifyListeners();
  }

  void clearSpace() {
    _selectedSpaceId = null;
    notifyListeners();
  }

  void openBookingForm(String spaceName, String packageId) {
    _bookingSpaceName = spaceName;
    _bookingPackageId = packageId;
    _isBookingFormOpen = true;
    notifyListeners();
  }

  void closeBookingForm() {
    _isBookingFormOpen = false;
    notifyListeners();
  }

  void confirmBooking() {
    _isBookingFormOpen = false;
    _selectedSpaceId = null;
    _selectedQRCode = {
      'spaceName': _bookingSpaceName,
      'unitType': _bookingPackageId == 'p1' ? 'Hot Desk' : 'Meeting Room',
      'checkIn': '09:00 AM',
      'checkOut': '12:00 PM',
      'status': 'Active',
      'expiresIn': '2h 45m',
    };
    _activeTab = AppTab.activity;
    notifyListeners();
  }

  void setDirectionsOpen(bool v) {
    _isDirectionsOpen = v;
    notifyListeners();
  }

  void setProfileOpen(bool v) {
    _isProfileOpen = v;
    notifyListeners();
  }

  void setNotificationOpen(bool v) {
    _isNotificationOpen = v;
    notifyListeners();
  }

  void setScanQROpen(bool v) {
    _isScanQROpen = v;
    notifyListeners();
  }

  void setBookingRequestsOpen(bool v) {
    _isBookingRequestsOpen = v;
    notifyListeners();
  }

  void setSelectedQRCode(Map<String, dynamic>? details) {
    _selectedQRCode = details;
    notifyListeners();
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  final Map<String, List<Review>> _spaceReviews = {};
  final Map<String, Set<String>> _userReviewedSpaces = {};

  static const String _currentUserId = 'user_1';

  List<Review> getSpaceReviews(String spaceId) =>
      _spaceReviews[spaceId] ?? [];

  bool hasUserVisitedSpace(String spaceId) {
    const space = kSampleSpaces;
    final matching = space.where((s) => s.id == spaceId);
    if (matching.isEmpty) return false;
    final spaceName = matching.first.name;
    return kSampleBookings.any(
        (b) => b.status == BookingStatus.completed &&
               b.title.startsWith(spaceName));
  }

  bool hasUserReviewedSpace(String spaceId) {
    return _userReviewedSpaces[_currentUserId]?.contains(spaceId) ?? false;
  }

  void addReview(String spaceId, Review review) {
    _spaceReviews.putIfAbsent(spaceId, () => []).add(review);
    _userReviewedSpaces
        .putIfAbsent(_currentUserId, () => {})
        .add(spaceId);
    notifyListeners();
  }

  // ── Saved Spaces ─────────────────────────────────────────────────────────

  final Set<String> _savedSpaceIds = {};

  bool isSpaceSaved(String spaceId) =>
      _savedSpaceIds.contains(spaceId);

  void toggleSavedSpace(String spaceId) {
    if (_savedSpaceIds.contains(spaceId)) {
      _savedSpaceIds.remove(spaceId);
    } else {
      _savedSpaceIds.add(spaceId);
    }
    notifyListeners();
  }
}