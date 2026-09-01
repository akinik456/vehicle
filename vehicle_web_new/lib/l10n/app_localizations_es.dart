// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get admin => 'Administrador';

  @override
  String get address => 'Dirección';

  @override
  String get appTitle => 'LynraFleet';

  @override
  String get atThisLocationNow => 'Aquí desde hace: Hace un momento';

  @override
  String atThisLocationMinutes(Object minutes) {
    return 'Aquí desde hace: $minutes min';
  }

  @override
  String atThisLocationHours(Object hours) {
    return 'Aquí desde hace: $hours h';
  }

  @override
  String atThisLocationHoursMinutes(Object hours, Object minutes) {
    return 'Aquí desde hace: $hours h $minutes min';
  }

  @override
  String get authenticationerror => 'Error de autenticación';

  @override
  String get battery => 'Batería';

  @override
  String get dashboard => 'Panel';

  @override
  String get driverName => 'Nombre del conductor';

  @override
  String get email => 'Correo electrónico';

  @override
  String get lastUpdate => 'Última actualización';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get parked => 'Estacionado';

  @override
  String get password => 'Contraseña';

  @override
  String get plate => 'Matrícula';

  @override
  String get pleaseactivatewebaccess =>
      'Activa el acceso web desde la aplicación móvil LynraFleet.';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signintoyourfleetdashboard =>
      'Inicia sesión en el panel de tu flota';

  @override
  String get unknownPlate => 'Sin matrícula';

  @override
  String get updated => 'Actualizado';

  @override
  String get vehicleFleet => 'Flota de Vehículos';

  @override
  String get vehicleWeb => 'Web de Vehículos';

  @override
  String get vehicles => 'Vehículos';

  @override
  String get webaccessisnotactive => 'Web access is not active.';
}
