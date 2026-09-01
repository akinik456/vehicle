import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleInfoService {
  VehicleInfoService._();

  static Future<Map<String, Map<String, String>>> loadAllVehicleInfo({
		required String groupId,
	}) async {
		final devicesSnapshot = await FirebaseFirestore.instance
				.collection('groups')
				.doc(groupId)
				.collection('devices')
				.where('role', isEqualTo: 'locator')
				.where('active', isEqualTo: true)
				.get();

		final locatorIds = devicesSnapshot.docs
				.map((doc) => doc.id)
				.toList();

		if (locatorIds.isEmpty) {
			return {};
		}

		final result = <String, Map<String, String>>{};

		for (final locatorId in locatorIds) {
			final locatorDoc = await FirebaseFirestore.instance
					.collection('locators')
					.doc(locatorId)
					.get();

			final data = locatorDoc.data();

			if (data == null) {
				continue;
			}

			result[locatorId] = {
				'locatorName':
						(data['locatorName'] ?? data['name'] ?? '').toString(),
				'locatorPlate':
						(data['locatorPlate'] ?? '').toString(),
				'vehicleType':
						(data['vehicleType'] ?? 'car').toString(),
			};
		}

		return result;
	}
	
	static Future<void> updateVehicleType({
		required String locatorId,
		required String vehicleType,
	}) async {
		await FirebaseFirestore.instance
				.collection('locators')
				.doc(locatorId)
				.update({
			'vehicleType': vehicleType,
		});
	}	
	
}