import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'identity_service.dart';
import '../core/widgets/app_banner.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';

class LocatorNameEditor {
  LocatorNameEditor._();

  static Future<bool> edit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final currentName =
        await IdentityService.getLocatorName() ?? '';

    final currentPlate =
        await IdentityService.getLocatorPlate() ?? '';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final nameController =
            TextEditingController(text: currentName);

        final plateController =
            TextEditingController(text: currentPlate);

        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            l10n.enterVehicleInfo,
            style: AppFonts.title,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                maxLength: 20,
                autofocus: true,
                style: AppFonts.body,
                decoration: InputDecoration(
                  labelText: l10n.vehicleName,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: plateController,
                maxLength: 20,
                textCapitalization: TextCapitalization.characters,
                style: AppFonts.body,
                decoration: InputDecoration(
                  labelText: l10n.plate,
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'plate': plateController.text.trim().toUpperCase(),
                });
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return false;
    }

    final newName = result['name'] ?? '';
    final newPlate = result['plate'] ?? '';

    if (newName.isEmpty) {
      return false;
    }

    if (newName == currentName && newPlate == currentPlate) {
      return false;
    }

    final locatorId =
        await IdentityService.getLocatorId();

    if (locatorId == null || locatorId.isEmpty) {
      return false;
    }

    await FirebaseFirestore.instance
        .collection('locators')
        .doc(locatorId)
        .update({
      'locatorName': newName,
      'locatorPlate': newPlate,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await IdentityService.setLocatorName(newName);
    await IdentityService.setLocatorPlate(newPlate);

    if (!context.mounted) {
      return false;
    }

    AppBanner.success(
      context,
      l10n.saved,
    );

    return true;
  }
}