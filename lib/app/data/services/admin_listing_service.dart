import 'package:city_guide_app/app/data/models/admin_listing_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminListingService {
  AdminListingService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _listingCollection =>
      _firestore.collection('listings');

  Stream<List<AdminListingModel>> watchListings() async* {
    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _listingCollection
              .orderBy('createdAt', descending: true)
              .snapshots()) {
        yield snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  AdminListingModel.fromDoc(doc),
            )
            .toList();
      }
    } on FirebaseException {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _listingCollection.snapshots()) {
        final List<AdminListingModel> listings = snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  AdminListingModel.fromDoc(doc),
            )
            .toList();
        listings.sort(
          (AdminListingModel a, AdminListingModel b) =>
              (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
                a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
              ),
        );
        yield listings;
      }
    }
  }

  Future<void> updateListingStatus({
    required String listingId,
    required String status,
  }) async {
    final String uid = _auth.currentUser?.uid ?? '';
    await _listingCollection.doc(listingId).update(<String, dynamic>{
      'status': status,
      'moderatedAt': FieldValue.serverTimestamp(),
      'moderatedBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createListing({
    required String name,
    required String city,
    required String category,
    required String description,
    required String imageUrl,
    required String address,
    required String contactInfo,
    required String openingHours,
    required String website,
    required double latitude,
    required double longitude,
    required double rating,
  }) async {
    final String uid = _auth.currentUser?.uid ?? '';
    await _listingCollection.add(<String, dynamic>{
      'name': name.trim(),
      'city': city.trim(),
      'category': category.trim(),
      'description': description.trim(),
      'imageUrl': imageUrl.trim(),
      'address': address.trim(),
      'contactInfo': contactInfo.trim(),
      'openingHours': openingHours.trim(),
      'website': website.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'averageRating': rating,
      'ratingsCount': 0,
      'status': 'pending',
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateListing({
    required String listingId,
    required String name,
    required String city,
    required String category,
    required String description,
    required String imageUrl,
    required String address,
    required String contactInfo,
    required String openingHours,
    required String website,
    required double latitude,
    required double longitude,
    required double rating,
  }) async {
    await _listingCollection.doc(listingId).update(<String, dynamic>{
      'name': name.trim(),
      'city': city.trim(),
      'category': category.trim(),
      'description': description.trim(),
      'imageUrl': imageUrl.trim(),
      'address': address.trim(),
      'contactInfo': contactInfo.trim(),
      'openingHours': openingHours.trim(),
      'website': website.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'averageRating': rating,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<int> renameListingsCity({
    required String oldCityName,
    required String newCityName,
  }) async {
    if (oldCityName.trim().isEmpty || newCityName.trim().isEmpty) return 0;
    if (oldCityName.trim().toLowerCase() == newCityName.trim().toLowerCase()) {
      return 0;
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _listingCollection
            .where('city', isEqualTo: oldCityName.trim())
            .get();
    if (snapshot.docs.isEmpty) return 0;

    final WriteBatch batch = _firestore.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      batch.update(doc.reference, <String, dynamic>{
        'city': newCityName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return snapshot.docs.length;
  }

  Future<int> deleteListingsByCity(String cityName) async {
    if (cityName.trim().isEmpty) return 0;
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _listingCollection
            .where('city', isEqualTo: cityName.trim())
            .get();
    if (snapshot.docs.isEmpty) return 0;

    final WriteBatch batch = _firestore.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return snapshot.docs.length;
  }
}
