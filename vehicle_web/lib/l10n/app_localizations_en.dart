// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get admin => 'Admin';

  @override
  String get address => 'Address';

  @override
  String get appTitle => 'LynraFleet';

  @override
  String get atThisLocationNow => 'At this location: just now';

  @override
  String atThisLocationMinutes(Object minutes) {
    return 'At this location: $minutes min';
  }

  @override
  String atThisLocationHours(Object hours) {
    return 'At this location: $hours h';
  }

  @override
  String atThisLocationHoursMinutes(Object hours, Object minutes) {
    return 'At this location: $hours h $minutes min';
  }

  @override
  String get authenticationerror => 'Authentication error';

  @override
  String get battery => 'Battery';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get driverName => 'Driver Name';

  @override
  String get email => 'Email';

  @override
  String get lastUpdate => 'Last Update';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get parked => 'Parked';

  @override
  String get password => 'Password';

  @override
  String get plate => 'Plate';

  @override
  String get pleaseactivatewebaccess =>
      'Please activate web access from the LynraFleet mobile application.';

  @override
  String get signIn => 'Sign In';

  @override
  String get signintoyourfleetdashboard => 'Sign in to your fleet dashboard';

  @override
  String get unknownPlate => 'Unknown Plate';

  @override
  String get updated => 'Updated';

  @override
  String get vehicleFleet => 'Vehicle Fleet';

  @override
  String get vehicleWeb => 'Vehicle Web';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get webaccessisnotactive => 'Web access is not active.';
}
