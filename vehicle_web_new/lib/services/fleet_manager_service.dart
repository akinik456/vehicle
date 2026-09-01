import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FleetManagerService {
  static Future<String?> getCurrentGroupId() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('fleet_managers')
        .doc(user.uid)
        .collection('groups')//b6825e33-15cd-455c-aaaa-6b9da4ccedd7
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.id;
  }
	
	static Future<String?> getGroupName(String groupId) async {
		final doc = await FirebaseFirestore.instance
				.collection('groups')
				.doc(groupId)
				.get();

		if (!doc.exists) return null;

		return doc.data()?['groupName']?.toString();
	}

	static Future<void> updateGroupName({
			required String groupId,
			required String groupName,
		}) async {
			await FirebaseFirestore.instance
					.collection('groups')
					.doc(groupId)
					.update({
				'groupName': groupName.trim(),
				'updatedAt': FieldValue.serverTimestamp(),
			});
		}
		static Future<String?> getMasterRequesterName(
			String groupId,
		) async {
			final groupDoc = await FirebaseFirestore.instance
					.collection('groups')
					.doc(groupId)
					.get();

			final masterRequesterId =
					groupDoc.data()?['masterRequesterId']?.toString();

			if (masterRequesterId == null ||
					masterRequesterId.isEmpty) {
				return null;
			}

			final requesterDoc = await FirebaseFirestore.instance
					.collection('requesters')
					.doc(masterRequesterId)
					.get();

			if (!requesterDoc.exists) return null;

			return requesterDoc.data()?['requesterName']?.toString();
		}
		
		static Future<List<Map<String, String>>>
				getCurrentGroups() async {

			final user = FirebaseAuth.instance.currentUser;

			if (user == null) {
				return [];
			}

			final accessSnapshot =
					await FirebaseFirestore.instance
							.collection('fleet_managers')
							.doc(user.uid)
							.collection('groups')
							.get();

			final groups = <Map<String, String>>[];

			for (final accessDoc in accessSnapshot.docs) {
				final groupId = accessDoc.id;

				final groupDoc =
						await FirebaseFirestore.instance
								.collection('groups')
								.doc(groupId)
								.get();

				if (!groupDoc.exists) continue;

				groups.add({
					'groupId': groupId,
					'groupName':
							groupDoc.data()?['groupName']?.toString() ??
									'Fleet',
				});
			}

			return groups;
		}
		
		static Future<void> removeCurrentUserGroupAccess(
			String groupId,
		) async {
			final user = FirebaseAuth.instance.currentUser;

			if (user == null) return;

			await FirebaseFirestore.instance
					.collection('fleet_managers')
					.doc(user.uid)
					.collection('groups')
					.doc(groupId)
					.delete();
		}
}