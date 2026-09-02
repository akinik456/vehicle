import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinResponseService {
  JoinResponseService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      watchJoinResponse({
    required String groupId,
    required void Function() onApproved,
    required void Function() onRejected,
    required void Function(Object error) onError,
  }) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Authenticated user not found.');
    }

    late StreamSubscription<
        DocumentSnapshot<Map<String, dynamic>>> subscription;

    subscription = _findRequester(user.uid).asStream().listen(
      (requesterDoc) {
        final requesterId = requesterDoc.id;

        final requestRef = _firestore
            .collection('groups')
            .doc(groupId)
            .collection('join_requests')
            .doc(requesterId);

        subscription.cancel();

        subscription = requestRef.snapshots().listen(
          (snapshot) async {
            if (!snapshot.exists) return;

            final status =
                snapshot.data()?['status']?.toString();

            if (status == 'approved') {
              try {
                await _completeApprovedJoin(
                  user: user,
                  requesterDoc: requesterDoc,
                  groupId: groupId,
                  requestRef: requestRef,
                );

                await subscription.cancel();

                onApproved();
              } catch (e) {
                onError(e);
              }

              return;
            }

            if (status == 'rejected') {
              await requestRef.delete();
              await subscription.cancel();

              onRejected();
            }
          },
          onError: onError,
        );
      },
      onError: onError,
    );

    return subscription;
  }

  static Future<
      QueryDocumentSnapshot<Map<String, dynamic>>> _findRequester(
    String authUid,
  ) async {
    final query = await _firestore
        .collection('requesters')
        .where('authUid', isEqualTo: authUid)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Requester identity not found.');
    }

    return query.docs.first;
  }

  static Future<void> _completeApprovedJoin({
    required User user,
    required QueryDocumentSnapshot<Map<String, dynamic>>
        requesterDoc,
    required String groupId,
    required DocumentReference<Map<String, dynamic>>
        requestRef,
  }) async {
    final requesterId = requesterDoc.id;

    // Mobildeki gibi önce master tarafının requester
    // device kaydını oluşturduğunu doğrula.
    final requesterDevice = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('devices')
        .doc(requesterId)
        .get();

    if (!requesterDevice.exists) {
      throw Exception(
        'Approved requester device not found.',
      );
    }

    final now = FieldValue.serverTimestamp();

    final fleetManagerRef = _firestore
        .collection('fleet_managers')
        .doc(user.uid)
        .collection('groups')
        .doc(groupId);

    final batch = _firestore.batch();

    batch.set(
      requesterDoc.reference,
      {
        'groupId': groupId,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );

    batch.set(
      fleetManagerRef,
      {
        'groupId': groupId,
        'email': user.email,
        'createdAt': now,
        'createdBy': user.uid,
      },
      SetOptions(merge: true),
    );

    batch.delete(requestRef);

    await batch.commit();
  }
}