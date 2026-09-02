import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PairingResponseService {
  PairingResponseService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      watchPairingResponse({
    required String locatorId,
    required String requestId,
    required void Function() onApproved,
    required void Function() onRejected,
    required void Function(Object error) onError,
  }) {
    final ref = _firestore
        .collection('locators')
        .doc(locatorId)
        .collection('pairing_requests')
        .doc(requestId);

    return ref.snapshots().listen(
      (snapshot) async {
        if (!snapshot.exists) return;

        final data = snapshot.data();
        if (data == null) return;

        final status = data['status']?.toString();

        if (status == 'approved') {
          try {
            await _completeApprovedPairing(
              locatorId: locatorId,
            );

            await ref.delete();

            onApproved();
          } catch (e) {
            onError(e);
          }

          return;
        }

        if (status == 'rejected') {
          try {
            await ref.delete();
            onRejected();
          } catch (e) {
            onError(e);
          }
        }
      },
      onError: onError,
    );
  }

  static Future<void> _completeApprovedPairing({
    required String locatorId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('not_authenticated');
    }

    final requesterQuery = await _firestore
        .collection('requesters')
        .where('authUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (requesterQuery.docs.isEmpty) {
      throw Exception('requester_not_found');
    }

    final requesterDoc = requesterQuery.docs.first;
    final requesterData = requesterDoc.data();

    final requesterId = requesterDoc.id;

    final requesterCode =
        (requesterData['requesterCode'] ?? '').toString();

    final groupId =
        (requesterData['groupId'] ?? '').toString();

    if (groupId.isEmpty) {
      throw Exception('group_not_found');
    }

    final locatorSnap = await _firestore
        .collection('locators')
        .doc(locatorId)
        .get();

    final locatorData = locatorSnap.data() ?? {};

    final locatorCode =
        (locatorData['locatorCode'] ?? '------').toString();

    final now = FieldValue.serverTimestamp();

    // ---------------------------------------------------------
    // 1. REQUESTER -> pairedLocators
    // ---------------------------------------------------------

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('devices')
        .doc(requesterId)
        .set({
      'pairedLocators': {
        locatorId: {
          'locatorCode': locatorCode,
          'pairedAt': now,
        },
      },
      'updatedAt': now,
    }, SetOptions(merge: true));

    // ---------------------------------------------------------
    // 2. LOCATOR DEFAULT SETTINGS
    // ---------------------------------------------------------

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('devices')
        .doc(locatorId)
        .collection('settings')
        .doc('config')
        .set({
      'gpsOffAlert': true,
      'batteryLowAlert': true,
      'batteryLowLevel': 20,
      'geofenceAlert': true,
      'movementAlert': true,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    // ---------------------------------------------------------
    // 3. REQUESTER NOTIFY SETTINGS
    // ---------------------------------------------------------

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('devices')
        .doc(locatorId)
        .collection('notifyRequesters')
        .doc(requesterId)
        .set({
      'callMe': true,
      'gpsOff': true,
      'batteryLow': true,
      'geofence': false,
      'movement': false,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    // requesterCode şu an burada gerekmiyor.
    // Locator approve tarafı pairedRequesters kaydını zaten yapıyor.
    if (requesterCode.isEmpty) {
      // Bilerek boş bırakıyoruz.
    }
  }
}