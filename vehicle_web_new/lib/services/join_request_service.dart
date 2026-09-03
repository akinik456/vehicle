import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinRequestService {
  JoinRequestService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      watchPendingJoinRequests({
    required String groupId,
  }) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('join_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  static Future<void> rejectJoinRequest({
    required String groupId,
    required String requesterId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Authenticated user not found.');
    }

    final joinRequestRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('join_requests')
        .doc(requesterId);

    await joinRequestRef.update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> approveJoinRequest({
    required String groupId,
    required String requesterId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Authenticated user not found.');
    }

    final requesterQuery = await _firestore
        .collection('requesters')
        .where('authUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (requesterQuery.docs.isEmpty) {
      throw Exception('Current requester not found.');
    }

    final currentRequesterId =
        requesterQuery.docs.first.id;

    final groupRef =
        _firestore.collection('groups').doc(groupId);

    final currentRequesterRef = groupRef
        .collection('devices')
        .doc(currentRequesterId);

    final requesterRef = groupRef
        .collection('devices')
        .doc(requesterId);

    final joinRequestRef = groupRef
        .collection('join_requests')
        .doc(requesterId);

    await _firestore.runTransaction((tx) async {
      final joinRequest =
          await tx.get(joinRequestRef);

      if (!joinRequest.exists) {
        throw Exception('join_request_not_found');
      }

      final groupDoc =
          await tx.get(groupRef);

      if (!groupDoc.exists) {
        throw Exception('group_not_found');
      }

      final currentRequesterDoc =
          await tx.get(currentRequesterRef);

      if (!currentRequesterDoc.exists) {
        throw Exception('current_requester_not_found');
      }

      final currentRequesterData =
          currentRequesterDoc.data() ?? {};

      if (currentRequesterData['isMaster'] != true) {
        throw Exception('not_master_requester');
      }

      final groupData =
          groupDoc.data() ?? {};

      final maxRequesters =
          groupData['maxRequesters'] ?? 1;

      final activeRequesterCount =
          groupData['activeRequesterCount'] ?? 0;

      if (activeRequesterCount >= maxRequesters) {
        throw Exception('requester_capacity_reached');
      }

      final joinData =
          joinRequest.data() ?? {};

      tx.set(requesterRef, {
        'requesterCode':
            joinData['requesterCode'],
        'role': 'requester',
        'isMaster': false,
        'active': true,
        'isEntitled': true,
        'authUid': joinData['authUid'] ?? '',
        'pairedLocators': {},
        'joinedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(groupRef, {
        'activeRequesterCount':
            FieldValue.increment(1),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      tx.update(joinRequestRef, {
        'status': 'approved',
        'approvedAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    });
  }
}