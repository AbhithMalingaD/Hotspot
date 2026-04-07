class SpaceModel {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int seats;
  final String? tag;
  final List<String> types;
  final String address;
  final double lat;
  final double lng;
  final double distanceKm;
  final int pricePerHour;

  const SpaceModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.seats,
    this.tag,
    required this.types,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.pricePerHour,
  });
}

// ── Sample Data (mirrors your JS constants) ──────────────────────────────────

const List<SpaceModel> kSampleSpaces = [
  SpaceModel(
    id: '1',
    name: 'Urban Hub',
    imageUrl:
        'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80&w=400&h=300',
    rating: 4.8,
    seats: 12,
    tag: 'Hot',
    types: ['Hot Desk', 'Meeting Room', 'Event Space'],
    address: '123 Galle Road, Colombo 03',
    lat: 6.9271,
    lng: 79.8612,
    distanceKm: 0.4,
    pricePerHour: 500,
  ),
  SpaceModel(
    id: '2',
    name: 'Cafe Works',
    imageUrl:
        'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&q=80&w=400&h=300',
    rating: 4.5,
    seats: 8,
    tag: 'Shared',
    types: ['Hot Desk'],
    address: '45 Duplication Road, Colombo 04',
    lat: 6.9220,
    lng: 79.8580,
    distanceKm: 0.8,
    pricePerHour: 600,
  ),
  SpaceModel(
    id: '3',
    name: 'The Hive',
    imageUrl:
        'https://images.unsplash.com/photo-1524758631624-e2822e304c36?auto=format&fit=crop&q=80&w=400&h=300',
    rating: 4.9,
    seats: 20,
    tag: 'Premium',
    types: ['Hot Desk', 'Private Office', 'Meeting Room'],
    address: '78 Union Place, Colombo 02',
    lat: 6.9300,
    lng: 79.8650,
    distanceKm: 1.1,
    pricePerHour: 800,
  ),
  SpaceModel(
    id: '4',
    name: 'Studio 54',
    imageUrl:
        'https://images.unsplash.com/photo-1527192491265-7e15c55b1ed2?auto=format&fit=crop&q=80&w=400&h=300',
    rating: 4.6,
    seats: 15,
    types: ['Meeting Room', 'Event Space'],
    address: '12 Bauddhaloka Mw, Colombo 07',
    lat: 6.9250,
    lng: 79.8700,
    distanceKm: 1.5,
    pricePerHour: 700,
  ),
  SpaceModel(
    id: '5',
    name: 'Green Desk',
    imageUrl:
        'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&q=80&w=400&h=300',
    rating: 4.7,
    seats: 10,
    tag: 'New',
    types: ['Hot Desk', 'Private Office'],
    address: '90 Havelock Road, Colombo 05',
    lat: 6.9190,
    lng: 79.8550,
    distanceKm: 0.6,
    pricePerHour: 450,
  ),
  SpaceModel(
    id: '6',
    name: 'Tech Loft',
    imageUrl:
        'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&q=80&w=400&h=300',
    rating: 4.4,
    seats: 25,
    types: ['Private Office', 'Meeting Room'],
    address: '34 Flower Road, Colombo 07',
    lat: 6.9220,
    lng: 79.8600,
    distanceKm: 1.2,
    pricePerHour: 650,
  ),
];