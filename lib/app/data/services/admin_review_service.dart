import 'package:city_guide_app/app/data/models/admin_review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminReviewService {
  AdminReviewService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');
  CollectionReference<Map<String, dynamic>> get _listingsCollection =>
      _firestore.collection('listings');

  Stream<List<AdminReviewModel>> watchReviews() async* {
    yield const <AdminReviewModel>[];

    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _reviewsCollection.orderBy('createdAt', descending: true).snapshots()) {
        yield snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  AdminReviewModel.fromDoc(doc),
            )
            .toList();
      }
    } on FirebaseException {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _reviewsCollection.snapshots()) {
        final List<AdminReviewModel> reviews = snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  AdminReviewModel.fromDoc(doc),
            )
            .toList();
        reviews.sort(
          (AdminReviewModel a, AdminReviewModel b) =>
              (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                  .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
        yield reviews;
      }
    }
  }

  Future<void> updateReviewStatus({
    required String reviewId,
    required String status,
    required String reasonCode,
    String moderationNote = '',
  }) async {
    final String uid = _auth.currentUser?.uid ?? '';
    await _reviewsCollection.doc(reviewId).update(<String, dynamic>{
      'status': status,
      'moderationReasonCode': reasonCode,
      'moderationNote': moderationNote.trim(),
      'moderatedBy': uid,
      'moderatedAt': FieldValue.serverTimestamp(),
      'moderationHistory': FieldValue.arrayUnion(<Map<String, dynamic>>[
        <String, dynamic>{
          'action': status,
          'reasonCode': reasonCode,
          'note': moderationNote.trim(),
          'moderatedBy': uid,
          'at': Timestamp.now(),
        },
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> recomputeListingRatingAggregates({
    required String listingId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _reviewsCollection
        .where('listingId', isEqualTo: listingId)
        .where('status', isEqualTo: 'visible')
        .get();

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> reviews = snapshot.docs;
    if (reviews.isEmpty) {
      await _listingsCollection.doc(listingId).update(<String, dynamic>{
        'averageRating': 0.0,
        'ratingsCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    double total = 0;
    for (final QueryDocumentSnapshot<Map<String, dynamic>> review in reviews) {
      final dynamic ratingRaw = review.data()['rating'];
      if (ratingRaw is num) {
        total += ratingRaw.toDouble().clamp(0, 5);
      } else if (ratingRaw is String) {
        final double? parsed = double.tryParse(ratingRaw);
        if (parsed != null) {
          total += parsed.clamp(0, 5);
        }
      }
    }

    final int count = reviews.length;
    final double average = count == 0 ? 0 : total / count;

    await _listingsCollection.doc(listingId).update(<String, dynamic>{
      'averageRating': double.parse(average.toStringAsFixed(2)),
      'ratingsCount': count,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
