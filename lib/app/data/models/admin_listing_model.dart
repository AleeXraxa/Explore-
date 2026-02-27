import 'package:cloud_firestore/cloud_firestore.dart';

class AdminListingModel {
  const AdminListingModel({
    required this.id,
    required this.name,
    required this.city,
    required this.category,
    required this.description,
    required this.status,
    required this.imageUrl,
    required this.address,
    required this.contactInfo,
    required this.openingHours,
    required this.website,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.averageRating,
    required this.ratingsCount,
    this.createdAt,
  });

  final String id;
  final String name;
  final String city;
  final String category;
  final String description;
  final String status;
  final String imageUrl;
  final String address;
  final String contactInfo;
  final String openingHours;
  final String website;
  final double latitude;
  final double longitude;
  // Legacy/seed/import rating fallback.
  final double rating;
  // User-review-driven aggregate rating.
  final double averageRating;
  final int ratingsCount;
  final DateTime? createdAt;

  bool get isPending => status == 'pending';
  double get displayRating => ratingsCount > 0 ? averageRating : rating;

  factory AdminListingModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final Timestamp? createdAtTs = data['createdAt'] as Timestamp?;

    return AdminListingModel(
      id: doc.id,
      name: data['name']?.toString().trim().isNotEmpty == true
          ? data['name'].toString().trim()
          : 'Unnamed Listing',
      city: data['city']?.toString().trim().isNotEmpty == true
          ? data['city'].toString().trim()
          : 'Unknown City',
      category: data['category']?.toString().trim().isNotEmpty == true
          ? data['category'].toString().trim()
          : 'General',
      description: data['description']?.toString().trim() ?? '',
      status: _normalizeStatus(data['status']?.toString()),
      imageUrl: data['imageUrl']?.toString().trim() ?? '',
      address: data['address']?.toString().trim() ?? 'No address provided',
      contactInfo:
          data['contactInfo']?.toString().trim() ?? 'No contact info provided',
      openingHours:
          data['openingHours']?.toString().trim() ?? 'Hours not available',
      website: data['website']?.toString().trim() ?? '',
      latitude: _parseCoordinate(data['latitude']),
      longitude: _parseCoordinate(data['longitude']),
      rating: _parseRating(data['rating']),
      averageRating: _parseRating(data['averageRating']),
      ratingsCount: _parseInt(data['ratingsCount']),
      createdAt: createdAtTs?.toDate(),
    );
  }

  static String _normalizeStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'approved':
      case 'rejected':
      case 'pending':
        return raw!.toLowerCase();
      default:
        return 'pending';
    }
  }

  static double _parseRating(dynamic value) {
    if (value is num) return value.toDouble().clamp(0, 5);
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed.clamp(0, 5);
      }
    }
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseCoordinate(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
