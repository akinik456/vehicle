import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'code_service.dart';

class LocatorPairingService {
  LocatorPairingService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<Map<String, String>?> sendPairingRequest({
    required String locatorInput,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return {
          'error': 'not_authenticated',
        };
      }

      // ---------------------------------------------------------
      // REQUESTER
      // ---------------------------------------------------------

      final requesterQuery = await _firestore
          .collection('requesters')
          .where('authUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (requesterQuery.docs.isEmpty) {
        return {
          'error': 'requester_not_found',
        };
      }

      final requesterDoc = requesterQuery.docs.first;
      final requesterData = requesterDoc.data();

      final requesterId = requesterDoc.id;

      final requesterCode =
          (requesterData['requesterCode'] ?? '').toString();

      final groupId =
          (requesterData['groupId'] ?? '').toString();

      // Web hesabında henüz requesterName tutmuyoruz.
      const requesterName = 'Requester';

      if (requesterCode.isEmpty || groupId.isEmpty) {
        return {
          'error': 'missing_requester_data',
        };
      }

      // ---------------------------------------------------------
      // LOCATOR
      // ---------------------------------------------------------

      final normalized =
          CodeService.normalizeCode(locatorInput);

      String locatorId;

      if (CodeService.isValidCode(normalized)) {
        final query = await _firestore
            .collection('locators')
            .where(
              'locatorCode',
              isEqualTo: normalized,
            )
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          return {
            'error': 'member_not_found',
          };
        }

        locatorId = query.docs.first.id;
      } else {
        final locatorDoc = await _firestore
            .collection('locators')
            .doc(locatorInput.trim())
            .get();

        if (!locatorDoc.exists) {
          return {
            'error': 'member_not_found',
          };
        }

        locatorId = locatorInput.trim();
      }

      // ---------------------------------------------------------
      // REQUESTER DEVICE
      // ---------------------------------------------------------

      final requesterDeviceDoc = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('devices')
          .doc(requesterId)
          .get();

      if (!requesterDeviceDoc.exists) {
        return {
          'error': 'missing_requester_device',
        };
      }

      final requesterDeviceData =
          requesterDeviceDoc.data() ?? {};

      final pairedLocators =
          Map<String, dynamic>.from(
        requesterDeviceData['pairedLocators'] ?? {},
      );

      if (pairedLocators.containsKey(locatorId)) {
        return {
          'error': 'member_already_paired',
        };
      }

      // ---------------------------------------------------------
      // GROUP / VEHICLE LIMIT
      // ---------------------------------------------------------

      final existingDeviceDoc = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('devices')
          .doc(locatorId)
          .get();

      final groupSnap = await _firestore
          .collection('groups')
          .doc(groupId)
          .get();

      if (!groupSnap.exists) {
        return {
          'error': 'group_not_found',
        };
      }

      final groupData = groupSnap.data() ?? {};

      final maxLocators =
          (groupData['maxLocators'] ?? 1) as num;

      final activeLocatorCount =
          (groupData['activeLocatorCount'] ?? 0) as num;

      final locatorAlreadyInGroup =
          existingDeviceDoc.exists;

      if (!locatorAlreadyInGroup &&
          activeLocatorCount >= maxLocators) {
        return {
          'error': 'member_limit_reached',
        };
      }

      // ---------------------------------------------------------
      // EXISTING PENDING REQUEST
      // ---------------------------------------------------------

      final pendingRequestSnap = await _firestore
          .collection('locators')
          .doc(locatorId)
          .collection('pairing_requests')
          .where(
            'status',
            isEqualTo: 'pending',
          )
          .limit(1)
          .get();

      if (pendingRequestSnap.docs.isNotEmpty) {
        return {
          'error': 'pairing_request_pending',
        };
      }

      // ---------------------------------------------------------
      // CREATE PAIRING REQUEST
      // ---------------------------------------------------------

      final requestRef = _firestore
          .collection('locators')
          .doc(locatorId)
          .collection('pairing_requests')
          .doc();

      await requestRef.set({
        'requesterId': requesterId,
        'requesterName': requesterName,
        'requesterCode': requesterCode,
        'groupId': groupId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'locatorId': locatorId,
        'requestId': requestRef.id,
      };
    } catch (e) {
      return {
        'error': 'pairing_error',
      };
    }
  }
}