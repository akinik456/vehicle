import 'package:google_maps_flutter/google_maps_flutter.dart';

class HistoryPoint {
  final int timestamp;
  final LatLng position;

  const HistoryPoint({
    required this.timestamp,
    required this.position,
  });
}