import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/history_point.dart';

class HistoryService {
  static final FirebaseDatabase _db =
      FirebaseDatabase.instance;

  static Future<List<HistoryPoint>> getPointsBetween({
    required String groupId,
    required String locatorId,
    required DateTime start,
    required DateTime end,
  }) async {
    final ref = _db.ref(
      'history/groups/$groupId/$locatorId/lastday',
    );

    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final raw = snapshot.value;

    if (raw is! Map) {
      return [];
    }

    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;

    final points = <HistoryPoint>[];
		
    for (final entry in raw.entries) {
      final timestamp = int.tryParse(
        entry.key.toString(),
      );

      if (timestamp == null) continue;

      if (timestamp < startMillis ||
          timestamp > endMillis) {
        continue;
      }

      final value = entry.value;

      if (value is! Map) continue;

      final lat = (value['lat'] as num?)?.toDouble();
      final lng = (value['lng'] as num?)?.toDouble();

      if (lat == null || lng == null) continue;

      points.add(
				HistoryPoint(
					timestamp: timestamp,
					position: LatLng(lat, lng),
				),
			);
    }

    // Timestamp sırasını garanti edelim.
				points.sort(
			(a, b) => a.timestamp.compareTo(b.timestamp),
		);

		return points;
}
}