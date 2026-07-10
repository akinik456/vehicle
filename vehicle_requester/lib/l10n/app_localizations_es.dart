// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get enterVehicleInfo => 'Introduzca la Información del Vehículo';

  @override
  String get vehicleName => 'Nombre del vehículo';

  @override
  String get plate => 'Matrícula';

  @override
  String get actionRequired => 'Acción requerida';

  @override
  String get activeWatchers => 'Observadores activos';

  @override
  String get addAdmin => 'Agregar administrador';

  @override
  String get addMember => 'Agregar Vehículo';

  @override
  String get addressNotAvailable => 'Dirección no disponible';

  @override
  String get addressResolving => 'Resolviendo dirección...';

  @override
  String get adminName => 'Nombre del administrador';

  @override
  String get alertBatteryLow => 'Batería baja';

  @override
  String get alertGpsOff => 'GPS desactivado';

  @override
  String get alertMovement => 'Movimiento detectado';

  @override
  String get alertPlaceEnter => 'Entró en la zona';

  @override
  String get alertPlaceExit => 'Salió de la zona';

  @override
  String get alerts => 'ALERTAS';

  @override
  String get alertTitle => 'Alerta de LynraFleet';

  @override
  String get allPermissionsGranted => 'Todos los permisos concedidos';

  @override
  String get allowOneMoreAdmin => 'Permitir un administrador más';

  @override
  String get allowOneMoreMember => 'Permitir un Vehículo más';

  @override
  String get aNewVer => 'Hay una nueva versión disponible. Actualiza ahora para disfrutar de la mejor experiencia.';

  @override
  String get appName => 'LynraFleet';

  @override
  String get approve => 'Aprobar';

  @override
  String get askTheGroup => 'Pide al propietario del grupo que actualice LynraFleet.';

  @override
  String get askEverybody => 'Pedir a todos que me llamen';

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
  String get autoStart => 'Inicio automático';

  @override
  String get backgroundAccessInstructions => 'En la pantalla inicial, busque \"LynraFleet Vehicle\" y active el interruptor para garantizar la fiabilidad en segundo plano.\n\nEsta ventana se cerrará en 10 segundos...';

  @override
  String get backgroundPermissions => 'LynraFleet Vehicle requiere estos permisos para funcionar en segundo plano.';

  @override
  String get batteryAlertlevel => 'Nivel de alerta de batería';

  @override
  String get batteryLowAlert => 'Alerta de batería baja';

  @override
  String get batteryOptimization => 'Optimización de batería';

  @override
  String get batteryOptimizationDescription => 'Configurar como \"Sin restricciones\" para el funcionamiento en segundo plano';

  @override
  String get beingWatched => 'Te están observando';

  @override
  String get callme => 'Llámame';

  @override
  String get callMeSent => 'Llamada solicitada.';

  @override
  String get callMeSentAll => 'Solicitud de llamada enviada a todos los administradores';

  @override
  String get cameraPermissionDesc => 'Se utiliza solo al escanear un código QR.';

  @override
  String get cameraPermissionTitle => 'Permiso de cámara';

  @override
  String get cancel => 'Cancelar';

  @override
  String get chooseWhichNotif => 'Elija qué notificaciones desea recibir de este Vehículo.';

  @override
  String get cntinue => 'Continuar';

  @override
  String get code => 'Código';

  @override
  String get confirm => 'Confirmar';

  @override
  String get connectAMember => 'Conectar un Vehículo';

  @override
  String get createNewGroup => 'Crear un nuevo Flota';

  @override
  String get createOrJoin => 'Crear un nuevo Flota o unirse a un Flota existente';

  @override
  String daysAgo(Object count) {
    return 'hace $count días';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get deletePlaceConfirmation => 'Quieres eliminar este lugar?';

  @override
  String get disabledByMaster => 'Deshabilitado por el administrador';

  @override
  String get dismiss => 'Cerrar';

  @override
  String get enableAutostart => 'Habilitar LynraFleet Vehicle en la lista de inicio automático';

  @override
  String get enteryourname => 'Introduzca su nombre (otros Vehículo verán este nombre).';

  @override
  String get enterMemberCode => 'Introducir código del Vehículo';

  @override
  String get enterMemberName => 'Introducir nombre del Vehículo';

  @override
  String get familyHome => 'Familia, Hogar...';

  @override
  String get feedback => 'Comentarios';

  @override
  String freeTrialDaysLeft(int days) {
    return 'Prueba gratuita: quedan $days días';
  }

  @override
  String get geofenceAlert => 'Alerta de geovalla';

  @override
  String get goPremium => 'Hazte Premium';

  @override
  String get gpsOffAlert => 'Alerta de GPS desactivado';

  @override
  String get groupInfo => 'Información del Flota';

  @override
  String get granted => 'Concedido';

  @override
  String get grantRequiredPermissions => 'Conceder permisos requeridos';

  @override
  String get group => 'Flota';

  @override
  String get groupCode => 'Código del Flota';

  @override
  String get groupName => 'Nombre del Flota';

  @override
  String get groupQRCode => 'Código QR del Flota';

  @override
  String get hello => 'Hola';

  @override
  String hoursAgo(Object count) {
    return 'hace $count hora(s)';
  }

  @override
  String get iUnderstand => 'ENTIENDO';

  @override
  String get importantFor => 'Importante para la visibilidad de solicitudes';

  @override
  String isWatchingYourLocation(Object name) {
    return '$name está viendo tu ubicación.';
  }

  @override
  String get joinGroup => 'Unirse al Flota';

  @override
  String get joinInstantlyWithCamera => 'Unirse instantáneamente con la cámara';

  @override
  String get joinRequest => 'Solicitud de unión';

  @override
  String get joinRequestCouldNotBeApproved => 'No se pudo aprobar la solicitud para unirse.';

  @override
  String get justNow => 'Justo ahora';

  @override
  String get language => 'Idioma';

  @override
  String get lastKnownLocation => 'Última ubicación';

  @override
  String get later => 'MÁS TARDE';

  @override
  String get lifeTimeAccess => 'Acceso de por vida';

  @override
  String get locationAccess => 'Acceso a ubicación';

  @override
  String get locationAlwaysDescription => 'Configurar como \"Permitir siempre\" para el seguimiento';

  @override
  String get locationPermissionTitle => 'Permiso de ubicación';

  @override
  String get locationPermissionDescription => 'LynraFleet usa tu ubicación solo para calcular la distancia entre tú y los miembros vinculados.\n\nTu ubicación no se comparte con los miembros ni con otros usuarios.';

  @override
  String get locationPermissionDescForLocator => 'LynraFleet Vehicle necesita acceso a la ubicación para que tus familiares de confianza puedan solicitar tu ubicación cuando sea necesario.\n\nEl acceso a la ubicación en segundo plano permite que estas solicitudes funcionen incluso cuando la aplicación está cerrada.\n\nTu ubicación solo se comparte con familiares de confianza.';

  @override
  String get locatorGuide1 => 'Para compartir tu ubicación, primero debes unirte a un Flota.';

  @override
  String get locatorGuide2 => 'Comparte tu Código de Vehículo con el administrador de tu flota para recibir una solicitud de vinculación.';

  @override
  String get locatorGuide3 => 'Puedes encontrar tu Código de Vehículo abriendo el panel Información del Flota.';

  @override
  String get locatorGuide4 => 'Utiliza el botón Llámame cuando quieras que los administradores de tu flota se pongan en contacto contigo.';

  @override
  String get manufacturerSettings => 'AJUSTES DEL FABRICANTE';

  @override
  String get mapbutton => 'Mapa';

  @override
  String get master => 'Administrador principal';

  @override
  String get maxFamilyMembersReached => 'Se alcanzó el número máximo de miembros';

  @override
  String get maximum5Places => 'Máximo 5 lugares permitidos';

  @override
  String get member => 'Vehículo';

  @override
  String get members => 'Vehículos';

  @override
  String get memberAlreadyPaired => 'Este Vehículo ya está vinculado.';

  @override
  String get memberCode => 'Código del Vehículo';

  @override
  String get memberlimitreached => 'Límite de Vehículos alcanzado';

  @override
  String get memberNotifications => 'Notificaciones del Vehículo';

  @override
  String get memberNotFound => 'Vehículo no encontrado';

  @override
  String get memberpaired => 'Vehículo vinculado correctamente';

  @override
  String get memberQRCode => 'Código QR del Vehículo';

  @override
  String get memberremoved => 'Vehículo eliminado';

  @override
  String get memberSettings => 'Configuración del Vehículo';

  @override
  String get memoryLock => 'Bloqueo de memoria';

  @override
  String get memoryProtection => 'Protección de memoria';

  @override
  String get memoryProtectionInstructions => 'Para ayudar a que LynraFleet Vehicle siga funcionando en segundo plano, siga estos pasos:\n\n• Xiaomi: Abra la aplicación Seguridad > Aumentar velocidad > Ajustes > Bloqueo de aplicaciones y active LynraFleet Member.\n• Otros dispositivos Android: Abra la pantalla de Aplicaciones recientes y toque o mantenga presionado el icono de LynraFleet Member para abrir la información de la aplicación.\nSi su dispositivo lo permite, active la opción para mantener la aplicación en memoria o mantenerla abierta.';

  @override
  String get memberReady => 'Vehículo listo';

  @override
  String minutesAgo(Object count) {
    return 'hace $count min';
  }

  @override
  String get missing => 'Falta';

  @override
  String get movementAlert => 'Alerta de movimiento';

  @override
  String get movementDistance => 'Distancia de movimiento';

  @override
  String multipleWatchersWatchingYourLoc(Object count, Object name) {
    return '$name y $count personas más están viendo tu ubicación.';
  }

  @override
  String get name => 'nombre';

  @override
  String get notify => 'Notificar';

  @override
  String get noActiveWatchers => 'No hay observadores activos';

  @override
  String get noGroupYet => 'Aún no hay Flota';

  @override
  String get noPairedMemberYet => 'Aún no hay vehículos.';

  @override
  String get noPairedRequester => 'No hay administrador vinculado';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationSettingsSaved => 'Configuración de notificaciones guardada';

  @override
  String get notifyBattery => 'Notificar cuando la batería esté baja';

  @override
  String get notifyGPS => 'Notificar cuando el GPS se desactive';

  @override
  String get notifyMovement => 'Notificar cuando haya movimiento';

  @override
  String get notifyPlaces => 'Notificar cuando un vehículo entre o salga de lugares';

  @override
  String get offlineNow => 'Hace un momento';

  @override
  String offlineMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String offlineHours(Object hours) {
    return '$hours h';
  }

  @override
  String offlineHoursMinutes(Object hours, Object minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get ok => 'Aceptar';

  @override
  String get onlyTheMaster => 'Solo el administrador principal puede editar esta configuración.';

  @override
  String get otherApps => 'Otras aplicaciones';

  @override
  String get pairedMember => 'Vehículo vinculado';

  @override
  String get pairedMembers => 'Vehículos vinculados';

  @override
  String get pairingRejected => 'Solicitud de vinculación rechazada';

  @override
  String get pairingRequest => 'Solicitud de vinculación';

  @override
  String get pairedRequesters => 'Administradores vinculados';

  @override
  String get pairingRequestPending => 'Este vehículo ya tiene una solicitud de vinculación pendiente.';

  @override
  String get permissions => 'Permisos';

  @override
  String get permissionIntroTitle => 'Antes de comenzar';

  @override
  String get permissionIntroSubtitle => 'LynraFleet necesita algunos permisos para funcionar de forma segura y correcta.';

  @override
  String get permissionsRequired => 'Permisos requeridos';

  @override
  String get physicalActivity => 'Actividad física';

  @override
  String get places => 'Lugares';

  @override
  String get placeName => 'Nombre del lugar';

  @override
  String get placeNameHint => 'Casa, Escuela, Trabajo...';

  @override
  String get premiumActive => 'Premium activo';

  @override
  String get placeSaved => 'Lugar guardado';

  @override
  String get preventSystemKillDescription => 'Evitar que el sistema cierre LynraFleet Vehicle';

  @override
  String get purchase => 'Comprar';

  @override
  String get quickGuide => 'Guía rápida';

  @override
  String get rateOnPlayStore => 'Valorar en Play Store';

  @override
  String get receiveCallMe => 'Recibir solicitudes de llamada de este vehículo';

  @override
  String get receiveGPSalerts => 'Recibir alertas de GPS desactivado';

  @override
  String get receivelowbattery => 'Recibir alertas de batería baja';

  @override
  String get receiveMovement => 'Recibir alertas de movimiento';

  @override
  String get reject => 'Rechazar';

  @override
  String get rejected => 'RECHAZADO';

  @override
  String get remove => 'Eliminar';

  @override
  String get removeFromGroup => 'Eliminar del flota';

  @override
  String get removeMember => 'Eliminar vehículo';

  @override
  String get requester => 'Ejecutivo';

  @override
  String get requesterGuide1 => 'Crea un fluto o únete a uno existente.';

  @override
  String get requesterGuide2 => 'Invita a los vehículos introduciendo su Código de Vehículo o escaneando su código QR.';

  @override
  String get requesterGuide3 => 'Espera a que los vehículos aprueben tu solicitud de vinculación antes de solicitar su ubicación.';

  @override
  String get requesterGuide4 => 'Utiliza Ubicación en Vivo y Llámame solo cuando sea necesario.';

  @override
  String get requesters => 'Administradores';

  @override
  String get requiredForMotion => 'Requerido para detección de movimiento';

  @override
  String get requesterName => 'nombre de administrador';

  @override
  String get save => 'Guardar';

  @override
  String get saved => 'Guardado';

  @override
  String get saveMemberLocation => 'Guardar ubicación del vehículo como lugar';

  @override
  String get saveSettings => 'Guardar configuración';

  @override
  String get scanMemberCodeWithCamera => 'Escanear código del vehículo con la cámara';

  @override
  String get scanQRCode => 'Escanear código QR';

  @override
  String get scanTheMember => 'Escanee el código QR del vehículo o introduzca su código corto manualmente.';

  @override
  String secondsAgo(Object count) {
    return 'hace $count seg';
  }

  @override
  String get sendFeedback => 'Enviar comentarios';

  @override
  String get sendJoinRequest => 'Enviar solicitud para unirse';

  @override
  String get sendPairingRequest => 'Enviar solicitud de vinculación';

  @override
  String get settings => 'ajustes';

  @override
  String get settingsSaved => 'Configuración guardada';

  @override
  String get sixdigitcode => 'Introduzca un código de 6 dígitos';

  @override
  String get somePermissions => 'Faltan algunos permisos. Abra la página de permisos y conceda los permisos requeridos.';

  @override
  String get sva => 'Guardar';

  @override
  String get systemPermissions => 'PERMISOS DEL SISTEMA';

  @override
  String get thismember => 'Este vehículo será eliminado de su lista vinculada.';

  @override
  String get title => 'LynraFleet';

  @override
  String get titleMember => 'LynraFleet Vehicle';

  @override
  String get trialExpired => 'Período de prueba finalizado';

  @override
  String twoWatchersWatchingYourLocation(Object name1, Object name2) {
    return '$name1 y $name2 están viendo tu ubicación.';
  }

  @override
  String get unknown => 'Desconocido';

  @override
  String get update => 'ACTUALIZAR';

  @override
  String get updateAvailable => 'Actualización disponible';

  @override
  String get upgradeToAddMoreMembers => 'Actualiza tu plan para agregar más vehículos.';

  @override
  String get upgradeToContinue => 'Suscríbete a Premium para seguir realizando el seguimiento de tu flota.';

  @override
  String get version => 'Versión';

  @override
  String get viewOnly => 'Solo lectura';

  @override
  String get waitingForApproval => 'Esperando aprobación';

  @override
  String get waitingForLocator => 'Esperando aprobación del miembro...';

  @override
  String get wantsYoutoCall => 'Quiere que lo llame';

  @override
  String watchingLocationSingle(Object name) {
    return '$name está viendo tu ubicación.';
  }

  @override
  String watchingLocationDouble(Object name1, Object name2) {
    return '$name1 y $name2 están viendo tu ubicación.';
  }

  @override
  String watchingLocationMultiple(Object count, Object name) {
    return '$name y $count personas más están viendo tu ubicación.';
  }

  @override
  String get wellcome => 'Bienvenido';

  @override
  String get yesterday => 'Ayer';

  @override
  String get yourname => 'Nombre';

  @override
  String get yourrequest => 'Su solicitud ha sido enviada al administrador principal del flota.';
}
