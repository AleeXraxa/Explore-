import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSettingsService {
  AdminSettingsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<Map<String, dynamic>> loadAdminProfileAndSettings() async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      return <String, dynamic>{
        'fullName': 'Alee Khan',
        'email': 'admin@explora.app',
        'phone': '+92 300 1234567',
        'strictModeration': true,
        'autoHideFlagged': false,
        'realTimeAlerts': true,
      };
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(uid).get();
    final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
    final Map<String, dynamic> prefs =
        (data['adminPreferences'] as Map<String, dynamic>?) ??
            <String, dynamic>{};

    return <String, dynamic>{
      'fullName': data['fullName']?.toString().trim().isNotEmpty == true
          ? data['fullName'].toString().trim()
          : 'Alee Khan',
      'email': data['email']?.toString().trim().isNotEmpty == true
          ? data['email'].toString().trim()
          : 'admin@explora.app',
      'phone': data['phone']?.toString().trim().isNotEmpty == true
          ? data['phone'].toString().trim()
          : '+92 300 1234567',
      'strictModeration': prefs['strictModeration'] != false,
      'autoHideFlagged': prefs['autoHideFlagged'] == true,
      'realTimeAlerts': prefs['realTimeAlerts'] != false,
    };
  }

  Future<void> saveAdminPreferences({
    required bool strictModeration,
    required bool autoHideFlagged,
    required bool realTimeAlerts,
  }) async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    await _firestore.collection('users').doc(uid).set(
      <String, dynamic>{
        'adminPreferences': <String, dynamic>{
          'strictModeration': strictModeration,
          'autoHideFlagged': autoHideFlagged,
          'realTimeAlerts': realTimeAlerts,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

