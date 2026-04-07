enum BookingStatus { active, pending, completed, cancelled }
enum CancelledBy   { user, space }

class BookingModel {
  final String id;
  final String title;
  final String subtitle;
  final BookingStatus status;
  final String address;
  final String checkIn;
  final String checkOut;
  final String duration;
  final String price;
  final CancelledBy? cancelledBy;
  final String? cancelReason;
  final String? cancelledByAdmin;

  const BookingModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.address,
    required this.checkIn,
    required this.checkOut,
    required this.duration,
    required this.price,
    this.cancelledBy,
    this.cancelReason,
    this.cancelledByAdmin,
  });
}

const List<BookingModel> kSampleBookings = [
  BookingModel(
    id: '1',
    title: 'Urban Hub — Hot Desk',
    subtitle: 'Today · 2:00 PM – 5:00 PM',
    status: BookingStatus.active,
    address: '123 Galle Road, Colombo 03',
    checkIn: '2:00 PM',
    checkOut: '5:00 PM',
    duration: '3 hours',
    price: 'LKR 1,500',
  ),
  BookingModel(
    id: '2',
    title: 'The Hive — Private Room',
    subtitle: 'Tomorrow · 10:00 AM',
    status: BookingStatus.pending,
    address: '78 Union Place, Colombo 02',
    checkIn: '10:00 AM',
    checkOut: '12:00 PM',
    duration: '2 hours',
    price: 'LKR 3,000',
  ),
  BookingModel(
    id: '3',
    title: 'Green Desk — Hot Desk',
    subtitle: 'Tomorrow · 2:00 PM',
    status: BookingStatus.pending,
    address: '90 Havelock Road, Colombo 05',
    checkIn: '2:00 PM',
    checkOut: '6:00 PM',
    duration: '4 hours',
    price: 'LKR 1,800',
  ),
  BookingModel(
    id: '4',
    title: 'Cafe Works — Hot Desk',
    subtitle: 'Mar 12 · Completed',
    status: BookingStatus.completed,
    address: '45 Duplication Road, Colombo 04',
    checkIn: '9:00 AM',
    checkOut: '2:00 PM',
    duration: '5 hours',
    price: 'LKR 3,000',
  ),
  BookingModel(
    id: '5',
    title: 'Studio 54 — Board Room',
    subtitle: 'Mar 10 · Completed',
    status: BookingStatus.completed,
    address: '12 Bauddhaloka Mw, Colombo 07',
    checkIn: '3:00 PM',
    checkOut: '5:00 PM',
    duration: '2 hours',
    price: 'LKR 7,000',
  ),
  BookingModel(
    id: '6',
    title: 'Nexus Space — Board Room',
    subtitle: 'Mar 8 · Cancelled by you',
    status: BookingStatus.cancelled,
    cancelledBy: CancelledBy.user,
    address: '56 Ward Place, Colombo 07',
    checkIn: '1:00 PM',
    checkOut: '4:00 PM',
    duration: '3 hours',
    price: 'LKR 10,500',
  ),
  BookingModel(
    id: '7',
    title: 'Tech Loft — Private Office',
    subtitle: 'Mar 6 · Cancelled by space',
    status: BookingStatus.cancelled,
    cancelledBy: CancelledBy.space,
    cancelReason:
        'The private office is under maintenance during the requested time slot. We apologize for the inconvenience.',
    cancelledByAdmin: 'Ruwan (Space Admin)',
    address: '34 Flower Road, Colombo 07',
    checkIn: '9:00 AM',
    checkOut: '1:00 PM',
    duration: '4 hours',
    price: 'LKR 6,000',
  ),
];