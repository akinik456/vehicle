class LocatorPresence {
  final String locatorId;

  final double lat;
  final double lng;
	final String address;
  final int battery;

  final bool gpsEnabled;
  final bool geoInside;

  final String status;

  final double accuracy;

  final int movedMeters;

  final int updateCount;

  final int lastSeen;

  final int? stationarySince;
	
	final int? offlineSince;
	
	String locatorName;
	String locatorPlate;
	String vehicleType;
	
	final double speed;
	
	final int totalDistanceMeters;
	final int tripDistanceMeters;

  LocatorPresence({
    required this.locatorId,
    required this.lat,
    required this.lng,
		required this.address,
    required this.battery,
    required this.gpsEnabled,
    required this.geoInside,
    required this.status,
    required this.accuracy,
    required this.movedMeters,
    required this.updateCount,
    required this.lastSeen,
		required this.speed,
		required this.totalDistanceMeters,
		required this.tripDistanceMeters,
		required this.offlineSince,
    this.stationarySince,
		this.locatorName = '',
		this.locatorPlate = '',
		this.vehicleType = 'car',
  });

  factory LocatorPresence.fromMap(
    String locatorId,
    Map<dynamic, dynamic> map,
  ) {
    return LocatorPresence(
      locatorId: locatorId,

      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
			
			address: map['address'] ?? '',

      battery: map['battery'] ?? 0,

      gpsEnabled: map['gpsEnabled'] ?? false,
      geoInside: map['geoInside'] ?? false,

      status: map['status'] ?? 'offline',

      accuracy: (map['accuracy'] ?? 0).toDouble(),

      movedMeters: map['movedSinceLastUpdateMeters'] ?? 0,

      updateCount: map['updateCount'] ?? 0,

      lastSeen: map['lastSeen'] ?? 0,
			
			offlineSince: (map['offlineSince'] as num?)?.toInt(),

      stationarySince: map['stationarySince'],
			
			speed: (map['speed'] as num?)?.toDouble() ?? 0,

			totalDistanceMeters:
					(map['totalDistanceMeters'] as num?)?.toInt() ?? 0,

			tripDistanceMeters:
					(map['tripDistanceMeters'] as num?)?.toInt() ?? 0,
			
    );
  }
}