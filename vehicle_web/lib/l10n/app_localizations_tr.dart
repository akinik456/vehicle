// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get admin => 'Yönetici';

  @override
  String get address => 'Adres';

  @override
  String get appTitle => 'LynraFleet';

  @override
  String get atThisLocationNow => 'Bu konumda: Az önce';

  @override
  String atThisLocationMinutes(Object minutes) {
    return 'Bu konumda: $minutes dk';
  }

  @override
  String atThisLocationHours(Object hours) {
    return 'Bu konumda: $hours sa';
  }

  @override
  String atThisLocationHoursMinutes(Object hours, Object minutes) {
    return 'Bu konumda: $hours sa $minutes dk';
  }

  @override
  String get authenticationerror => 'Kimlik doğrulama hatası';

  @override
  String get battery => 'Pil';

  @override
  String get dashboard => 'Kontrol Paneli';

  @override
  String get driverName => 'Sürücü Adı';

  @override
  String get email => 'E-posta';

  @override
  String get lastUpdate => 'Son Güncelleme';

  @override
  String get login => 'Giriş';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get parked => 'Parkta';

  @override
  String get password => 'Şifre';

  @override
  String get plate => 'Plaka';

  @override
  String get pleaseactivatewebaccess =>
      'Lütfen web erişimini LynraFleet mobil uygulamasından etkinleştirin.';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get signintoyourfleetdashboard =>
      'Filo kontrol panelinizde oturum açın';

  @override
  String get unknownPlate => 'Plaka girilmemiş';

  @override
  String get updated => 'Güncellendi';

  @override
  String get vehicleFleet => 'Araç Filosu';

  @override
  String get vehicleWeb => 'Araç Web';

  @override
  String get vehicles => 'Araçlar';

  @override
  String get webaccessisnotactive => 'Web erişimi aktif değil.';
}
