import 'package:flutter/material.dart';

import '../services/group_service.dart';

class CreateJoinFleetPage extends StatelessWidget {
  const CreateJoinFleetPage({
    super.key,
    required this.onFleetCreated,
  });

  final Future<void> Function() onFleetCreated;

  static const lynraBlue = Color(0xFF43BFF3);

  Future<void> _createFleet(BuildContext context) async {
    final controller = TextEditingController();

    final fleetName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF172033),
          title: const Text(
            'Create Fleet',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 20,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              labelText: 'Fleet Name',
              hintText: 'My Fleet',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              final name = value.trim();

              if (name.isNotEmpty) {
                Navigator.of(dialogContext).pop(name);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: lynraBlue,
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) return;

                Navigator.of(dialogContext).pop(name);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (fleetName == null || fleetName.isEmpty) {
      return;
    }

    try {
      await GroupService.createGroup(
        groupName: fleetName,
      );

      if (!context.mounted) return;

      await onFleetCreated();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fleet creation failed: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 560,
          child: Card(
            color: const Color(0xFF172033),
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 54,
                    color: lynraBlue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Set up your fleet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Create a new fleet or join an existing fleet '
                    'to start tracking vehicles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () => _createFleet(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: lynraBlue,
                        foregroundColor:
                            const Color(0xFF0F172A),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Create Fleet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Join Fleet sonraki adım.
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: lynraBlue,
                        side: const BorderSide(
                          color: lynraBlue,
                        ),
                      ),
                      icon: const Icon(
                        Icons.group_add_outlined,
                      ),
                      label: const Text(
                        'Join Fleet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'You can add more fleets later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}