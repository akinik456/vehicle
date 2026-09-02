import 'package:flutter/material.dart';

import '../models/locator_presence.dart';
import 'panel_footer.dart';
import 'panel_header.dart';
import 'vehicle_list.dart';
import 'vehicle_search_bar.dart';

class LeftPanel extends StatefulWidget {	
  final List<LocatorPresence> vehicles;
	final String? selectedVehicleId;
	final ValueChanged<String> onVehicleSelected;
	final void Function(String locatorId, String vehicleType)
    onVehicleTypeChanged;
	final VoidCallback onAddVehicle;
		
	const LeftPanel({
		super.key,
		required this.vehicles,
		required this.selectedVehicleId,
		required this.onVehicleSelected,
		required this.onVehicleTypeChanged,
		required this.onAddVehicle,
	});
@override
  State<LeftPanel> createState() =>
      _LeftPanelState();
}

 class _LeftPanelState extends State<LeftPanel> {
	String _search = '';
	String _statusFilter = 'all';
	
  @override
  Widget build(BuildContext context) {
		final onlineCount = widget.vehicles
				.where((v) => v.status.toLowerCase() == 'online')
				.length;

		final offlineCount = widget.vehicles.length - onlineCount;
		
    final filteredVehicles = widget.vehicles.where((vehicle) {
			final query = _search.trim().toLowerCase();

			final matchesSearch =
					query.isEmpty ||
					vehicle.locatorPlate.toLowerCase().contains(query) ||
					vehicle.locatorName.toLowerCase().contains(query) ||
					vehicle.address.toLowerCase().contains(query);

			final isOnline =
					vehicle.status.toLowerCase() == 'online';

			final matchesStatus = switch (_statusFilter) {
				'online' => isOnline,
				'offline' => !isOnline,
				_ => true,
			};

			return matchesSearch && matchesStatus;
		}).toList();

    return Column(
      children: [
        VehicleSearchBar(
          onChanged: (value) {
            setState(() {
              _search = value;
            });
          },
        ),
				Padding(
					padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
					child: SizedBox(
						width: double.infinity,
						child: SegmentedButton<String>(
							segments: [
								ButtonSegment(
									value: 'all',
									label: Text('Tümü ${widget.vehicles.length}'),
								),
								ButtonSegment(
									value: 'online',
									icon: const Icon(
										Icons.circle,
										size: 9,
										color: Colors.greenAccent,
									),
									label: Text('Online $onlineCount'),
								),
								ButtonSegment(
									value: 'offline',
									icon: const Icon(
										Icons.circle,
										size: 9,
										color: Colors.redAccent,
									),
									label: Text('Offline $offlineCount'),
								),
							],
							selected: {_statusFilter},
							showSelectedIcon: false,
							onSelectionChanged: (selection) {
								setState(() {
									_statusFilter = selection.first;
								});
							},
						),
					),
				),
				Padding(
					padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
					child: SizedBox(
						width: double.infinity,
						height: 46,
						child: FilledButton.icon(
							onPressed: widget.onAddVehicle,
							icon: const Icon(Icons.add_rounded),
							label: const Text('Add Vehicle'),
						),
					),
				),				
        VehicleList(
					vehicles: filteredVehicles,
					selectedVehicleId: widget.selectedVehicleId,
					onVehicleSelected: widget.onVehicleSelected,
					onVehicleTypeChanged: widget.onVehicleTypeChanged,
				),
      ],
    );
  }
}