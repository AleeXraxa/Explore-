import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReviewModel {
  const AdminReviewModel({
    required this.id,
    required this.listingId,
    required this.listingName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.comment,
    required this.rating,
    required this.likesCount,
    required this.likedByUserIds,
    required this.status,
    required this.isFlagged,
    required this.moderationReasonCode,
    required this.moderationNote,
    required this.moderatedBy,
    required this.moderationHistory,
    this.createdAt,
    this.moderatedAt,
  });

  final String id;
  final String listingId;
  final String listingName;
  final String userId;
  final String userName;
  final String userEmail;
  final String comment;
  final double rating;
  final int likesCount;
  final List<String> likedByUserIds;
  final String status;
  final bool isFlagged;
  final String moderationReasonCode;
  final String moderationNote;
  final String moderatedBy;
  final DateTime? createdAt;
  final DateTime? moderatedAt;
  final List<ReviewModerationEvent> moderationHistory;

  bool get isVisible => status == 'visible';
  bool get isHidden => status == 'hidden';
  bool get isRemoved => status == 'removed';
  bool isLikedBy(String userId) => likedByUserIds.contains(userId.trim());
  ReviewModerationEvent? get latestModerationEvent =>
      moderationHistory.isEmpty ? null : moderationHistory.first;

  factory AdminReviewModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final Timestamp? createdAtTs = data['createdAt'] as Timestamp?;
    final Timestamp? moderatedAtTs = data['moderatedAt'] as Timestamp?;
    return AdminReviewModel(
      id: doc.id,
      listingId: data['listingId']?.toString() ?? '',
      listingName: data['listingName']?.toString().trim().isNotEmpty == true
          ? data['listingName'].toString().trim()
          : 'Unknown Listing',
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString().trim().isNotEmpty == true
          ? data['userName'].toString().trim()
          : 'Anonymous User',
      userEmail: data['userEmail']?.toString().trim() ?? '',
      comment: data['comment']?.toString().trim() ?? '',
      rating: _parseRating(data['rating']),
      likesCount: _parseInt(data['likesCount']),
      likedByUserIds: _parseStringList(data['likedByUserIds']),
      status: _normalizeStatus(data['status']?.toString()),
      isFlagged: data['isFlagged'] == true,
      moderationReasonCode:
          data['moderationReasonCode']?.toString().trim() ?? '',
      moderationNote: data['moderationNote']?.toString().trim() ?? '',
      moderatedBy: data['moderatedBy']?.toString().trim() ?? '',
      moderationHistory: _parseModerationHistory(data['moderationHistory']),
      createdAt: createdAtTs?.toDate(),
      moderatedAt: moderatedAtTs?.toDate(),
    );
  }

  static String _normalizeStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'hidden':
      case 'removed':
      case 'visible':
        return raw!.toLowerCase();
      default:
        return 'visible';
    }
  }

  static double _parseRating(dynamic value) {
    if (value is num) return value.toDouble().clamp(0, 5);
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed.clamp(0, 5);
    }
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value
        .map((dynamic item) => item.toString().trim())
        .where((String item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  static List<ReviewModerationEvent> _parseModerationHistory(dynamic raw) {
    if (raw is! List) return const <ReviewModerationEvent>[];

    final List<ReviewModerationEvent> items = raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> item) {
          final dynamic atRaw = item['at'];
          DateTime? at;
          if (atRaw is Timestamp) {
            at = atRaw.toDate();
          } else if (atRaw is String) {
            at = DateTime.tryParse(atRaw);
          }
          return ReviewModerationEvent(
            action: item['action']?.toString().trim() ?? '',
            reasonCode: item['reasonCode']?.toString().trim() ?? '',
            note: item['note']?.toString().trim() ?? '',
            moderatedBy: item['moderatedBy']?.toString().trim() ?? '',
            at: at,
          );
        })
        .where((ReviewModerationEvent item) => item.action.isNotEmpty)
        .toList();

    items.sort(
      (ReviewModerationEvent a, ReviewModerationEvent b) =>
          (b.at ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            a.at ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
    );
    return items;
  }
}

class ReviewModerationEvent {
  const ReviewModerationEvent({
    required this.action,
    required this.reasonCode,
    required this.note,
    required this.moderatedBy,
    required this.at,
  });

  final String action;
  final String reasonCode;
  final String note;
  final String moderatedBy;
  final DateTime? at;
}
