import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'pages/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
	debugPrint(
		'VEHICLE WEB AUTH => '
		'${FirebaseAuth.instance.currentUser?.uid}',
	);

  runApp(const VehicleWebApp());
}

class VehicleWebApp extends StatelessWidget {
  const VehicleWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
			debugShowCheckedModeBanner: false,

			localizationsDelegates:
					AppLocalizations.localizationsDelegates,

			supportedLocales:
					AppLocalizations.supportedLocales,

			title: 'LynraFleet',

			theme: ThemeData.dark(),

			home: const AuthGate(),
		);
  }
}