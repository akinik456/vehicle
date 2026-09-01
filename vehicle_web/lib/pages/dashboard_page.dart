import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_config.dart';
import '../models/locator_presence.dart';
import '../services/presence_service.dart';
import '../services/vehicle_info_service.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/left_panel.dart';
import '../widgets/map_panel.dart';
import '../services/fleet_manager_service.dart';
import '../extensions/context_extensions.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  StreamSubscription<List<LocatorPresence>>? _presenceSubscription;

  List<LocatorPresence> _locators = [];
  Map<String, Map<String, String>> _vehicleInfo = {};
	String? _groupId;
	String _groupName = '';
	String _managerName = '';
  String? _selectedVehicleId;
	bool? _hasWebAccess ;
	bool _mapFullscreen = false;
	List<Map<String, String>> _groups = [];
	
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
		final groups =
				await FleetManagerService.getCurrentGroups();

		if (!mounted) return;

		if (groups.isEmpty) {
			setState(() {
				_groups = [];
				_hasWebAccess = false;
			});

			return;
		}

		setState(() {
			_groups = groups;
			_hasWebAccess = true;
		});

		final firstGroupId =
				groups.first['groupId'];

		if (firstGroupId == null) return;

		await _openGroup(firstGroupId);
	}
	
	Future<void> _openGroup(String groupId) async {
		// Eski filonun listener'ını kapat.
		await _presenceSubscription?.cancel();
		_presenceSubscription = null;

		// Eski filo verisini ekrandan kaldır.
		if (mounted) {
			setState(() {
				_groupId = groupId;
				_groupName = '';
				_managerName = '';
				_locators = [];
				_vehicleInfo = {};
				_selectedVehicleId = null;
			});
		}

		final groupName =
				await FleetManagerService.getGroupName(
			groupId,
		);

		final managerName =
				await FleetManagerService.getMasterRequesterName(
			groupId,
		);

		await _loadVehicleInfo(groupId);

		if (!mounted) return;

		setState(() {
			_groupId = groupId;
			_groupName = groupName ?? '';
			_managerName = managerName ?? '';
		});

		_presenceSubscription =
				PresenceService.watchLocators(
			groupId: groupId,
		).listen(
			(locators) {
				for (final locator in locators) {
					final info =
							_vehicleInfo[locator.locatorId];

					if (info != null) {
						locator.locatorName =
								info['locatorName'] ?? '';

						locator.locatorPlate =
								info['locatorPlate'] ?? '';

						locator.vehicleType =
								info['vehicleType'] ?? 'car';
					}
				}

				if (!mounted) return;

				setState(() {
					_locators = locators;
					
					if (_selectedVehicleId == null && _locators.isNotEmpty) {
						_selectedVehicleId = _locators.first.locatorId;
					}
				});
			},
			onError: (error, stack) {
				debugPrint(
					'PRESENCE STREAM ERROR => $error',
				);
				debugPrint('$stack');
			},
		);
	}
	
	Future<void> _showFleetManagement() async {
		if (_groups.isEmpty) return;

		final selectedGroupId = await showDialog<String>(
			context: context,
			builder: (dialogContext) {
				return AlertDialog(
					title: const Row(
						children: [
							Icon(Icons.directions_car_filled_rounded),
							SizedBox(width: 10),
							Text('Fleet Management'),
						],
					),
					content: SizedBox(
						width: 420,
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: _groups.map((group) {
								final groupId = group['groupId']!;
								final groupName =
										group['groupName'] ?? 'Fleet';

								final selected =
										groupId == _groupId;

								return ListTile(
									contentPadding: const EdgeInsets.symmetric(
										horizontal: 8,
									),
									leading: Icon(
										selected
												? Icons.check_circle_rounded
												: Icons.circle_outlined,
									),
									title: Text(
										groupName,
										style: TextStyle(
											fontWeight: selected
													? FontWeight.w700
													: FontWeight.normal,
										),
									),
									subtitle: selected
											? const Text('Current fleet')
											: null,
											
									trailing: Row(
										mainAxisSize: MainAxisSize.min,
										children: [
											if (!selected)
												const Icon(
													Icons.chevron_right_rounded,
												),

											const SizedBox(width: 8),

											IconButton(
												tooltip: 'Remove web access',
												icon: const Icon(
													Icons.delete_outline_rounded,
													color: Colors.redAccent,
												),
												onPressed: () async {
													Navigator.pop(dialogContext);

													await _removeFleetAccess(
														groupId,
														groupName,
													);
												},
											),
										],
									),
												
									onTap: () {
										Navigator.pop(
											dialogContext,
											groupId,
										);
									},
								);
							}).toList(),
						),
					),
					actions: [
						TextButton(
							onPressed: () {
								Navigator.pop(dialogContext);
							},
							child: const Text('Close'),
						),
					],
				);
			},
		);

		if (selectedGroupId == null ||
				selectedGroupId == _groupId) {
			return;
		}

		await _openGroup(selectedGroupId);
	}
	
  Future<void> _loadVehicleInfo(String groupId) async {
		try {
			_vehicleInfo = await VehicleInfoService.loadAllVehicleInfo(
				groupId: groupId,
			);

			debugPrint(
				'VEHICLE INFO => '
				'count=${_vehicleInfo.length} '
				'data=$_vehicleInfo',
			);
		} catch (e) {
			debugPrint(
				'VEHICLE INFO ERROR => $e',
			);
		}
	}
	
  void _selectVehicle(String vehicleId) {
    setState(() {
      _selectedVehicleId = vehicleId;
    });
  }

  @override
  void dispose() {
    _presenceSubscription?.cancel();
    super.dispose();
  }
	
	Future<void> _editGroupName() async {
		if (_groupId == null) return;

		final controller = TextEditingController(
			text: _groupName,
		);

		final newName = await showDialog<String>(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: const Text('Edit Fleet Name'),
					content: TextField(
						controller: controller,
						autofocus: true,
						decoration: const InputDecoration(
							labelText: 'Fleet Name',
							border: OutlineInputBorder(),
						),
						onSubmitted: (value) {
							final name = value.trim();

							if (name.isNotEmpty) {
								Navigator.pop(context, name);
							}
						},
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.pop(context),
							child: const Text('Cancel'),
						),
						FilledButton(
							onPressed: () {
								final name = controller.text.trim();

								if (name.isEmpty) return;

								Navigator.pop(context, name);
							},
							child: const Text('Save'),
						),
					],
				);
			},
		);

		controller.dispose();

		if (newName == null || newName == _groupName) return;

		await FleetManagerService.updateGroupName(
			groupId: _groupId!,
			groupName: newName,
		);

		if (!mounted) return;

		setState(() {
			_groupName = newName;
		});
	}	
	
	Future<void> _removeFleetAccess(
		String groupId,
		String groupName,
	) async {
		final confirmed = await showDialog<bool>(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: const Text('Remove Fleet Access'),
					content: Text(
						'Remove web panel access to "$groupName"?',
					),
					actions: [
						TextButton(
							onPressed: () {
								Navigator.pop(context, false);
							},
							child: const Text('Cancel'),
						),
						FilledButton(
							onPressed: () {
								Navigator.pop(context, true);
							},
							child: const Text('Remove'),
						),
					],
				);
			},
		);

		if (confirmed != true) return;

		await FleetManagerService.removeCurrentUserGroupAccess(
			groupId,
		);

		final groups =
				await FleetManagerService.getCurrentGroups();

		if (!mounted) return;

		// Hiç filo kalmadı.
		if (groups.isEmpty) {
			await _presenceSubscription?.cancel();

			setState(() {
				_groups = [];
				_groupId = null;
				_groupName = '';
				_managerName = '';
				_locators = [];
				_vehicleInfo = {};
				_selectedVehicleId = null;
				_hasWebAccess = false;
			});

			return;
		}

		setState(() {
			_groups = groups;
		});

		// Silinen filo açıksa başka filoya geç.
		if (_groupId == groupId) {
			final nextGroupId =
					groups.first['groupId'];

			if (nextGroupId != null) {
				await _openGroup(nextGroupId);
			}
		}
	}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DashboardHeader(
						groupName: _groupName,
						managerName: _managerName,
						onEditGroupName: _editGroupName,
						onFleetManagement: _showFleetManagement,
					),
          Expanded(
						child: _hasWebAccess == null
								? const Center(
										child: CircularProgressIndicator(),
									)
								: _hasWebAccess == false
										? Center(
												child: Text(
													'${context.l10n.webaccessisnotactive}\n\n'
													'${context.l10n.pleaseactivatewebaccess}',
													textAlign: TextAlign.center,
												),
											)
										: Row(
												children: [
												if (!_mapFullscreen)
													SizedBox(
														width: 360,
														child: LeftPanel(
															vehicles: _locators,
															selectedVehicleId: _selectedVehicleId,
															onVehicleSelected: _selectVehicle,
															onVehicleTypeChanged: (locatorId, type) {
																setState(() {
																	final vehicle = _locators.firstWhere(
																		(v) => v.locatorId == locatorId,
																	);

																	vehicle.vehicleType = type;
																});
															},
														),
													),
													Expanded(
														child: MapPanel(
															groupId: _groupId!,
															locators: _locators,
															selectedVehicleId: _selectedVehicleId,
															onVehicleSelected: _selectVehicle,
															isFullscreen: _mapFullscreen,
															onToggleFullscreen: () {
																setState(() {
																	_mapFullscreen = !_mapFullscreen;
																});
															},
														),
													),
												],
											),
					),
        ],
      ),
    );
  }
}