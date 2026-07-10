// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get enterVehicleInfo => 'Enter Vehicle Info';

  @override
  String get vehicleName => 'Vehicle Name';

  @override
  String get plate => 'Plate';

  @override
  String get actionRequired => 'Action Required';

  @override
  String get activeWatchers => 'Active Watchers';

  @override
  String get addAdmin => 'Add admin';

  @override
  String get addMember => 'Add Vehicle';

  @override
  String get addressNotAvailable => 'Address not available';

  @override
  String get addressResolving => 'Resolving address...';

  @override
  String get adminName => 'Admin Name';

  @override
  String get alertBatteryLow => 'Battery Low';

  @override
  String get alertGpsOff => 'GPS Off';

  @override
  String get alertMovement => 'Movement Detected';

  @override
  String get alertPlaceEnter => 'Place Entered';

  @override
  String get alertPlaceExit => 'Place Exited';

  @override
  String get alerts => 'ALERTS';

  @override
  String get alertTitle => 'LynraFleet Alert';

  @override
  String get allPermissionsGranted => 'All Permissions Granted';

  @override
  String get allowOneMoreAdmin => 'Allow one more admin';

  @override
  String get allowOneMoreMember => 'Allow one more vehicle';

  @override
  String get aNewVer => 'A new version is available. Update now for the best experience.';

  @override
  String get appName => 'LynraFleet';

  @override
  String get approve => 'Approve';

  @override
  String get askTheGroup => 'Ask the group owner to upgrade LynraFleet.';

  @override
  String get askEverybody => 'Ask Everybody To Call Me';

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
  String get autoStart => 'Auto-Start';

  @override
  String get backgroundAccessInstructions => 'In the opening screen, please find \"LynraFleet Vehicle\" and turn the switch ON to ensure background reliability.\n\nThis window will close in 10 seconds...';

  @override
  String get backgroundPermissions => 'LynraFleet Vehicle requires these permissions to work in background.';

  @override
  String get batteryAlertlevel => 'Battery Alert Level';

  @override
  String get batteryLowAlert => 'Battery Low Alert';

  @override
  String get batteryOptimization => 'Battery Optimization';

  @override
  String get batteryOptimizationDescription => 'Set to \"No Restrictions\" for background operation';

  @override
  String get beingWatched => 'Being watched';

  @override
  String get callme => 'Call Me';

  @override
  String get callMeSent => 'Call Me Sent';

  @override
  String get callMeSentAll => 'Call Me sent to all requesters';

  @override
  String get cameraPermissionDesc => 'Used only when scanning a QR code.';

  @override
  String get cameraPermissionTitle => 'Camera permission';

  @override
  String get cancel => 'Cancel';

  @override
  String get chooseWhichNotif => 'Choose which notifications you want to receive from this vehicle.';

  @override
  String get cntinue => 'Continue';

  @override
  String get code => 'Code';

  @override
  String get confirm => 'Confirm';

  @override
  String get connectAMember => 'Connect A Vehicle';

  @override
  String get createNewGroup => 'Create a new fleet';

  @override
  String get createOrJoin => 'Create a new fleet or join an existing fleet';

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deletePlaceConfirmation => 'Delete this place?';

  @override
  String get disabledByMaster => 'Disabled by master';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get enableAutostart => 'Enable LynraFleet Vehicle in Autostart list';

  @override
  String get enteryourname => 'Enter Your Name (Other vehicle will see this name.)';

  @override
  String get enterMemberCode => 'Enter Vehicle Code';

  @override
  String get enterMemberName => 'Enter Vehicle Name';

  @override
  String get familyHome => 'Family,Home...';

  @override
  String get feedback => 'Feedback';

  @override
  String freeTrialDaysLeft(int days) {
    return 'Free trial: $days days left';
  }

  @override
  String get geofenceAlert => 'Geofence Alert';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get gpsOffAlert => 'GPS Off Alert';

  @override
  String get groupInfo => 'Fleet Information';

  @override
  String get granted => 'Granted';

  @override
  String get grantRequiredPermissions => 'Grant Required Permissions';

  @override
  String get group => 'Fleet';

  @override
  String get groupCode => 'Fleet Code';

  @override
  String get groupName => 'Fleet Name';

  @override
  String get groupQRCode => 'Fleet QR Code';

  @override
  String get hello => 'Hello';

  @override
  String hoursAgo(Object count) {
    return '$count hour ago';
  }

  @override
  String get iUnderstand => 'I UNDERSTAND';

  @override
  String get importantFor => 'Important for request visibility';

  @override
  String isWatchingYourLocation(Object name) {
    return '$name is watching your location.';
  }

  @override
  String get joinGroup => 'Join Fleet';

  @override
  String get joinInstantlyWithCamera => 'Join instantly with camera';

  @override
  String get joinRequest => 'Join Request';

  @override
  String get joinRequestCouldNotBeApproved => 'The join request could not be approved.';

  @override
  String get justNow => 'Just now';

  @override
  String get language => 'Language';

  @override
  String get lastKnownLocation => 'Last known location';

  @override
  String get later => 'LATER';

  @override
  String get lifeTimeAccess => 'Lifetime access';

  @override
  String get locationAccess => 'Location Access';

  @override
  String get locationAlwaysDescription => 'Set to \"Allow all the time\" for tracking';

  @override
  String get locationPermissionTitle => 'Location permission';

  @override
  String get locationPermissionDescription => 'LynraFleet uses your location only to calculate the distance between you and your paired members.\n\nYour location is not shared with members or other users.';

  @override
  String get locationPermissionDescForLocator => 'LynraFleet Vehicle requires location access so your trusted family can request your location when needed.\n\nBackground location access allows these requests to work even when the app is closed.\n\nYour location is only shared with trusted family members.';

  @override
  String get locatorGuide1 => 'To share your location, you must first join a Fleet.';

  @override
  String get locatorGuide2 => 'Share your Vehicle Code with your fleet administrator to receive a pairing request.';

  @override
  String get locatorGuide3 => 'You can find your Vehicle Code by opening the Fleet Information panel.';

  @override
  String get locatorGuide4 => 'Use the Call Me button whenever you want your Fleet administrators to contact you.';

  @override
  String get manufacturerSettings => 'MANUFACTURER SETTINGS';

  @override
  String get mapbutton => 'Map';

  @override
  String get master => 'Master';

  @override
  String get maxFamilyMembersReached => 'Maximum family vehicles reached';

  @override
  String get maximum5Places => 'Maximum 5 places allowed';

  @override
  String get member => 'Vehicle';

  @override
  String get members => 'Vehicles';

  @override
  String get memberAlreadyPaired => 'Vehicle Already Paired';

  @override
  String get memberCode => 'Vehicle Code';

  @override
  String get memberlimitreached => 'Vehicle Limit Reached';

  @override
  String get memberNotifications => 'Vehicle Notifications';

  @override
  String get memberNotFound => 'Vehicle Not Found';

  @override
  String get memberpaired => 'Vehicle paired successfully';

  @override
  String get memberQRCode => 'Vehicle QR Code';

  @override
  String get memberremoved => 'Vehicle Removed';

  @override
  String get memberSettings => 'Vehicle Settings';

  @override
  String get memoryLock => 'Memory Lock';

  @override
  String get memoryProtection => 'Memory Protection';

  @override
  String get memoryProtectionInstructions => 'To help LynraFleet Vehicle continue running in the background, please follow these steps:\n\n• Xiaomi: Open the Security app > Boost speed > Settings > App lock, then enable LynraFleet Member.\n• Other Android devices: Open the Recent Apps screen, tap or press and hold the LynraFleet Member app icon to open App Info.\nIf your device supports it, enable the option to keep the app in memory or keep it open.';

  @override
  String get memberReady => 'Vehicle Ready';

  @override
  String minutesAgo(Object count) {
    return '$count min ago';
  }

  @override
  String get missing => 'Missing';

  @override
  String get movementAlert => 'Movement Alert';

  @override
  String get movementDistance => 'Movement Distance';

  @override
  String multipleWatchersWatchingYourLoc(Object count, Object name) {
    return '$name and $count others are watching your location.';
  }

  @override
  String get name => 'name';

  @override
  String get notify => 'Notify';

  @override
  String get noActiveWatchers => 'No Active Watchers';

  @override
  String get noGroupYet => 'No fleet yet';

  @override
  String get noPairedMemberYet => 'No paired vehicles yet.';

  @override
  String get noPairedRequester => 'No Paired Admin';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettingsSaved => 'Notification settings saved';

  @override
  String get notifyBattery => 'Notify when battery is low';

  @override
  String get notifyGPS => 'Notify when GPS is turned off';

  @override
  String get notifyMovement => 'Notify on Movement';

  @override
  String get notifyPlaces => 'Notify when vehicle enters or leaves places';

  @override
  String get offlineNow => 'Just now';

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
  String get ok => 'OK';

  @override
  String get onlyTheMaster => 'Only the master can edit these settings.';

  @override
  String get otherApps => 'Other Apps';

  @override
  String get pairedMember => 'Paired Vehicle';

  @override
  String get pairedMembers => 'Paired Vehicles';

  @override
  String get pairingRejected => 'Pairing request rejected';

  @override
  String get pairingRequest => 'Pairing request';

  @override
  String get pairedRequesters => 'Paired Admins';

  @override
  String get pairingRequestPending => 'This vehicle already has a pending pairing request.';

  @override
  String get permissions => 'Permissions';

  @override
  String get permissionIntroTitle => 'Before we start';

  @override
  String get permissionIntroSubtitle => 'LynraFleet needs a few permissions to work safely and correctly.';

  @override
  String get permissionsRequired => 'Permissions Required';

  @override
  String get physicalActivity => 'Physical Activity';

  @override
  String get places => 'Places';

  @override
  String get placeName => 'Place name';

  @override
  String get placeNameHint => 'Home, School, Work...';

  @override
  String get premiumActive => 'Premium active';

  @override
  String get placeSaved => 'Place Saved';

  @override
  String get preventSystemKillDescription => 'Prevent the system from killing LynraFleet Vehicle';

  @override
  String get purchase => 'Purchase';

  @override
  String get quickGuide => 'Quick Guide';

  @override
  String get rateOnPlayStore => 'Rate on Play Store';

  @override
  String get receiveCallMe => 'Receive call me requests from this vehicle';

  @override
  String get receiveGPSalerts => 'Receive GPS off alerts';

  @override
  String get receivelowbattery => 'Receive low battery alerts';

  @override
  String get receiveMovement => 'Receive movement alerts';

  @override
  String get reject => 'Reject';

  @override
  String get rejected => 'REJECTED';

  @override
  String get remove => 'Remove';

  @override
  String get removeFromGroup => 'Remove from fleet';

  @override
  String get removeMember => 'Remove vehicle';

  @override
  String get requester => 'Admin';

  @override
  String get requesterGuide1 => 'Create a fleet or join an existing one.';

  @override
  String get requesterGuide2 => 'Invite vehicles by entering their Vehicle Code or scanning their QR code.';

  @override
  String get requesterGuide3 => 'Wait for fleets to approve your pairing request before requesting their location.';

  @override
  String get requesterGuide4 => 'Use Live Location and Call Me only when needed.';

  @override
  String get requesters => 'Admins';

  @override
  String get requiredForMotion => 'Required for motion detection';

  @override
  String get requesterName => 'Admin name';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get saveMemberLocation => 'Save vehicle location as place';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get scanMemberCodeWithCamera => 'Scan vehicle code with camera';

  @override
  String get scanQRCode => 'Scan QR code';

  @override
  String get scanTheMember => 'Scan the member QR code or enter its short code manually.';

  @override
  String secondsAgo(Object count) {
    return '$count sec ago';
  }

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get sendJoinRequest => 'Send Join Request';

  @override
  String get sendPairingRequest => 'Send Pairing Request';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get sixdigitcode => 'Enter 6-digit code';

  @override
  String get somePermissions => 'Some permissions are missing. Please open the permissions page and allow the required permissions.';

  @override
  String get speed => 'Speed';

  @override
  String get sva => 'Save';

  @override
  String get systemPermissions => 'SYSTEM PERMISSIONS';

  @override
  String get thismember => 'This Vehicle will be removed from your paired list.';

  @override
  String get title => 'LynraFleet';

  @override
  String get titleMember => 'LynraFleet Vehicle';

  @override
  String get trialExpired => 'Trial expired';

  @override
  String twoWatchersWatchingYourLocation(Object name1, Object name2) {
    return '$name1 and $name2 are watching your location.';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get update => 'UPDATE';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get upgradeToAddMoreMembers => 'Upgrade to add more vehicles.';

  @override
  String get upgradeToContinue => 'Upgrade to continue monitoring your fleet.';

  @override
  String get version => 'Version';

  @override
  String get viewOnly => 'View Only';

  @override
  String get waitingForApproval => 'Waiting for approval';

  @override
  String get waitingForLocator => 'Waiting for locator approval...';

  @override
  String get wantsYoutoCall => 'Wants You to Call';

  @override
  String watchingLocationSingle(Object name) {
    return '$name is watching your location.';
  }

  @override
  String watchingLocationDouble(Object name1, Object name2) {
    return '$name1 and $name2 are watching your location.';
  }

  @override
  String watchingLocationMultiple(Object count, Object name) {
    return '$name and $count others are watching your location.';
  }

  @override
  String get wellcome => 'Wellcome';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get yourname => 'Name';

  @override
  String get yourrequest => 'Your request has been sent to the fleet master.';
}
