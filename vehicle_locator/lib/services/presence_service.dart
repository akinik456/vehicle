import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_database/firebase_database.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';

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
	static String? _serviceGroupId;
	static String? _serviceLocatorId;
	static double? _lastLat;
	static double? _lastLng;
	static int? _lastBatteryLevel;
	static bool? _lastGpsEnabled;
	
	static double? lastSpeedKmh;
	static DateTime? _lastAcceptedLocationTime;
	static String _currentAddress = '';

	static Future<void> updateOnline({
		String reason = 'unknown',
	}) async {
	
  final groupId = _serviceGroupId ?? await IdentityService.getGroupId();
  final locatorId = _serviceLocatorId ?? await IdentityService.getLocatorId();
		if (groupId == null || locatorId == null) {
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
			try {
				position = await Geolocator.getCurrentPosition(
					desiredAccuracy: LocationAccuracy.high,
				);
			} catch (e) {}
		} else {}
  
		// Hatalı GPS konumunu hareket/konum hesabında kullanma.
		// Ancak pil veya GPS durumu değiştiyse aşağıda yine yazılabilir.
		if (position != null && position.accuracy > 100) {
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
				if (confirmation == null) {} 
				else {
				final isNewFix = confirmation.timestamp.isAfter(firstPosition.timestamp);
					if (!isNewFix) {} 
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

						if (confirmationMatches) {
						position = confirmation;
						movedMeters = confirmationMovedMeters;
						speedKmh = confirmationSpeedKmh;
						finalAnalysis = secondAnalysis;
						confirmationAccepted = true;
						} 
						else {}
					}
				}
			}				
			if (analysis.decision == GpsDecision.suspicious && !confirmationAccepted && finalAnalysis.decision != GpsDecision.safe)
			{
			return;
			}
		SmartPresenceScheduler.setSpeedKmh(speedKmh,);
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
		await _db.child(path).update({
			'status': 'online',
			'lastSeen': ServerValue.timestamp,
			'battery': batteryLevel,
			'gpsEnabled': gpsEnabled,
			'updateCount': ServerValue.increment(1),
		});
		
		await PresenceCacheService.save({
			'status': 'online',
			'battery': batteryLevel,
			'gpsEnabled': gpsEnabled,
			'speed': speedKmh,
		});				
		_lastBatteryLevel = batteryLevel;
		_lastGpsEnabled = gpsEnabled;
		
		return;
		}

		// Geçerli konum yoksa yalnızca değişen cihaz durumu yazılabilir.
		if (position == null) 
		{
			if (!deviceStatusChanged) 
			{
			return;
			}

    await _db.child(path).update({
      'status': 'online',
      'lastSeen': ServerValue.timestamp,
      'battery': batteryLevel,
      'gpsEnabled': gpsEnabled,
			'speed': speedKmh,
      'updateCount': ServerValue.increment(1),
    });
		
		await PresenceCacheService.save({
			'status': 'online',
			'battery': batteryLevel,
			'gpsEnabled': gpsEnabled,
			'speed': speedKmh,
		});
		
    _lastBatteryLevel = batteryLevel;
    _lastGpsEnabled = gpsEnabled;

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
				'updateCount': ServerValue.increment(1),
			});
			
			await PresenceCacheService.save({
				'status': 'online',
				'battery': batteryLevel,
				'gpsEnabled': gpsEnabled,
				'speed': speedKmh,
			});
			_lastBatteryLevel = batteryLevel;
			_lastGpsEnabled = gpsEnabled;
			}
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
		'updateCount': ServerValue.increment(1),
		...placeData,
	};		
	
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
	};

		if (movedMeters == null ||
				movedMeters >= 25) {
			updateData['stationarySince'] =
					ServerValue.timestamp;
		}
		try {
		await _db.child(path).update(updateData,);
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
//Log.d("BEACON_PRESENCE => startConnectionWatcher called");
  final groupId = await IdentityService.getGroupId();
  final locatorId = await IdentityService.getLocatorId();
	
	//Log.d("BEACON_PRESENCE => watcher ids group=$groupId locator=$locatorId",);

  if (groupId == null || locatorId == null) {
    //Log.d("BEACON_PRESENCE => watcher missing group/locator");
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
	//Log.d("BEACON_PRESENCE => connected=$connected");

    if (!connected) return;

    await locatorRef.onDisconnect().update({
			'status': 'offline',
			'lastSeen': ServerValue.timestamp,
			'offlineSince': ServerValue.timestamp,
		});
		
    await locatorRef.update({
      'status': 'online',
      'lastSeen': ServerValue.timestamp,
			'offlineSince': null,
    });

    //Log.d("BEACON_PRESENCE => onDisconnect armed");
  });
}
}
