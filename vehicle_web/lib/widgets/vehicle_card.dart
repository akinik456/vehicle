import 'package:flutter/material.dart';
import '../utils/time_helper.dart';

class VehicleCard extends StatelessWidget {
  final String plate;
  final String driverName;
	final String address;
	final int battery;
  final bool isOnline;
  final int speed;
  final String lastUpdate;
	final int? offlineSince;
  final bool isSelected;
  final VoidCallback? onTap;
	final String locatorId;
	final String vehicleType;
	final ValueChanged<String> onVehicleTypeChanged;

  const VehicleCard({
    super.key,
    required this.plate,
    required this.driverName,
		required this.address,
		required this.battery,
    required this.isOnline,
    required this.speed,
    required this.lastUpdate,
		required this.offlineSince,
    this.isSelected = false,
		required this.locatorId,
		required this.vehicleType,
		required this.onVehicleTypeChanged,
    this.onTap,
  });
	
	IconData _vehicleIcon(String type) {
		switch (type) {
			case 'van':
				return Icons.airport_shuttle_rounded;
			case 'minibus':
				return Icons.directions_bus_filled_rounded;
			case 'truck':
				return Icons.local_shipping_rounded;
			case 'motorcycle':
				return Icons.two_wheeler_rounded;
			case 'car':
			default:
				return Icons.directions_car_rounded;
		}
	}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Material(
				elevation: isSelected ? 6 : 0,
				shadowColor: const Color(0xFF38BDF8).withOpacity(0.25),
				color: isSelected
						? const Color(0xFF1E3A5F)
						: const Color(0xFF273449),
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(14),
					side: BorderSide(
						color: isSelected
								? const Color(0xFF38BDF8)
								: Colors.transparent,
						width: 1.5,
					),
				),				
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
										tooltip: 'Vehicle type',
										padding: EdgeInsets.zero,
										icon: Icon(
											_vehicleIcon(vehicleType),
											color: const Color(0xFF38BDF8),
										),
										onSelected: onVehicleTypeChanged,
										itemBuilder: (context) => [
											PopupMenuItem(
												value: 'car',
												child: Row(
													children: [
														Icon(_vehicleIcon('car')),
														const SizedBox(width: 10),
														const Text('Car'),
													],
												),
											),
											PopupMenuItem(
												value: 'van',
												child: Row(
													children: [
														Icon(_vehicleIcon('van')),
														const SizedBox(width: 10),
														const Text('Van'),
													],
												),
											),
											PopupMenuItem(
												value: 'minibus',
												child: Row(
													children: [
														Icon(_vehicleIcon('minibus')),
														const SizedBox(width: 10),
														const Text('Minibus'),
													],
												),
											),
											PopupMenuItem(
												value: 'truck',
												child: Row(
													children: [
														Icon(_vehicleIcon('truck')),
														const SizedBox(width: 10),
														const Text('Truck'),
													],
												),
											),
											PopupMenuItem(
												value: 'motorcycle',
												child: Row(
													children: [
														Icon(_vehicleIcon('motorcycle')),
														const SizedBox(width: 10),
														const Text('Motorcycle'),
													],
												),
											),
										],
									),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driverName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
											if (address.isNotEmpty)
											Text(
												address,
												maxLines: 2,
												overflow: TextOverflow.ellipsis,
												style: const TextStyle(
													fontSize: 12,
													color: Colors.grey,
												),
											),
                      const SizedBox(height: 8),
                      Row(
												children: [
													Container(
														width: 8,
														height: 8,
														decoration: BoxDecoration(
															shape: BoxShape.circle,
															color: isOnline
																	? Colors.greenAccent
																	: Colors.redAccent,
														),
													),
													const SizedBox(width: 6),
													Text(
														isOnline
																? 'Online'
																: TimeHelper.formatOfflineDate(offlineSince),
														style: const TextStyle(
															fontSize: 12,
															color: Colors.white70,
														),
													),
													const Spacer(),
													Text(
														'🔋$battery%',
														style: const TextStyle(
															fontSize: 13,
															fontWeight: FontWeight.w600,
														),
													),
												],
											),
                      const SizedBox(height: 6),
                      Text(
                        lastUpdate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}