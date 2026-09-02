import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'code_service.dart';

class GroupService {
  GroupService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<String> createGroup({
    required String groupName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Authenticated user not found.');
    }

    // Web kullanıcısının requester kaydını bul.
    final requesterQuery = await _firestore
        .collection('requesters')
        .where('authUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (requesterQuery.docs.isEmpty) {
      throw Exception('Requester identity not found.');
    }

    final requesterDoc = requesterQuery.docs.first;
    final requesterId = requesterDoc.id;

    final requesterData = requesterDoc.data();

    final requesterCode =
        requesterData['requesterCode']?.toString();

    if (requesterCode == null ||
        requesterCode.isEmpty) {
      throw Exception('Requester code not found.');
    }

    // Mobildeki gibi yeni group kimliği.
    final groupId = const Uuid().v4();

    final groupCode =
        CodeService.shortCodeFromId(groupId);

    final groupRef =
        _firestore.collection('groups').doc(groupId);

    final requesterDeviceRef =
        groupRef.collection('devices').doc(requesterId);

    final locale = PlatformDispatcher.instance.locale;
    final countryCode = locale.countryCode;

    final now = FieldValue.serverTimestamp();

    await _firestore.runTransaction((tx) async {
      // Şimdilik mobildeki tek-filo davranışı:
      // requester zaten bir gruba bağlıysa yeni grup oluşturma.
      final currentRequesterSnap =
          await tx.get(requesterDoc.reference);

      final existingGroupId =
          currentRequesterSnap.data()?['groupId']
              ?.toString()
              .trim();

      if (existingGroupId != null &&
          existingGroupId.isNotEmpty) {
        throw Exception(
          'Requester already belongs to a fleet.',
        );
      }

      tx.set(groupRef, {
        'activeRequesterCount': 1,
        'countryCode': countryCode,
        'createdAt': now,
        'entitlementUpdatedAt': now,
        'groupId': groupId,
        'groupCode': groupCode,
        'groupName': groupName.trim(),
        'masterRequesterId': requesterId,
        'maxRequesters': 5,
        'maxLocators': 5,
        'planStatus': 'trial',
        'purchaseStatus': 'none',
        'purchaseOwnerRequesterId': null,
        'purchasedAt': null,
        'trialStartedAt': now,
        'trialEndsAt': Timestamp.fromDate(
          DateTime.now().add(
            const Duration(days: 7),
          ),
        ),
      });

      tx.set(requesterDeviceRef, {
        'active': true,
        'authUid': user.uid,
        'isMaster': true,
        'joinedAt': now,
        'pairedLocators': {},
        'requesterCode': requesterCode,
        'requesterId': requesterId,
        'role': 'requester',
        'updatedAt': now,
      });

      tx.set(
        requesterDoc.reference,
        {
          'groupId': groupId,
          'updatedAt': now,
        },
        SetOptions(merge: true),
      );

      // Web panel erişimi.
      final fleetManagerRef = _firestore
          .collection('fleet_managers')
          .doc(user.uid)
          .collection('groups')
          .doc(groupId);

      tx.set(fleetManagerRef, {
        'groupId': groupId,
        'email': user.email,
        'createdAt': now,
        'createdBy': user.uid,
      });
    });
    return groupId;
  }
	static Future<String?> joinGroup({
		required String groupCode,
	}) async {
		final user = FirebaseAuth.instance.currentUser;

		if (user == null) {
			throw Exception('Authenticated user not found.');
		}

		// Web requester kimliğini bul.
		final requesterQuery = await _firestore
				.collection('requesters')
				.where('authUid', isEqualTo: user.uid)
				.limit(1)
				.get();

		if (requesterQuery.docs.isEmpty) {
			throw Exception('Requester identity not found.');
		}

		final requesterDoc = requesterQuery.docs.first;
		final requesterId = requesterDoc.id;
		final requesterData = requesterDoc.data();

		final requesterCode =
				requesterData['requesterCode']?.toString();

		if (requesterCode == null ||
				requesterCode.isEmpty) {
			throw Exception('Requester code not found.');
		}

		// Zaten bir filoya bağlıysa join gönderme.
		final existingGroupId =
				requesterData['groupId']?.toString().trim();

		if (existingGroupId != null &&
				existingGroupId.isNotEmpty) {
			throw Exception(
				'Requester already belongs to a fleet.',
			);
		}

		final normalizedCode =
				CodeService.normalizeCode(groupCode);

		// Fleet code ile grubu bul.
		final groupQuery = await _firestore
				.collection('groups')
				.where(
					'groupCode',
					isEqualTo: normalizedCode,
				)
				.limit(1)
				.get();

		if (groupQuery.docs.isEmpty) {
			return null;
		}

		final groupDoc = groupQuery.docs.first;
		final groupId = groupDoc.id;

		final joinRequestRef = _firestore
				.collection('groups')
				.doc(groupId)
				.collection('join_requests')
				.doc(requesterId);

		// Daha önce pending request varsa yenisini yazma.
		final existingRequest =
				await joinRequestRef.get();

		if (existingRequest.exists) {
			final status =
					existingRequest.data()?['status']?.toString();

			if (status == 'pending') {
				return groupId;
			}
		}

		await joinRequestRef.set({
			'requesterCode': requesterCode,

			// Web profilinde henüz isim tutmuyoruz.
			'requesterName': 'Requester',

			'authUid': user.uid,
			'status': 'pending',
			'createdAt': FieldValue.serverTimestamp(),
			'updatedAt': FieldValue.serverTimestamp(),
		}, SetOptions(merge: true));

		return groupId;
	}
	
}