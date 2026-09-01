import 'package:flutter/material.dart';
import '../models/locator_presence.dart';
import '../utils/time_helper.dart';
import '../extensions/context_extensions.dart';
import '../services/presence_service.dart';

class VehicleInfoCard extends StatelessWidget {
  final LocatorPresence vehicle;
	final String groupId;

  const VehicleInfoCard({
    super.key,
    required this.vehicle,
		required this.groupId,
  });
	

  @override
  Widget build(BuildContext context) {
	final speed = vehicle.speed.round();

	final speedColor =
			speed < 90
					? Colors.greenAccent
					: speed < 120
							? Colors.orangeAccent
							: Colors.redAccent;
    return Material(
      color: const Color(0xFF273449),
      elevation: 6,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 240,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						mainAxisSize: MainAxisSize.min,
						children: [
							Text(
								vehicle.locatorPlate,
								style: const TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 4),
							Text(
								vehicle.locatorName,
								style: const TextStyle(
									fontSize: 14,
									color: Colors.white70,
								),
							),
							const SizedBox(height: 12),

							Row(
								children: [
									Container(
										width: 12,
										height: 12,
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											color: vehicle.status == 'online'
													? Colors.greenAccent
													: Colors.redAccent,
										),
									),
									const SizedBox(width: 8),
									Text(
										vehicle.status == 'online'
												? 'Online'
												: TimeHelper.formatOfflineSince(vehicle.offlineSince),
										style: const TextStyle(
											fontSize: 13,
											color: Colors.white70,
										),
									),
									const Spacer(),
									Text(
										'🔋${vehicle.battery}%',
										style: const TextStyle(
											fontSize: 13,
											fontWeight: FontWeight.w600,
										),
									),
								],
							),
							const SizedBox(height: 10),
							Row(
								children: [
									Icon(
										vehicle.gpsEnabled
												? Icons.gps_fixed_rounded
												: Icons.gps_off_rounded,
										size: 16,
										color: vehicle.gpsEnabled
												? Colors.greenAccent
												: Colors.redAccent,
									),
									const SizedBox(width: 6),
									Text(
										vehicle.gpsEnabled
												? 'GPS On'
												: 'GPS Off',
										style: TextStyle(
											fontSize: 13,
											fontWeight: FontWeight.w600,
											color: vehicle.gpsEnabled
													? Colors.greenAccent
													: Colors.redAccent,
										),
									),
								],
							),							
							const SizedBox(height: 10),
							Row(
								mainAxisSize: MainAxisSize.min,
								children: [
									Icon(
										vehicle.speed > 0
												? Icons.speed_rounded
												: Icons.directions_car_rounded,
										size: 16,
										color: vehicle.speed > 0
											? Colors.white70
											: Colors.redAccent,
									),
									const SizedBox(width: 6),
									Text(
										vehicle.speed > 0
												? '${vehicle.speed.toStringAsFixed(0)} km/h'
												: context.l10n.parked,
										style: TextStyle(
											fontSize: 14,
											color: vehicle.speed > 0
													? speedColor
													: Colors.white70,
											fontWeight: FontWeight.w600,
										),
									),
								],
							),
							const SizedBox(height: 12),

							Row(
								children: [
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Row(
													children: [
														const Text(
															'Odometer',
															style: TextStyle(
																fontSize: 12,
																color: Colors.white60,
															),
														),
														const SizedBox(width: 6),
														IconButton.filledTonal(
															onPressed: () async {
																final controller = TextEditingController(
																	text: (vehicle.totalDistanceMeters / 1000)
																			.toStringAsFixed(1),
																);

																final newValue = await showDialog<double>(
																	context: context,
																	builder: (context) {
																		return AlertDialog(
																			title: const Text('Edit Odometer'),
																			content: TextField(
																				controller: controller,
																				autofocus: true,
																				keyboardType: const TextInputType.numberWithOptions(
																					decimal: true,
																				),
																				decoration: const InputDecoration(
																					labelText: 'Odometer',
																					suffixText: 'km',
																					border: OutlineInputBorder(),
																				),
																				onSubmitted: (_) {
																					final value = double.tryParse(
																						controller.text.replaceAll(',', '.'),
																					);

																					if (value != null && value >= 0) {
																						Navigator.pop(context, value);
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
																						final value = double.tryParse(
																							controller.text.replaceAll(',', '.'),
																						);

																						if (value == null || value < 0) return;

																						Navigator.pop(context, value);
																					},
																					child: const Text('Save'),
																				),
																			],
																		);
																	},
																);

																controller.dispose();

																if (newValue == null) return;

																final newMeters = (newValue * 1000).round();

																debugPrint(
																	'ODOMETER EDIT => '
																	'${vehicle.locatorId} => $newMeters meters',
																);

																await PresenceService.updateOdometer(
																	groupId: groupId,
																	locatorId: vehicle.locatorId,
																	totalDistanceMeters: newMeters,
																);
															},
															tooltip: 'Edit odometer',
															icon: const Icon(
																Icons.edit_rounded,
																size: 13,
															),
															constraints: const BoxConstraints(
																minWidth: 24,
																minHeight: 24,
															),
															padding: EdgeInsets.zero,
														),
													],
												),
												const SizedBox(height: 2),
												Text(
													'${(vehicle.totalDistanceMeters / 1000).toStringAsFixed(1)} km',
													style: const TextStyle(
														fontSize: 12,
														fontWeight: FontWeight.w600,
													),
												),												
											],
										),
									),
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Row(
													children: [
														const Text(
															'Trip',
															style: TextStyle(
																fontSize: 12,
																color: Colors.white60,
															),
														),
														const SizedBox(width: 6),
														IconButton.filledTonal(
															onPressed: () async {
																final confirmed = await showDialog<bool>(
																	context: context,
																	builder: (context) {
																		return AlertDialog(
																			title: const Text('Reset Trip'),
																			content: const Text(
																				'Are you sure you want to reset the trip distance?',
																			),
																			actions: [
																				TextButton(
																					onPressed: () => Navigator.pop(context, false),
																					child: const Text('Cancel'),
																				),
																				FilledButton(
																					onPressed: () => Navigator.pop(context, true),
																					child: const Text('Reset'),
																				),
																			],
																		);
																	},
																);

																if (confirmed != true) return;

																await PresenceService.resetTrip(
																	groupId: groupId,
																	locatorId: vehicle.locatorId,
																);
															},
															tooltip: 'Edit odometer',
															icon: const Icon(
																Icons.restart_alt_rounded,
																size: 13,
															),
															constraints: const BoxConstraints(
																minWidth: 24,
																minHeight: 24,
															),
															padding: EdgeInsets.zero,
														),
													],
												),
												const SizedBox(height: 2),
												Text(
													'${(vehicle.tripDistanceMeters / 1000).toStringAsFixed(1)} km',
													style: const TextStyle(
														fontSize: 12,
														fontWeight: FontWeight.w600,
													),
												),
											],
										),
									),
								],
							),
							const SizedBox(height: 12),
							Text(
								context.l10n.address,
								style: TextStyle(
									fontSize: 13,
									color: Colors.white60,
									fontWeight: FontWeight.w700,
								),
							),

							const SizedBox(height: 4),

							Text(
								vehicle.address,
								style: const TextStyle(
									fontSize: 13,
									color: Colors.white60,
								),
							),
							const SizedBox(height: 12),

							Text(
								TimeHelper.locationDurationText(
									context,
									vehicle.stationarySince,
								),
								style: const TextStyle(
									fontSize: 13,
									color: Colors.white70,
								),
							),				
						],
					),
        ),
      ),
    );
  }
}