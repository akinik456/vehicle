import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../extensions/context_extensions.dart';

class DashboardHeader extends StatelessWidget {
  final String groupName;
	final String managerName;
	final String groupCode;
  final VoidCallback onEditGroupName;
	final VoidCallback onFleetManagement;
	
  const DashboardHeader({
    super.key,
    required this.groupName,
		required this.managerName,
		required this.groupCode,
    required this.onEditGroupName,
		required this.onFleetManagement,
  });

  Future<void> _logout() async {
		await FirebaseAuth.instance.signOut();
	}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF374151),
            width: 1,
          ),
        ),
      ),
			child: Stack(
				alignment: Alignment.center,
				children: [
					// ORTA - her zaman ekranın tam merkezi
					const Center(
						child: Text(
							'LynraFleet',
							style: TextStyle(
								fontSize: 22,
								fontWeight: FontWeight.w700,
								color: Color(0xFF38BDF8),
								letterSpacing: 0.5,
							),
						),
					),			
					Row(
						children: [
							Image.asset(
								'assets/images/fleet_icon.png',
								width: 42,
								height: 32,
								fit: BoxFit.contain,
							),
							const SizedBox(width: 12),
							InkWell(
								borderRadius: BorderRadius.circular(8),
								onTap: onFleetManagement,
								child: Column(
									mainAxisSize: MainAxisSize.min,
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											children: [
												Text(
													groupName,
													style: const TextStyle(
														fontSize: 24,
														fontWeight: FontWeight.bold,
													),
												),
												const SizedBox(width: 4),
												const Icon(
													Icons.keyboard_arrow_down_rounded,
													size: 20,
												),
											],
										),

										if (groupCode.isNotEmpty)
											Text(
												'Fleet Code: $groupCode',
												style: const TextStyle(
													fontSize: 12,
													color: Colors.white60,
													fontWeight: FontWeight.w500,
												),
											),
									],
								),
							),
							const SizedBox(width: 8),
							IconButton(
								onPressed: onEditGroupName,
								tooltip: 'Edit fleet name',
								icon: const Icon(
									Icons.edit_rounded,
									size: 18,
								),
							),
							const Spacer(),

							PopupMenuButton<String>(
								tooltip: '',
								onSelected: (value) {
									if (value == 'logout') {
										_logout();
									}
								},
								itemBuilder: (context) => [
									const PopupMenuItem<String>(
										value: 'logout',
										child: Row(
											children: [
												Icon(Icons.logout),
												SizedBox(width: 10),
												Text('Çıkış Yap'),
											],
										),
									),
								],
								child: Row(
									children: [
										const CircleAvatar(
											radius: 18,
											child: Icon(Icons.person),
										),
										const SizedBox(width: 12),
										Text(
											managerName,
											style: const TextStyle(fontSize: 16),
										),
										const SizedBox(width: 6),
										const Icon(
											Icons.keyboard_arrow_down,
											size: 20,
										),
									],
								),
							),
						],
					),
				],
			),			
    );
  }
}