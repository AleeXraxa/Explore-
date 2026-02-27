import 'package:city_guide_app/app/data/models/admin_review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserReviewService {
  UserReviewService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<bool> hasCurrentUserReviewedListing(String listingId) async {
    final String uid = currentUserId;
    final String normalizedListingId = listingId.trim();
    if (uid.isEmpty || normalizedListingId.isEmpty) return false;
    final String reviewId = _buildReviewId(
      listingId: normalizedListingId,
      userId: uid,
    );
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection('reviews')
        .doc(reviewId)
        .get();
    return doc.exists;
  }

  Future<void> submitReview({
    required String listingId,
    required String listingName,
    required double rating,
    required String comment,
  }) async {
    final String uid = currentUserId;
    if (uid.isEmpty) {
      throw Exception('Please login to submit a review.');
    }
    final String normalizedListingId = listingId.trim();
    if (normalizedListingId.isEmpty) {
      throw Exception('Listing is invalid.');
    }
    final String reviewId = _buildReviewId(
      listingId: normalizedListingId,
      userId: uid,
    );
    final QuerySnapshot<Map<String, dynamic>> duplicateSnapshot =
        await _firestore
            .collection('reviews')
            .where('listingId', isEqualTo: normalizedListingId)
            .where('userId', isEqualTo: uid)
            .limit(1)
            .get();
    if (duplicateSnapshot.docs.isNotEmpty) {
      throw Exception('You already reviewed this listing.');
    }

    final User? user = _auth.currentUser;
    final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
        .collection('users')
        .doc(uid)
        .get();
    final String userName =
        userDoc.data()?['fullName']?.toString().trim().isNotEmpty == true
        ? userDoc.data()!['fullName'].toString().trim()
        : (user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!.trim()
              : 'Anonymous User');
    final String userEmail =
        userDoc.data()?['email']?.toString().trim().isNotEmpty == true
        ? userDoc.data()!['email'].toString().trim()
        : (user?.email ?? '');

    final DocumentReference<Map<String, dynamic>> reviewRef = _firestore
        .collection('reviews')
        .doc(reviewId);
    final DocumentSnapshot<Map<String, dynamic>> existingReview =
        await reviewRef.get();
    if (existingReview.exists) {
      throw Exception('You already reviewed this listing.');
    }

    await reviewRef.set(<String, dynamic>{
      'id': reviewId,
      'listingId': normalizedListingId,
      'listingName': listingName.trim(),
      'userId': uid,
      'userName': userName,
      'userEmail': userEmail,
      'comment': comment.trim(),
      'rating': rating,
      'likesCount': 0,
      'likedByUserIds': <String>[],
      'status': 'visible',
      'isFlagged': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _recomputeListingRatingAggregates(listingId: normalizedListingId);
  }

  Stream<List<AdminReviewModel>> watchListingReviews(String listingId) async* {
    if (listingId.trim().isEmpty) {
      yield const <AdminReviewModel>[];
      return;
    }

    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _firestore
              .collection('reviews')
              .where('listingId', isEqualTo: listingId.trim())
              .where('status', isEqualTo: 'visible')
              .orderBy('createdAt', descending: true)
              .snapshots()) {
        final List<AdminReviewModel> items = snapshot.docs.map((
          QueryDocumentSnapshot<Map<String, dynamic>> doc,
        ) {
          return AdminReviewModel.fromDoc(doc);
        }).toList();
        yield items;
      }
    } on FirebaseException {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _firestore
              .collection('reviews')
              .where('listingId', isEqualTo: listingId.trim())
              .where('status', isEqualTo: 'visible')
              .snapshots()) {
        final List<AdminReviewModel> items = snapshot.docs.map((
          QueryDocumentSnapshot<Map<String, dynamic>> doc,
        ) {
          return AdminReviewModel.fromDoc(doc);
        }).toList();
        items.sort(
          (AdminReviewModel a, AdminReviewModel b) =>
              (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
                a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
              ),
        );
        yield items;
      }
    }
  }

  Future<void> likeReview(String reviewId) async {
    final String normalizedReviewId = reviewId.trim();
    final String uid = currentUserId;
    if (normalizedReviewId.isEmpty || uid.isEmpty) return;
    await _firestore.runTransaction((Transaction tx) async {
      final DocumentReference<Map<String, dynamic>> ref = _firestore
          .collection('reviews')
          .doc(normalizedReviewId);
      final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(ref);
      if (!snap.exists) return;
      final List<String> likedBy = _parseStringList(
        snap.data()?['likedByUserIds'],
      );
      if (likedBy.contains(uid)) {
        return;
      }
      final int currentLikes =
          (snap.data()?['likesCount'] as num?)?.toInt() ?? 0;
      tx.update(ref, <String, dynamic>{
        'likesCount': currentLikes + 1,
        'likedByUserIds': FieldValue.arrayUnion(<String>[uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  String _buildReviewId({required String listingId, required String userId}) {
    final String safeListing = listingId.replaceAll('/', '_').trim();
    final String safeUser = userId.replaceAll('/', '_').trim();
    return '${safeListing}_$safeUser';
  }

  List<String> _parseStringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value
        .map((dynamic item) => item.toString().trim())
        .where((String item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _recomputeListingRatingAggregates({
    required String listingId,
  }) async {
    if (listingId.isEmpty) return;
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .where('status', isEqualTo: 'visible')
        .get();

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> reviews =
        snapshot.docs;
    if (reviews.isEmpty) {
      await _firestore
          .collection('listings')
          .doc(listingId)
          .update(<String, dynamic>{
            'averageRating': 0.0,
            'ratingsCount': 0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return;
    }

    double total = 0;
    for (final QueryDocumentSnapshot<Map<String, dynamic>> review in reviews) {
      final dynamic raw = review.data()['rating'];
      if (raw is num) {
        total += raw.toDouble().clamp(0, 5);
      } else if (raw is String) {
        final double? parsed = double.tryParse(raw);
        if (parsed != null) {
          total += parsed.clamp(0, 5);
        }
      }
    }

    final int count = reviews.length;
    final double average = count == 0 ? 0 : total / count;
    await _firestore
        .collection('listings')
        .doc(listingId)
        .update(<String, dynamic>{
          'averageRating': double.parse(average.toStringAsFixed(2)),
          'ratingsCount': count,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
