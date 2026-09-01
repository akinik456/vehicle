import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/history_service.dart';
import '../models/history_point.dart';

import '../models/locator_presence.dart';
import 'vehicle_info_card.dart';
import '../extensions/context_extensions.dart';

class MapPanel extends StatefulWidget {
	final String groupId;
  final List<LocatorPresence> locators;
  final String? selectedVehicleId;
	final ValueChanged<String>? onVehicleSelected;
	final bool isFullscreen;
	final VoidCallback onToggleFullscreen;
	
  const MapPanel({
    super.key,
		required this.groupId,
    required this.locators,
    required this.selectedVehicleId,
		required this.isFullscreen,
		required this.onToggleFullscreen,
		this.onVehicleSelected,
  });

  @override
  State<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<MapPanel> {
  GoogleMapController? _mapController;
	MapType _mapType = MapType.normal;
	bool _followSelectedVehicle = true;
	List<HistoryPoint> _historyPoints = [];
	bool _showHistory = false;
	BitmapDescriptor? _historyStartIcon;
	BitmapDescriptor? _historyEndIcon;
	BitmapDescriptor? _playbackVehicleIcon;
	BitmapDescriptor? _historyPointIcon;
	BitmapDescriptor? _vehicleMarkerIcon;
	BitmapDescriptor? _selectedVehicleMarkerIcon;
	Timer? _playbackTimer;
	bool _isPlaying = false;
	int _playbackIndex = 0;
	double _playbackSpeed = 1.0;
	
	
	@override
	void initState() {
		super.initState();
		_loadHistoryIcons();
	}
	Future<void> _loadHistoryIcons() async {
		_historyStartIcon =
				await BitmapDescriptor.asset(
			const ImageConfiguration(size: Size(64, 64)),
			'assets/images/history_start.png',
		);

		_historyEndIcon =
				await BitmapDescriptor.asset(
			const ImageConfiguration(size: Size(64, 64)),
			'assets/images/history_end.png',
		);
		
		_playbackVehicleIcon =
				await BitmapDescriptor.asset(
			const ImageConfiguration(
				size: Size(32, 32),
			),
			'assets/images/playback_vehicle.png',
		);
		
		_historyPointIcon =
				await BitmapDescriptor.asset(
			const ImageConfiguration(
				size: Size(10, 10),
			),
			'assets/images/history_point.png',
		);
		
		_vehicleMarkerIcon = await BitmapDescriptor.asset(
			const ImageConfiguration(size: Size(44, 44)),
			'assets/images/vehicle_marker.png',
		);

		_selectedVehicleMarkerIcon = await BitmapDescriptor.asset(
			const ImageConfiguration(size: Size(48, 48)),
			'assets/images/vehicle_marker_selected.png',
		);

		if (mounted) {
			setState(() {});
		}
	}
	
	Future<void> _centerPlaybackVehicle() async {
		if (_mapController == null ||
				_historyPoints.isEmpty) {
			return;
		}

		final point =
				_historyPoints[_playbackIndex].position;

		await _mapController!.animateCamera(
			CameraUpdate.newLatLng(point),
		);
	}
	
	@override
	void dispose() {
		_playbackTimer?.cancel();
		super.dispose();
	}	

@override
void didUpdateWidget(covariant MapPanel oldWidget) {
  super.didUpdateWidget(oldWidget);

  final selectedChanged =
      widget.selectedVehicleId !=
          oldWidget.selectedVehicleId;

  final groupChanged =
      widget.groupId != oldWidget.groupId;

  if (selectedChanged || groupChanged) {
    _playbackTimer?.cancel();

    setState(() {
      _showHistory = false;
      _historyPoints = [];
      _playbackIndex = 0;
      _isPlaying = false;
    });
  }

  if (!_followSelectedVehicle) return;

  final locationChanged =
      widget.locators != oldWidget.locators;

  if (selectedChanged || locationChanged) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToSelectedVehicle();
    });
  }
}
  Future<void> _moveToSelectedVehicle() async {
    if (_mapController == null) return;
    if (widget.selectedVehicleId == null) return;

    final index = widget.locators.indexWhere(
      (e) => e.locatorId == widget.selectedVehicleId,
    );

    if (index == -1) return;

    final vehicle = widget.locators[index];

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          vehicle.lat,
          vehicle.lng,
        ),
        16,
      ),
    );
  }
	Future<void> _fitAllVehicles() async {
		if (_mapController == null) return;
		if (widget.locators.isEmpty) return;

		setState(() {
			_followSelectedVehicle = false;
		});

		if (widget.locators.length == 1) {
			final vehicle = widget.locators.first;

			await _mapController!.animateCamera(
				CameraUpdate.newLatLngZoom(
					LatLng(vehicle.lat, vehicle.lng),
					16,
				),
			);

			return;
		}

		double minLat = widget.locators.first.lat;
		double maxLat = widget.locators.first.lat;
		double minLng = widget.locators.first.lng;
		double maxLng = widget.locators.first.lng;

		for (final vehicle in widget.locators.skip(1)) {
			if (vehicle.lat < minLat) minLat = vehicle.lat;
			if (vehicle.lat > maxLat) maxLat = vehicle.lat;
			if (vehicle.lng < minLng) minLng = vehicle.lng;
			if (vehicle.lng > maxLng) maxLng = vehicle.lng;
		}

		final bounds = LatLngBounds(
			southwest: LatLng(minLat, minLng),
			northeast: LatLng(maxLat, maxLng),
		);

		await _mapController!.animateCamera(
			CameraUpdate.newLatLngBounds(
				bounds,
				80,
			),
		);
	}	
	
	Future<void> _toggleHistory() async {
		_playbackTimer?.cancel();

setState(() {
  _showHistory = false;
  _historyPoints = [];
  _playbackIndex = 0;
  _isPlaying = false;
});

		await _moveToSelectedVehicle();
	}
	void _startPlayback() {
		if (_historyPoints.isEmpty) return;

		_playbackTimer?.cancel();

		setState(() {
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
					_stopPlayback();
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

  setState(() {
    _isPlaying = false;
  });
}

void _stopPlayback() {
  _playbackTimer?.cancel();

  setState(() {
    _isPlaying = false;
  });
}	
Future<void> _selectHistoryRange() async {
  final locatorId = widget.selectedVehicleId;
  if (locatorId == null) return;

  TimeOfDay startTime = const TimeOfDay(
    hour: 0,
    minute: 0,
  );

  TimeOfDay endTime = const TimeOfDay(
    hour: 23,
    minute: 59,
  );

  final result = await showDialog<List<TimeOfDay>>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Today\'s Route'),

            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ================= START =================

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Start time',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.schedule,
                      ),
                      label: Text(
                        startTime.format(context),
                      ),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );

                        if (time == null) return;

                        setDialogState(() {
                          startTime = time;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= END =================

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'End time',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.schedule,
                      ),
                      label: Text(
                        endTime.format(context),
                      ),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );

                        if (time == null) return;

                        setDialogState(() {
                          endTime = time;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),

              FilledButton.icon(
                icon: const Icon(Icons.route),
                label: const Text('Show Route'),
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    [
                      startTime,
                      endTime,
                    ],
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );

  if (result == null || result.length != 2) return;

  final now = DateTime.now();

  final start = DateTime(
    now.year,
    now.month,
    now.day,
    result[0].hour,
    result[0].minute,
  );

  final end = DateTime(
    now.year,
    now.month,
    now.day,
    result[1].hour,
    result[1].minute,
  );

  if (!end.isAfter(start)) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'End time must be after start time.',
        ),
      ),
    );

    return;
  }

  final points = await HistoryService.getPointsBetween(
    groupId: widget.groupId,
    locatorId: locatorId,
    start: start,
    end: end,
  );

  if (!mounted) return;

  if (points.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No history found for this time range.',
        ),
      ),
    );
    return;
  }

  setState(() {
  _historyPoints = points;
  _showHistory = true;
  _followSelectedVehicle = false;

  _playbackIndex = 0;
  _isPlaying = false;
});

  await _fitHistoryPoints(
  points
      .map((point) => point.position)
      .toList(),
);
}	
	Future<void> _fitHistoryPoints(
		List<LatLng> points,
	) async {
		if (_mapController == null || points.isEmpty) return;

		if (points.length == 1) {
			await _mapController!.animateCamera(
				CameraUpdate.newLatLngZoom(
					points.first,
					16,
				),
			);

			return;
		}

		double minLat = points.first.latitude;
		double maxLat = points.first.latitude;
		double minLng = points.first.longitude;
		double maxLng = points.first.longitude;

		for (final point in points.skip(1)) {
			if (point.latitude < minLat) minLat = point.latitude;
			if (point.latitude > maxLat) maxLat = point.latitude;
			if (point.longitude < minLng) minLng = point.longitude;
			if (point.longitude > maxLng) maxLng = point.longitude;
		}

		await _mapController!.animateCamera(
			CameraUpdate.newLatLngBounds(
				LatLngBounds(
					southwest: LatLng(minLat, minLng),
					northeast: LatLng(maxLat, maxLng),
				),
				80,
			),
		);
	}

  @override
  Widget build(BuildContext context) {
		final selectedVehicle = widget.selectedVehicleId == null
			? null
			: widget.locators.cast<LocatorPresence?>().firstWhere(
					(e) => e?.locatorId == widget.selectedVehicleId,
					orElse: () => null,
				);
				
    final markers = _showHistory
    ? <Marker>{}
    : widget.locators.map((locator) {
        final selected =
            locator.locatorId == widget.selectedVehicleId;

        return Marker(
          markerId: MarkerId(locator.locatorId),
          position: LatLng(
            locator.lat,
            locator.lng,
          ),
          icon: selected
              ? _selectedVehicleMarkerIcon ??
                  BitmapDescriptor.defaultMarker
              : _vehicleMarkerIcon ??
                  BitmapDescriptor.defaultMarker,
          onTap: () {
            widget.onVehicleSelected?.call(locator.locatorId);
          },
          infoWindow: InfoWindow(
            title: locator.locatorPlate.isNotEmpty
                ? locator.locatorPlate
                : context.l10n.unknownPlate,
            snippet:
                '${locator.status} • ${context.l10n.battery} ${locator.battery}%',
          ),
        );
      }).toSet();
			if (_showHistory && _historyPoints.isNotEmpty) {
				// START
				markers.add(
					Marker(
						markerId: const MarkerId('historyStart'),
						position: _historyPoints.first.position,
						icon: _historyStartIcon ??
								BitmapDescriptor.defaultMarker,
						infoWindow: const InfoWindow(
							title: 'Start',
						),
					),
				);

				// END
				if (_historyPoints.length > 1) {
					markers.add(
						Marker(
							markerId: const MarkerId('historyEnd'),
							position: _historyPoints.last.position,
							icon: _historyEndIcon ??
									BitmapDescriptor.defaultMarker,
						infoWindow: const InfoWindow(
								title: 'End',
							),
						),
					);
				}

				markers.add(
					Marker(
						markerId: MarkerId(
							'playbackVehicle_$_playbackIndex',
						),
						position: _historyPoints[_playbackIndex].position,
						icon: _playbackVehicleIcon ??
								BitmapDescriptor.defaultMarker,
						zIndex: 999,
						infoWindow: InfoWindow(
							title: TimeOfDay.fromDateTime(
								DateTime.fromMillisecondsSinceEpoch(
									_historyPoints[_playbackIndex].timestamp,
								),
							).format(context),
						),
					),
				);				
				for (int i = 0; i < _historyPoints.length; i++) {
					final point = _historyPoints[i];

					markers.add(
						Marker(
							markerId: MarkerId('historyPoint_$i'),
							position: point.position,
							icon: _historyPointIcon ??
									BitmapDescriptor.defaultMarker,
							zIndex: 2,
							infoWindow: InfoWindow(
								title: TimeOfDay.fromDateTime(
									DateTime.fromMillisecondsSinceEpoch(
										point.timestamp,
									),
								).format(context),
							),
						),
					);
				}
			}					
			if (_showHistory && _historyPoints.isNotEmpty) {
			markers.add(
				Marker(
					markerId: const MarkerId('playbackVehicle'),
					position: _historyPoints[_playbackIndex].position,
					icon: _playbackVehicleIcon ??
							BitmapDescriptor.defaultMarker,
					infoWindow: InfoWindow(
						title: TimeOfDay.fromDateTime(
							DateTime.fromMillisecondsSinceEpoch(
								_historyPoints[_playbackIndex].timestamp,
							),
						).format(context),
					),
				),
			);
		}
    final initialTarget = widget.locators.isNotEmpty
        ? LatLng(
            widget.locators.first.lat,
            widget.locators.first.lng,
          )
        : const LatLng(
            40.0164648,
            32.8662597,
          );

    return Stack(		
			children: [
				GoogleMap(
					onMapCreated: (controller) {
						_mapController = controller;

						if (_followSelectedVehicle) {
							_moveToSelectedVehicle();
						}
					},
					mapType: _mapType,
					initialCameraPosition: CameraPosition(
						target: initialTarget,
						zoom: 16,
					),
					markers: markers,
					polylines: _showHistory && _historyPoints.length >= 2
					? {
							// KALAN ROTA
							if (_playbackIndex <
									_historyPoints.length - 1)
								Polyline(
									polylineId:
											const PolylineId('historyRemaining'),
									points: _historyPoints
											.sublist(_playbackIndex)
											.map((point) => point.position)
											.toList(),
									width: 5,
									color: Colors.red,
								),

							// GEÇİLEN ROTA
							if (_playbackIndex > 0)
								Polyline(
									polylineId:
											const PolylineId('historyPassed'),
									points: _historyPoints
											.sublist(
												0,
												_playbackIndex + 1,
											)
											.map((point) => point.position)
											.toList(),
									width: 5,
									color: Colors.yellow,
								),
						}
					: {},
					myLocationButtonEnabled: false,
					zoomControlsEnabled: true,
					mapToolbarEnabled: false,
					compassEnabled: true,
				),
				if (selectedVehicle != null)
					Positioned(
						top: 16,
						right: 16,
						child: VehicleInfoCard(
							vehicle: selectedVehicle,
							groupId: widget.groupId,
						),
					),

				if (selectedVehicle != null)
					Positioned(
						top: 128,
						left: 16,
						child: FloatingActionButton.small(
							heroTag: 'followVehicle',
							tooltip: 'Follow vehicle',
							onPressed: () {
								setState(() {
									_followSelectedVehicle = !_followSelectedVehicle;
								});

								if (_followSelectedVehicle) {
									_moveToSelectedVehicle();
								}
							},
							child: Icon(
								_followSelectedVehicle
										? Icons.gps_fixed
										: Icons.gps_not_fixed,
							),
						),
					),
					if (selectedVehicle != null)
					Positioned(
						top: 184,
						left: 16,
						child: FloatingActionButton.small(
							heroTag: 'vehicleHistory',
							tooltip: _showHistory
									? 'Hide history'
									: 'Show history',
							onPressed: _showHistory
								? _toggleHistory
								: _selectHistoryRange,
							child: Icon(
								_showHistory
										? Icons.route
										: Icons.history,
							),
						),
					),
					Positioned(
						top: 16,
						left: 16,
						child: FloatingActionButton.small(
							heroTag: 'mapType',
							tooltip: _mapType.name,
							onPressed: () {
								setState(() {
									switch (_mapType) {
										case MapType.normal:
											_mapType = MapType.satellite;
											break;

										case MapType.satellite:
											_mapType = MapType.terrain;
											break;

										default:
											_mapType = MapType.normal;
									}
								});
							},
							child: Icon(
								switch (_mapType) {
									MapType.normal => Icons.map,
									MapType.satellite => Icons.satellite_alt,
									MapType.terrain => Icons.terrain,
									_ => Icons.map,
								},
							),
						),
					),
					Positioned(
						top: 72,
						left: 16,
						child: FloatingActionButton.small(
							heroTag: 'fitAllVehicles',
							tooltip: 'Show all vehicles',
							onPressed: _fitAllVehicles,
							child: const Icon(
								Icons.zoom_out_map,
							),
						),
					),			
					Positioned(
					top: 240,
					left: 16,
					child: FloatingActionButton.small(
						heroTag: 'fullscreenMap',
						tooltip: widget.isFullscreen
								? 'Exit fullscreen'
								: 'Fullscreen map',
						onPressed: widget.onToggleFullscreen,
						child: Icon(
							widget.isFullscreen
									? Icons.fullscreen_exit_rounded
									: Icons.fullscreen_rounded,
						),
					),
				),
				if (_showHistory && _historyPoints.isNotEmpty)
				Positioned(
					left: 24,
					right: 24,
					bottom: 24,
					child: Center(
						child: Container(
							width: 520,
							padding: const EdgeInsets.symmetric(
								horizontal: 16,
								vertical: 10,
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
										tooltip: _isPlaying ? 'Pause' : 'Play',
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
											max: (_historyPoints.length - 1).toDouble(),
											value: _playbackIndex
													.clamp(
														0,
														_historyPoints.length - 1,
													)
													.toDouble(),
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
										tooltip: 'Playback speed',
										onSelected: (speed) {
											setState(() {
												_playbackSpeed = speed;
											});

											if (_isPlaying) {
												_startPlayback();
											}
										},
										itemBuilder: (context) => const [
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
											padding: const EdgeInsets.symmetric(
												horizontal: 8,
												vertical: 6,
											),
											child: Text(
												'${_playbackSpeed.toInt()}x',
												style: const TextStyle(
													fontWeight: FontWeight.w700,
												),
											),
										),
									),									

									const SizedBox(width: 8),
									Text(
										TimeOfDay.fromDateTime(
											DateTime.fromMillisecondsSinceEpoch(
												_historyPoints[_playbackIndex].timestamp,
											),
										).format(context),
										style: const TextStyle(
											fontWeight: FontWeight.w600,
										),
									),
								],
							),
						),
					),
				),	
			],			
		);
  }
}