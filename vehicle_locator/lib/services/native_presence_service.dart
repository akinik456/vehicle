import 'package:flutter/services.dart';
import '../utils/log.dart';

class NativePresenceService {
  NativePresenceService._();

  static const _channel =
      MethodChannel('lynra/presence_service');

  static Future<void> start({
		required String groupId,
		required String locatorId,
	}) async {
		try {
		Log.d(
  "NATIVE SERVICE => invokeMethod "
  "group=$groupId locator=$locatorId",
);
			await _channel.invokeMethod(
				'startPresenceService',
				{
					'groupId': groupId,
					'locatorId': locatorId,
				},
			);
Log.d("NATIVE SERVICE => invokeMethod done");
			Log.d(
				"NATIVE PRESENCE => service start requested "
				"group=$groupId locator=$locatorId",
			);
		} catch (e) {
			Log.e(
				"NATIVE PRESENCE => start failed => $e",
			);
		}
	}
	static Future<void> setAppForeground(
  bool value,
) async {
  await _channel.invokeMethod(
    'setAppForeground',
    {
      'value': value,
    },
  );
}
	static Future<Map<String, String>?> getPresenceIds() async {
		try {
			final result = await _channel.invokeMethod<Map>(
				'getPresenceIds',
			);

			final groupId = result?['groupId'] as String?;
			final locatorId = result?['locatorId'] as String?;

			if (groupId == null || locatorId == null) {
				return null;
			}

			return {
				'groupId': groupId,
				'locatorId': locatorId,
			};
		} catch (e) {
			Log.e("NATIVE PRESENCE => get ids failed => $e");
			return null;
		}
	}
}