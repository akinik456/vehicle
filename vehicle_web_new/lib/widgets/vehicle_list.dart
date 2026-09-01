import '../models/locator_presence.dart';
import 'package:flutter/material.dart';

import 'vehicle_card.dart';
import '../extensions/context_extensions.dart';
import '../services/vehicle_info_service.dart';

class VehicleList extends StatelessWidget {
  final List<LocatorPresence> vehicles;
	final String? selectedVehicleId;
	final ValueChanged<String> onVehicleSelected;
	final void Function(String locatorId, String vehicleType)
    onVehicleTypeChanged;
		
	const VehicleList({
		super.key,
		required this.vehicles,
		required this.selectedVehicleId,
		required this.onVehicleSelected,
		required this.onVehicleTypeChanged,
	});

  @override
  Widget build(BuildContext context) {
    return Expanded(
			child: ListView.builder(
				itemCount: vehicles.length,
				itemBuilder: (context, index) {
					final vehicle = vehicles[index];

					return VehicleCard(
						locatorId: vehicle.locatorId,
						vehicleType: vehicle.vehicleType,
						onVehicleTypeChanged: (type) async {
							await VehicleInfoService.updateVehicleType(
								locatorId: vehicle.locatorId,
								vehicleType: type,
							);

							onVehicleTypeChanged(
								vehicle.locatorId,
								type,
							);
						},
						plate: vehicle.locatorPlate.isNotEmpty
								? vehicle.locatorPlate
								: context.l10n.unknownPlate,

						driverName: vehicle.locatorName.isNotEmpty
								? vehicle.locatorName
								: context.l10n.driverName,

						battery: vehicle.battery,
						address: vehicle.address.isEmpty
								? ''
								: vehicle.address,

						isOnline: vehicle.status == 'online',
						speed: 0,

						lastUpdate: vehicle.speed > 0
								? '${vehicle.speed.toStringAsFixed(0)} km/h'
								: context.l10n.parked,

						offlineSince: vehicle.offlineSince,
						isSelected: vehicle.locatorId == selectedVehicleId,

						onTap: () {
							onVehicleSelected(vehicle.locatorId);
						},
					);
				},
			),
		);
  }
}