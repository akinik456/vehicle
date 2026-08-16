import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VehicleHistoryPoint {
  final int timestamp;
  final LatLng position;

  const VehicleHistoryPoint({
    required this.timestamp,
    required this.position,
  });
}

class VehicleHistoryPage extends StatefulWidget {
  final String groupId;
  final String locatorId;

  const VehicleHistoryPage({
    super.key,
    required this.groupId,
    required this.locatorId,
  });

  @override
  State<VehicleHistoryPage> createState() =>
      _VehicleHistoryPageState();
}

class _VehicleHistoryPageState
    extends State<VehicleHistoryPage> {

  bool _loading = true;
  int _pointCount = 0;
	GoogleMapController? _mapController;
	List<VehicleHistoryPoint> _historyPoints = [];
	Timer? _playbackTimer;

	int _playbackIndex = 0;
	bool _isPlaying = false;
	double _playbackSpeed = 1.0;
	
	BitmapDescriptor? _historyStartIcon;
	BitmapDescriptor? _historyEndIcon;
	BitmapDescriptor? _playbackVehicleIcon;
	BitmapDescriptor? _historyPointIcon;

  @override
  void initState() {
    super.initState();
		_loadMapIcons();
    _loadHistory();
  }
	
	@override
	void dispose() {
		_playbackTimer?.cancel();
		_mapController?.dispose();
		super.dispose();
	}

  Future<void> _loadHistory() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref(
            'history/groups/${widget.groupId}/'
            '${widget.locatorId}/lastday',
          )
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _pointCount = 0;
        });

        return;
      }

      final raw = snapshot.value;

      if (raw is! Map) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _pointCount = 0;
        });

        return;
      }

      final entries = raw.entries.toList();

      entries.sort(
        (a, b) => int.parse(
          a.key.toString(),
        ).compareTo(
          int.parse(
            b.key.toString(),
          ),
        ),
      );
			
			final points = <VehicleHistoryPoint>[];

			for (final entry in entries) {
				final value = entry.value;

				if (value is! Map) continue;

				final lat = (value['lat'] as num?)?.toDouble();
				final lng = (value['lng'] as num?)?.toDouble();

				if (lat == null || lng == null) continue;

				final timestamp =
						int.tryParse(entry.key.toString());

				if (timestamp == null) continue;

				points.add(
					VehicleHistoryPoint(
						timestamp: timestamp,
						position: LatLng(lat, lng),
					),
				);
			}

      for (final entry in entries) {
        final timestamp = entry.key.toString();
        final value = entry.value;

        if (value is! Map) continue;

        final lat =
            (value['lat'] as num?)?.toDouble();

        final lng =
            (value['lng'] as num?)?.toDouble();

        debugPrint(
          'VEHICLE HISTORY => '
          'timestamp=$timestamp '
          'lat=$lat lng=$lng',
        );
      }

      if (!mounted) return;

      setState(() {
				_historyPoints = points;
				_pointCount = points.length;
				_loading = false;
			});
    } catch (e) {
      debugPrint(
        'VEHICLE HISTORY ERROR => $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }
	
	Future<void> _loadMapIcons() async {
		_historyStartIcon = await BitmapDescriptor.asset(
			const ImageConfiguration(size: Size(32, 32)),
			'assets/images/history_start.png',
		);

		_historyEndIcon = await BitmapDescriptor.asset(
			const ImageConfiguration(size: Size(32, 32)),
			'assets/images/history_end.png',
		);

		_playbackVehicleIcon = await BitmapDescriptor.asset(
			const ImageConfiguration(size: Size(40, 40)),
			'assets/images/playback_vehicle.png',
		);

		_historyPointIcon = await BitmapDescriptor.asset(
			const ImageConfiguration(size: Size(10, 10)),
			'assets/images/history_point.png',
		);

		if (mounted) {
			setState(() {});
		}
	}
	
	void _startPlayback() {
		if (_historyPoints.isEmpty) return;

		_playbackTimer?.cancel();

		setState(() {
			// Sondaysa tekrar başlat.
			if (_playbackIndex >= _historyPoints.length - 1) {
				_playbackIndex = 0;
			}

			_isPlaying = true;
		});

		_playbackTimer = Timer.periodic(
			Duration(
				milliseconds: (500 / _playbackSpeed).round(),
			),
			(_) {
				if (_playbackIndex >= _historyPoints.length - 1) {
					_pausePlayback();
					return;
				}

				setState(() {
					_playbackIndex++;
				});

				_centerPlaybackVehicle();
			},
		);
	}

	void _pausePlayback() {
		_playbackTimer?.cancel();

		if (!mounted) return;

		setState(() {
			_isPlaying = false;
		});
	}

	Future<void> _centerPlaybackVehicle() async {
		if (_mapController == null ||
				_historyPoints.isEmpty) {
			return;
		}

		await _mapController!.animateCamera(
			CameraUpdate.newLatLng(
				_historyPoints[_playbackIndex].position,
			),
		);
	}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today\'s Route',
        ),
      ),
      body: _loading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : _historyPoints.isEmpty
        ? const Center(
            child: Text('No route data'),
          )
        : Stack(
					children: [
						GoogleMap(
							onMapCreated: (controller) {
								_mapController = controller;
							},

							initialCameraPosition: CameraPosition(
								target: _historyPoints.first.position,
								zoom: 16,
							),

							polylines: {
								// Kalan rota
								if (_playbackIndex < _historyPoints.length - 1)
									Polyline(
										polylineId: const PolylineId(
											'historyRemaining',
										),
										points: _historyPoints
												.sublist(_playbackIndex)
												.map((point) => point.position)
												.toList(),
										width: 5,
										color: Colors.red,
									),

								// Geçilen rota
								if (_playbackIndex > 0)
									Polyline(
										polylineId: const PolylineId(
											'historyPassed',
										),
										points: _historyPoints
												.sublist(0, _playbackIndex + 1)
												.map((point) => point.position)
												.toList(),
										width: 5,
										color: Colors.grey,
									),
							},

							markers: {
								// ROTA NOKTALARI
								for (int i = 0; i < _historyPoints.length; i++)
									Marker(
										markerId: MarkerId('historyPoint_$i'),
										position: _historyPoints[i].position,
										icon: _historyPointIcon ??
												BitmapDescriptor.defaultMarker,
										zIndex: 1,
										infoWindow: InfoWindow(
											title: TimeOfDay.fromDateTime(
												DateTime.fromMillisecondsSinceEpoch(
													_historyPoints[i].timestamp,
												),
											).format(context),
										),
									),

								// START
								Marker(
									markerId: const MarkerId('start'),
									position: _historyPoints.first.position,
									icon: _historyStartIcon ??
											BitmapDescriptor.defaultMarker,
									zIndex: 10,
									infoWindow: const InfoWindow(
										title: 'Start',
									),
								),

								// END
								if (_historyPoints.length > 1)
									Marker(
										markerId: const MarkerId('end'),
										position: _historyPoints.last.position,
										icon: _historyEndIcon ??
												BitmapDescriptor.defaultMarker,
										zIndex: 10,
										infoWindow: const InfoWindow(
											title: 'End',
										),
									),

								// PLAYBACK VEHICLE
								Marker(
									markerId: MarkerId(
										'playbackVehicle_$_playbackIndex',
									),
									position:
											_historyPoints[_playbackIndex].position,
									icon: _playbackVehicleIcon ??
											BitmapDescriptor.defaultMarker,
									zIndex: 999,
									infoWindow: InfoWindow(
										title: TimeOfDay.fromDateTime(
											DateTime.fromMillisecondsSinceEpoch(
												_historyPoints[_playbackIndex]
														.timestamp,
											),
										).format(context),
									),
								),
							},

							myLocationButtonEnabled: false,
							mapToolbarEnabled: false,
						),
						Positioned(
							left: 12,
							right: 12,
							bottom: 18,
							child: Container(
								padding: const EdgeInsets.symmetric(
									horizontal: 10,
									vertical: 6,
								),
								decoration: BoxDecoration(
									color: const Color(0xFF111827),
									borderRadius: BorderRadius.circular(14),
									boxShadow: const [
										BoxShadow(
											blurRadius: 10,
											color: Colors.black26,
										),
									],
								),
								child: Row(
									children: [
										IconButton(
											onPressed: () {
												if (_isPlaying) {
													_pausePlayback();
												} else {
													_startPlayback();
												}
											},
											icon: Icon(
												_isPlaying
														? Icons.pause_rounded
														: Icons.play_arrow_rounded,
											),
										),

										Expanded(
											child: Slider(
												min: 0,
												max: (_historyPoints.length - 1)
														.toDouble(),
												value: _playbackIndex.toDouble(),
												onChanged: (value) {
													_pausePlayback();

													setState(() {
														_playbackIndex = value.round();
													});

													_centerPlaybackVehicle();
												},
											),
										),

										PopupMenuButton<double>(
											initialValue: _playbackSpeed,
											onSelected: (speed) {
												setState(() {
													_playbackSpeed = speed;
												});

												if (_isPlaying) {
													_startPlayback();
												}
											},
											itemBuilder: (_) => const [
												PopupMenuItem(
													value: 1.0,
													child: Text('1x'),
												),
												PopupMenuItem(
													value: 2.0,
													child: Text('2x'),
												),
												PopupMenuItem(
													value: 4.0,
													child: Text('4x'),
												),
											],
											child: Padding(
												padding: const EdgeInsets.all(8),
												child: Container(
													padding: const EdgeInsets.symmetric(
														horizontal: 8,
														vertical: 4,
													),
													decoration: BoxDecoration(
														color: Colors.black54,
														borderRadius: BorderRadius.circular(8),
													),
													child: Text(
														'${_playbackSpeed.toInt()}x',
														style: const TextStyle(
															color: Colors.white,
															fontWeight: FontWeight.w700,
														),
													),
												),
											),
										),

										Text(
											TimeOfDay.fromDateTime(
												DateTime.fromMillisecondsSinceEpoch(
													_historyPoints[_playbackIndex]
															.timestamp,
												),
											).format(context),
										),
									],
								),
							),
						),
					
					],
				),
    );
  }
}