import 'dart:isolate';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_database/firebase_database.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'identity_service.dart';
import 'geofence_service.dart';
import 'locator_settings_service.dart';
import 'movement_alert_service.dart';
import '../utils/log.dart';
import 'smart_presence_scheduler.dart';
import 'presence_cache_service.dart';
import 'motion_service.dart';
import 'gps_analysis_service.dart';
import '../utils/address_helper.dart';
import 'app_log_service.dart';


class PresenceService {
  PresenceService._();

  static final _db = FirebaseDatabase.instance.ref();
	static StreamSubscription<DatabaseEvent>? _connectedSub;
	static StreamSubscription<DatabaseEvent>? _presenceSub;
	static String? _serviceGroupId;
	static String? _serviceLocatorId;
	static double? _lastLat;
	static double? _lastLng;
	static int? _lastBatteryLevel;
	static bool? _lastGpsEnabled;
	
	static double? lastSpeedKmh;
	static DateTime? _lastAcceptedLocationTime;
	static String _currentAddress = '';

	static int? _totalDistanceMeters;
	static int? _tripDistanceMeters;
	static const double _distanceCorrection = 1.0;
	static bool _distanceInitialized = false;
	
	static StreamSubscription<Position>? _odometerSub;

	static Position? _lastOdometerPosition;
	
	static Future<void> updateOnline({
		String reason = 'unknown',
	}) async {
	
Log.d("BEACON_PRESENCE => STARTED");	
await AppLogService.log(
type: AppLogType.presence,
text: "updateOnline started reason=$reason",
);

if (_totalDistanceMeters == null ||
    _tripDistanceMeters == null) {
  await loadDistanceCache();
}

if (_totalDistanceMeters == null ||
    _tripDistanceMeters == null) {
  return;
}
	
  final groupId = _serviceGroupId ?? await IdentityService.getGroupId();
  final locatorId = _serviceLocatorId ?? await IdentityService.getLocatorId();
		if (groupId == null || locatorId == null) {
				await AppLogService.log(
				type: AppLogType.warning,
				text:
						"updateOnline stopped: missinglocator "
						"locatorId=$locatorId",
			);
			return;
		}

  final path = "presence/groups/$groupId/locators/$locatorId";
  final batteryLevel = await Battery().batteryLevel;
  final gpsEnabled = await Geolocator.isLocationServiceEnabled();			
	final batteryChanged = _lastBatteryLevel == null || (batteryLevel - _lastBatteryLevel!).abs() >= 5;
  final deviceStatusChanged = batteryChanged || _lastGpsEnabled != gpsEnabled;

  Position? position;
  double speedKmh = 0;
  double? movedMeters;
	double? elapsedSeconds;
	

		if (gpsEnabled) {
await AppLogService.log(
type: AppLogType.gps,
text: "Requesting current position",
);		
			try {
				position = await Geolocator.getCurrentPosition(
					desiredAccuracy: LocationAccuracy.high,
				);
await AppLogService.log(
type: AppLogType.gps,
text:
		"RAW "
		"lat=${position.latitude} "
		"lng=${position.longitude} "
		"acc=${position.accuracy} "
		"speed=${position.speed} "
		"heading=${position.heading} "
		"alt=${position.altitude}",
);
			} catch (e) {
await AppLogService.log(
  type: AppLogType.error,
  text: "getCurrentPosition failed: $e ",
);
			}
		} else {}
		// Hatalı GPS konumunu hareket/konum hesabında kullanma.
		// Ancak pil veya GPS durumu değiştiyse aşağıda yine yazılabilir.
		if (position != null && position.accuracy > 100) {
			Log.d(
				"BEACON_PRESENCE => "
				"ignore inaccurate position "
				"accuracy=${position.accuracy.toStringAsFixed(1)}m",
			);
			 await AppLogService.log(
				type: AppLogType.gps,
				text: 
					"ignore inaccurate position "
					"accuracy=${position.accuracy.toStringAsFixed(1)}m",
			);	
			position = null;
		}//?*?

		if (position != null) { 
			final speedMps = position.speed;
			speedKmh = speedMps >= 0
					? speedMps * 3.6
					: 0;
			if (speedKmh < 3) { 
				speedKmh = 0;
			}//?*?
		}
		if (speedKmh >= 6) {
			await setOdometerTracking(true);
		} else if (speedKmh <= 3) {
			await setOdometerTracking(false);
		}
		if (position != null && _lastLat != null && _lastLng != null) 
		{
		movedMeters = Geolocator.distanceBetween(_lastLat!,_lastLng!,position.latitude,position.longitude,);		

			if (_lastAcceptedLocationTime != null) {
				elapsedSeconds = DateTime.now().difference(_lastAcceptedLocationTime!).inMilliseconds /1000.0;
			}	

		final motionRecent = MotionService.wasRecentlyMoving();

		final analysis = GpsAnalysisService.analyze(
			input: GpsAnalysisInput(
				accuracy: position.accuracy,
				movedMeters: movedMeters,
				elapsedSeconds: elapsedSeconds,
				reportedSpeedKmh: speedKmh,
				lastSpeedKmh: lastSpeedKmh,
				motionRecent: motionRecent,
			),
		);
			
		var finalAnalysis = analysis;
		var confirmationAccepted = false;
			
			if (analysis.decision == GpsDecision.verify || analysis.decision == GpsDecision.suspicious) 
			{
			final firstPosition = position;
			final firstMovedMeters = movedMeters;
				
			final confirmation = await _getConfirmationPosition(firstTimestamp: firstPosition.timestamp,);
				if (confirmation == null) {
					await AppLogService.log(
						type: AppLogType.gps,
						text: "BEACON_GPS_VERIFY => confirmation unavailable",
					);	
				} 
				else {
				final isNewFix = confirmation.timestamp.isAfter(firstPosition.timestamp);
					if (!isNewFix) {
					await AppLogService.log(
							type: AppLogType.gps,
							text: "BEACON_GPS_VERIFY => "
							"cached confirmation ignored "
							"firstTime=${firstPosition.timestamp}"
							"secondTime=${confirmation.timestamp}",	
						);	
					} 
					else {
					final double? secondElapsedSeconds = 
												_lastAcceptedLocationTime != null 
												? DateTime.now().difference(_lastAcceptedLocationTime!).inMilliseconds /1000.0: null;
					final double? confirmationMovedMeters =_lastLat != null && _lastLng != null
												? Geolocator.distanceBetween(_lastLat!,_lastLng!,confirmation.latitude,confirmation.longitude,)
												: null;
					final rawConfirmationSpeedKmh = confirmation.speed >= 0
												? confirmation.speed * 3.6
												: 0.0;
					final confirmationSpeedKmh = rawConfirmationSpeedKmh < 3
												? 0.0
												: rawConfirmationSpeedKmh;

					final secondAnalysis =
						GpsAnalysisService.analyze(
							input: GpsAnalysisInput(
								accuracy: confirmation.accuracy,
								movedMeters: confirmationMovedMeters,
								elapsedSeconds: secondElapsedSeconds,
								reportedSpeedKmh: confirmationSpeedKmh,
								lastSpeedKmh: lastSpeedKmh,
								motionRecent: motionRecent,
							),
						);

					final firstToSecondDistance =
						Geolocator.distanceBetween(
							firstPosition.latitude,
							firstPosition.longitude,
							confirmation.latitude,
							confirmation.longitude,
						);
/*Log.d(
								"BEACON_GPS_VERIFY => "
								"firstTime=${firstPosition.timestamp} "
								"secondTime=${confirmation.timestamp} "
								"firstToSecond=${firstToSecondDistance.toStringAsFixed(1)}m",
							);*/
await AppLogService.log(
  type: AppLogType.gps,
  text: "BEACON_GPS_VERIFY => "
  "firstTime=${firstPosition.timestamp} "
	"secondTime=${confirmation.timestamp} "
	"firstToSecond=${firstToSecondDistance.toStringAsFixed(1)}m",
);	

							/*Log.d(
								"BEACON_GPS_VERIFY => "
								"first=${analysis.decision.name}:${analysis.score} "
								"second=${secondAnalysis.decision.name}:${secondAnalysis.score}",
							);*/
await AppLogService.log(
  type: AppLogType.gps,
  text: "BEACON_GPS_VERIFY => "
	"first=${analysis.decision.name}:${analysis.score} "
	"second=${secondAnalysis.decision.name}:${secondAnalysis.score}",
);	
							/*Log.d(
								"BEACON_GPS_VERIFY => "
								"firstMoved=${firstMovedMeters?.toStringAsFixed(1)}m "
								"secondMoved=${confirmationMovedMeters?.toStringAsFixed(1)}m",
							);*/
await AppLogService.log(
  type: AppLogType.gps,
  text: "BEACON_GPS_VERIFY => "
	"firstMoved=${firstMovedMeters?.toStringAsFixed(1)}m "
	"secondMoved=${confirmationMovedMeters?.toStringAsFixed(1)}m",
);	

					/*final confirmationDistanceLimit = math.max(
						50.0,
						firstPosition.accuracy + confirmation.accuracy,
					);*/

					final firstTime = firstPosition.timestamp;
					final confirmationTime = confirmation.timestamp;

					final confirmationElapsedSeconds = math.max(0.0,confirmationTime.difference(firstTime).inMilliseconds / 1000.0,);
					final firstSpeedMps = math.max(0.0,firstPosition.speed,);
					final confirmationSpeedMps = math.max(0.0,confirmation.speed,);
					final movementSpeedMps = math.max(firstSpeedMps,confirmationSpeedMps,);

					// İki GPS ölçümü alınırken cihazın gerçekten ilerleyebileceği mesafe.
					final expectedTravelMeters = movementSpeedMps * confirmationElapsedSeconds;

					// GPS accuracy payı + gerçek hareket payı.
					// 1.5 katsayısı hız/süre ölçümündeki küçük sapmalara tolerans verir.
					final confirmationDistanceLimit = math.max(100.0,
																						firstPosition.accuracy + confirmation.accuracy +(expectedTravelMeters * 1.5),);

					final confirmationMatches = firstToSecondDistance <= confirmationDistanceLimit;
await AppLogService.log(
  type: AppLogType.gps,
  text:
      "BEACON_GPS_VERIFY => "
      "elapsed=${confirmationElapsedSeconds.toStringAsFixed(1)}s "
      "speed=${(movementSpeedMps * 3.6).toStringAsFixed(1)}kmh "
      "expectedTravel=${expectedTravelMeters.toStringAsFixed(1)}m "
      "distance=${firstToSecondDistance.toStringAsFixed(1)}m "
      "limit=${confirmationDistanceLimit.toStringAsFixed(1)}m",
);

						if (confirmationMatches) {
						position = confirmation;
						movedMeters = confirmationMovedMeters;
						speedKmh = confirmationSpeedKmh;
						finalAnalysis = secondAnalysis;
						confirmationAccepted = true;
await AppLogService.log(
	type: AppLogType.gps,
	text:
			"BEACON_GPS_VERIFY => confirmed "
			"distance=${firstToSecondDistance.toStringAsFixed(1)}m "
			"limit=${confirmationDistanceLimit.toStringAsFixed(1)}m",
);
						} 
						else {
await AppLogService.log(
			type: AppLogType.gps,
			text:
					"BEACON_GPS_VERIFY => confirmation mismatch "
					"distance=${firstToSecondDistance.toStringAsFixed(1)}m "
					"limit=${confirmationDistanceLimit.toStringAsFixed(1)}m",
		);
						}
					}
				}
			}				
			if (analysis.decision == GpsDecision.suspicious && !confirmationAccepted && finalAnalysis.decision != GpsDecision.safe)
			{
try {
await AppLogService.log(
  type: AppLogType.gps,
  text: "BEACON_GPS_REJECTED => "
	"diagnostic saved "
	"score=${analysis.score} "
	"moved=${movedMeters?.toStringAsFixed(1)}m",
);	
	
} catch (e) {
  Log.e(
    "BEACON_GPS_REJECTED => "
    "diagnostic save failed => $e",
  );
}

/*Log.d(
  "BEACON_GPS => suspicious fix rejected "
  "score=${analysis.score} "
  "reason=$reason",
);*/
await AppLogService.log(
  type: AppLogType.gps,
  text: "BEACON_GPS_REJECTED => suspicious fix rejected  "
	"score=${analysis.score} "
	"reason=$reason",
);	

			return;
			}
		SmartPresenceScheduler.setSpeedKmh(speedKmh,);
		
/*Log.d(
  "BEACON_GPS => "
  "reason=$reason "
  "accuracy=${position.accuracy.toStringAsFixed(1)}m "
  "moved=${movedMeters?.toStringAsFixed(1)}m "
  "elapsed=${elapsedSeconds?.toStringAsFixed(1)}s "
  "motionRecent=$motionRecent",
);*/

/*Log.d(
  "BEACON_GPS => "
  "lastSpeed=${lastSpeedKmh?.toStringAsFixed(1)}kmh "
  "reportedSpeed=${speedKmh.toStringAsFixed(1)}kmh "
  "calculatedSpeed=${finalAnalysis.calculatedSpeedKmh?.toStringAsFixed(1)}kmh "
  "speedDifference=${finalAnalysis.speedDifferenceKmh?.toStringAsFixed(1)}kmh "
  "speedJump=${finalAnalysis.speedJumpKmh?.toStringAsFixed(1)}kmh",
);*/
/*Log.d(
  "BEACON_GPS_SCORE => "
  "score=${finalAnalysis.score} "
  "decision=${finalAnalysis.decision.name} "
  "reasons=${finalAnalysis.reasons.isEmpty ? 'none' : finalAnalysis.reasons.join(',')}",
);*/  
		
		/*Log.d(
      "BEACON_PRESENCE => "
      "reason=$reason "
      "moved=${movedMeters != null ? movedMeters.toStringAsFixed(1) : '-'}m",
    );*/
		
await AppLogService.log(
  type: AppLogType.gps,
  text: "BEACON_GPS =>"
  "reason=$reason "
  "accuracy=${position.accuracy.toStringAsFixed(1)}m "
  "moved=${movedMeters?.toStringAsFixed(1)}m "
  "elapsed=${elapsedSeconds?.toStringAsFixed(1)}s "
  "motionRecent=$motionRecent"
  "lastSpeed=${lastSpeedKmh?.toStringAsFixed(1)}kmh "
  "reportedSpeed=${speedKmh.toStringAsFixed(1)}kmh "
  "calculatedSpeed=${finalAnalysis.calculatedSpeedKmh?.toStringAsFixed(1)}kmh "
  "speedDifference=${finalAnalysis.speedDifferenceKmh?.toStringAsFixed(1)}kmh "
  "speedJump=${finalAnalysis.speedJumpKmh?.toStringAsFixed(1)}kmh"
  "score=${finalAnalysis.score} "
  "decision=${finalAnalysis.decision.name} "
  "reasons=${finalAnalysis.reasons.isEmpty ? 'none' : finalAnalysis.reasons.join(',')}"
  "BEACON_PRESENCE => "
  "reason=$reason "
  "moved=${movedMeters != null ? movedMeters.toStringAsFixed(1) : '-'}m",
	
);	

		}

  final shouldSkipSmallMove = (reason == 'timer' || reason == 'motion') && movedMeters != null && movedMeters < 25;

	// Hareket yok, pil/GPS de değişmedi:
  // ne alert kontrolüne ne de RTDB write'a gerek var.

		if (shouldSkipSmallMove && !deviceStatusChanged) 
		{
			return;
		}//?*?

		// Hareket yok ama pil veya GPS durumu değişti:
		// yalnızca status alanlarını güncelle.
		if (shouldSkipSmallMove && deviceStatusChanged) 
		{
await AppLogService.log(
	type: AppLogType.rtdb,
	text:
			"RTDB status-only write started "
			"reason=$reason path=$path "
			"battery=$batteryLevel gpsEnabled=$gpsEnabled",
);
		await _db.child(path).update({
			'status': 'online',
			'lastSeen': ServerValue.timestamp,
			'battery': batteryLevel,
			'gpsEnabled': gpsEnabled,
			'updateCount': ServerValue.increment(1),
			'deviceChangedCounter': ServerValue.increment(1),
		});
		
		await PresenceCacheService.save({
			'status': 'online',
			'battery': batteryLevel,
			'gpsEnabled': gpsEnabled,
			'speed': speedKmh,
		});				
		_lastBatteryLevel = batteryLevel;
		_lastGpsEnabled = gpsEnabled;
		
await AppLogService.log(
	type: AppLogType.rtdb,
	text:
			"RTDB status-only write success "
			"reason=$reason path=$path",
);
		
		return;
		}

		// Geçerli konum yoksa yalnızca değişen cihaz durumu yazılabilir.
		if (position == null) 
		{
			if (!deviceStatusChanged) 
			{
await AppLogService.log(
	type: AppLogType.presence,
	text:
			"Presence stopped: no valid position "
			"and no device status change reason=$reason",
);
			return;
			}
await AppLogService.log(
	type: AppLogType.rtdb,
	text:
			"RTDB status-only write started: no valid position "
			"reason=$reason path=$path "
			"battery=$batteryLevel gpsEnabled=$gpsEnabled",
);
    await _db.child(path).update({
      'status': 'online',
      'lastSeen': ServerValue.timestamp,
      'battery': batteryLevel,
      'gpsEnabled': gpsEnabled,
			'speed': speedKmh,
      'updateCount': ServerValue.increment(1),
			'deviceChangedwithNoPos': ServerValue.increment(1),
    });
		
		await PresenceCacheService.save({
			'status': 'online',
			'battery': batteryLevel,
			'gpsEnabled': gpsEnabled,
			'speed': speedKmh,
		});
		
    _lastBatteryLevel = batteryLevel;
    _lastGpsEnabled = gpsEnabled;

await AppLogService.log(
	type: AppLogType.rtdb,
	text:
			"RTDB status-only write success: no valid position "
			"reason=$reason path=$path",
);
    return;
		}

  // Buraya geldiysek geçerli ve anlamlı bir konum hareketi var.
  final placeData =
      await GeofenceService.checkPlaces(
    groupId: groupId,
    locatorId: locatorId,
    lat: position.latitude,
    lng: position.longitude,
  );

  await MovementAlertService.checkNow(position: position,reason: reason,);

		// Motion alert ve geofence kontrolleri çalıştı.
		// Aktif izleyen yoksa sırf motion nedeniyle presence konumu yazma.
		
		Log.d("movedMeters:$movedMeters");
		
		
		if (!_distanceInitialized) {
			Log.d(
  "ODO NOT INIT => "
  "iso=${Isolate.current.hashCode} "
  "pid=$pid "
  "total=$_totalDistanceMeters "
  "trip=$_tripDistanceMeters",
);
		} else if (
				movedMeters != null &&
				movedMeters >= 25 &&
				movedMeters <= 1000
		){
			/*final delta =
					(movedMeters * _distanceCorrection).round();
			_totalDistanceMeters = _totalDistanceMeters! + delta;
			_tripDistanceMeters = _tripDistanceMeters! + delta;*/

			Log.d(
				"ODO => total=$_totalDistanceMeters "
				"trip=$_tripDistanceMeters",
			);
		}		
		
		if (reason == 'motion' && !SmartPresenceScheduler.hasActiveWatcher) 
		{
			if (deviceStatusChanged) 
			{
			await _db.child(path).update({
				'status': 'online',
				'lastSeen': ServerValue.timestamp,
				'battery': batteryLevel,
				'gpsEnabled': gpsEnabled,
				'speed': speedKmh,
				'totalDistanceMeters': _totalDistanceMeters,
				'tripDistanceMeters': _tripDistanceMeters,
				'updateCount': ServerValue.increment(1),
				'deviceChangedwithmotion': ServerValue.increment(1),
			});
		Log.d("km_update1 totalDistanceMeters:$_totalDistanceMeters");
			
			await PresenceCacheService.save({
				'status': 'online',
				'battery': batteryLevel,
				'gpsEnabled': gpsEnabled,
				'speed': speedKmh,
				'totalDistanceMeters': _totalDistanceMeters,
				'tripDistanceMeters': _tripDistanceMeters,
			});
				Log.d("km_update5 totalDistanceMeters:$_totalDistanceMeters");

			_lastBatteryLevel = batteryLevel;
			_lastGpsEnabled = gpsEnabled;
			}
await AppLogService.log(
	type: AppLogType.presence,
	text:
			"Presence location write skipped: "
			"motion without active watcher "
			"deviceStatusChanged=$deviceStatusChanged",
);
		return;
		}	
	_currentAddress = await AddressHelper.getAddressFromLatLng(lat: position.latitude,lng: position.longitude,);
	final Map<String, dynamic> updateData = 
	{
		'status': 'online',
		'lastSeen': ServerValue.timestamp,
		'battery': batteryLevel,
		'gpsEnabled': gpsEnabled,
		'speed': speedKmh,
		'lat': position.latitude,
		'lng': position.longitude,
		'address': _currentAddress,
		'accuracy': position.accuracy,
		'movedSinceLastUpdateMeters':
				movedMeters?.round(),
		'totalDistanceMeters': _totalDistanceMeters,
		'tripDistanceMeters': _tripDistanceMeters,
		'updateCount': ServerValue.increment(1),
		...placeData,
		'posupdateCounter': ServerValue.increment(1),
	};		
		Log.d("km_update4 totalDistanceMeters:$_totalDistanceMeters");
	
	final Map<String, dynamic> cacheData = 
	{
		'status': 'online',
		'battery': batteryLevel,
		'gpsEnabled': gpsEnabled,
		'speed': speedKmh,
		'lat': position.latitude,
		'lng': position.longitude,
		'address': _currentAddress,
		...placeData,
		'stationarySince': updateData['stationarySince'],
		'offlineSince': null,
		'totalDistanceMeters': _totalDistanceMeters,
		'tripDistanceMeters': _tripDistanceMeters,
	};
		Log.d("km_update3 totalDistanceMeters:$_totalDistanceMeters");


		if (movedMeters == null ||
				movedMeters >= 25) {
			updateData['stationarySince'] =
					ServerValue.timestamp;
		}
await AppLogService.log(
	type: AppLogType.rtdb,
	text:
			"RTDB presence write started "
			"reason=$reason path=$path "
			"lat=${position.latitude} "
			"lng=${position.longitude} "
			"accuracy=${position.accuracy.toStringAsFixed(1)}m "
			"moved=${movedMeters?.toStringAsFixed(1)}m",
);
		
final now = DateTime.now();

final currentDay =
    '${now.year}-${now.month}-${now.day}';

final prefs = await SharedPreferences.getInstance();

final historyDayKey =
    'history_day_$locatorId';

final savedDay =
    prefs.getString(historyDayKey);

if (savedDay != currentDay) {
  await _db
      .child(
        'history/groups/$groupId/$locatorId/lastday',
      )
      .remove();

  await prefs.setString(
    historyDayKey,
    currentDay,
  );

  Log.d(
    'HISTORY NEW DAY => '
    'old=$savedDay new=$currentDay '
    'lastday cleared',
  );
}
final historyTimestamp =
DateTime.now().millisecondsSinceEpoch;
final historyPath =
    'history/groups/$groupId/$locatorId/lastday/$historyTimestamp';

final Map<String, dynamic> rootUpdateData = {
  // Mevcut presence update
  for (final entry in updateData.entries)
    '$path/${entry.key}': entry.value,

  // History
  '$historyPath/lat': position.latitude,
  '$historyPath/lng': position.longitude,
};

try {
  await _db.update(rootUpdateData);

  await PresenceCacheService.save(cacheData);
} catch (e) {
  rethrow;
}
		
  _lastBatteryLevel = batteryLevel;
  _lastGpsEnabled = gpsEnabled;
  _lastLat = position.latitude;
  _lastLng = position.longitude;
	lastSpeedKmh = speedKmh;
	_lastAcceptedLocationTime = position.timestamp;
}

static Future<Position?> _getConfirmationPosition({
  required DateTime firstTimestamp,
}) async {
  try {
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    );

    return await stream
    .firstWhere((newPosition) {
      final isFresh =
          newPosition.timestamp.isAfter(firstTimestamp);

      /*Log.d(
        "BEACON_GPS_STREAM => "
        "first=$firstTimestamp "
        "candidate=${newPosition.timestamp} "
        "isFresh=$isFresh",
      );*/

      return isFresh;
    })
    .timeout(
      const Duration(seconds: 20),
    );
  } on TimeoutException {
    /*Log.d(
      "BEACON_GPS_VERIFY => "
      "fresh confirmation timeout",
    );*/

    return null;
  } catch (e) {
    Log.e(
      "BEACON_GPS_VERIFY => "
      "confirmation stream failed => $e",
    );

    return null;
  }
}

static void setServiceIds({
  required String groupId,
  required String locatorId,
}) {
  _serviceGroupId = groupId;
  _serviceLocatorId = locatorId;

  /*Log.d(
    "BEACON_PRESENCE => service ids set "
    "group=$groupId locator=$locatorId",
  );*/
}
static Future<void> startConnectionWatcher() async {
  final groupId = await IdentityService.getGroupId();
  final locatorId = await IdentityService.getLocatorId();

  if (groupId == null || locatorId == null) {
    return;
  }

  final locatorRef = _db.child(
    "presence/groups/$groupId/locators/$locatorId",
  );
	
	final connectedRef =
      FirebaseDatabase.instance.ref(".info/connected");

  await _connectedSub?.cancel();

  _connectedSub = connectedRef.onValue.listen((event) async {
    final connected =
        event.snapshot.value as bool? ?? false;
	Log.d(
    "RTDB CONNECTION => "
    "connected=$connected "
    "time=${DateTime.now()}",
  );
await AppLogService.log(
	type: AppLogType.rtdb,
	text:
			"RTDB CONNECTION => "
			"connected=$connected "
			"time=${DateTime.now()}",
);	

    if (!connected) return;

    await locatorRef.onDisconnect().update({
			'status': 'offline',
			'lastSeen': ServerValue.timestamp,
			'offlineSince': ServerValue.timestamp,
			'offlineCounter': ServerValue.increment(1),
			'updateCount': ServerValue.increment(1),
		});
		//Log.d("BEACON_PRESENCE => onDisconnect armed");
  });

  // İlk açılışta serverdaki km değerlerini kesin al
  try {
    final snapshot = await locatorRef.get();
    final data = snapshot.value;
		
		Log.d(
  "ODO GET => value=${snapshot.value} "
  "type=${snapshot.value.runtimeType}",
);

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final totalDistanceMeters =
          (map['totalDistanceMeters'] as num?)?.toInt();

      final tripDistanceMeters =
          (map['tripDistanceMeters'] as num?)?.toInt();

      if (totalDistanceMeters != null) {
        _totalDistanceMeters = totalDistanceMeters;
      }

      if (tripDistanceMeters != null) {
        _tripDistanceMeters = tripDistanceMeters;
      }

      await PresenceCacheService.save({
        'totalDistanceMeters': _totalDistanceMeters,
        'tripDistanceMeters': _tripDistanceMeters,
      });
				Log.d("km_update2 totalDistanceMeters:$_totalDistanceMeters");

    }

    _distanceInitialized = true;

    Log.d(
  "ODO INIT => "
  "iso=${Isolate.current.hashCode} "
  "pid=$pid "
  "total=$_totalDistanceMeters "
  "trip=$_tripDistanceMeters",
);
  } catch (e) {
    Log.e("ODO INIT ERROR => $e");

    // Server okunamadıysa cache ile devam et
    _distanceInitialized = true;
  }

  await _presenceSub?.cancel();

  _presenceSub = locatorRef.onValue.listen((event) async {
    final data = event.snapshot.value;

    if (data is! Map) return;

    final map = Map<String, dynamic>.from(data);

    final totalDistanceMeters =
        (map['totalDistanceMeters'] as num?)?.toInt();

    final tripDistanceMeters =
        (map['tripDistanceMeters'] as num?)?.toInt();

    if (totalDistanceMeters != null) {
      _totalDistanceMeters = totalDistanceMeters;
    }

    if (tripDistanceMeters != null) {
      _tripDistanceMeters = tripDistanceMeters;
    }

    Log.d(
  "ODO LISTENER => "
  "iso=${Isolate.current.hashCode} "
  "pid=$pid "
  "total=$_totalDistanceMeters "
  "trip=$_tripDistanceMeters",
);

    await PresenceCacheService.save({
      if (totalDistanceMeters != null)
        'totalDistanceMeters': totalDistanceMeters,
      if (tripDistanceMeters != null)
        'tripDistanceMeters': tripDistanceMeters,
    });
  });

}

static void resetTripDistance() {
  _tripDistanceMeters = 0;
}

static Future<void> loadDistanceCache() async {
  final cache = await PresenceCacheService.load();

  _totalDistanceMeters =
      (cache['totalDistanceMeters'] as num?)?.toInt();

  _tripDistanceMeters =
      (cache['tripDistanceMeters'] as num?)?.toInt();
}

static double _distanceCorrectionForSpeed(
  double speedKmh,
) {
  if (speedKmh >= 70) return 1.00;
  if (speedKmh >= 40) return 1.05;
  if (speedKmh >= 20) return 1.10;

  return 1.10;
}

	static Future<void> setOdometerTracking(
		bool active,
	) async {
		if (active) {
			if (_odometerSub != null) return;

			_lastOdometerPosition = null;

			final settings = AndroidSettings(
				accuracy: LocationAccuracy.high,
				distanceFilter: 10,
				intervalDuration: const Duration(
					seconds: 5,
				),
			);

			_odometerSub = Geolocator.getPositionStream(
				locationSettings: settings,
			).listen((position) {
				// Kötü GPS noktasını kullanma
				if (position.accuracy > 100) return;

				final previous =
						_lastOdometerPosition;

				_lastOdometerPosition = position;

				// İlk nokta sadece referans
				if (previous == null) return;

				final movedMeters =
						Geolocator.distanceBetween(
					previous.latitude,
					previous.longitude,
					position.latitude,
					position.longitude,
				);

				// Ufak GPS jitter
				if (movedMeters < 5) return;

				final speedKmh =
						position.speed >= 0
								? position.speed * 3.6
								: 0.0;

				final correction =
						_distanceCorrectionForSpeed(
					speedKmh,
				);

				final delta =
						(movedMeters * correction).round();

				if (_totalDistanceMeters == null ||
						_tripDistanceMeters == null) {
					return;
				}

				_totalDistanceMeters =
						_totalDistanceMeters! + delta;

				_tripDistanceMeters =
						_tripDistanceMeters! + delta;
			});

		} else {
			await _odometerSub?.cancel();

			_odometerSub = null;
			_lastOdometerPosition = null;
		}
	}

}
