import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/locator_presence.dart';

class PresenceService {
  PresenceService._();

  static Stream<List<LocatorPresence>> watchLocators({
    required String groupId,
  }) {
    return FirebaseDatabase.instance
        .ref('presence/groups/$groupId/locators')
        .onValue
        .map((event) {
      final value = event.snapshot.value;

      if (value == null) return <LocatorPresence>[];

      final map = value as Map<dynamic, dynamic>;

      return map.entries.map((entry) {
        return LocatorPresence.fromMap(
          entry.key.toString(),
          entry.value as Map<dynamic, dynamic>,
        );
      }).toList();
    });
  }
	
	static Future<void> updateOdometer({
		required String groupId,
		required String locatorId,
		required int totalDistanceMeters,
	}) async {
		await FirebaseDatabase.instance
				.ref(
					'presence/groups/$groupId/locators/$locatorId/totalDistanceMeters',
				)
				.set(totalDistanceMeters);
	}
	
	static Future<void> resetTrip({
		required String groupId,
		required String locatorId,
	}) async {
		await FirebaseDatabase.instance
				.ref(
					'presence/groups/$groupId/locators/$locatorId/tripDistanceMeters',
				)
				.set(0);
	}
}