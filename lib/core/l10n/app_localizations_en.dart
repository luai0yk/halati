// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get required => 'Required';

  @override
  String get invalidEmail => 'Invalid Email';

  @override
  String get invalidPhoneNumber => 'Invalid Phone Number';

  @override
  String get settings => 'Settings';

  @override
  String get preferences => 'Preferences';

  @override
  String get viewAll => 'View All';

  @override
  String get ok => 'Ok';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get gallery => 'Gallery';

  @override
  String get file => 'File';

  @override
  String get camera => 'Camera';

  @override
  String get recentImages => 'Recent Images';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noRecentImages => 'No recent images';

  @override
  String get deletedFromRecent => 'Deleted from recent';

  @override
  String get clearRecentImagesTitle => 'Clear Recent Images?';

  @override
  String get clearAllMessage =>
      'Are you sure you want to clear all recent images?';

  @override
  String get clear => 'Clear';

  @override
  String get cancel => 'Cancel';

  @override
  String get generalSettings => 'Preferences';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get search => 'Search..';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentSearchTerms => 'Try different search terms';

  @override
  String get tryAdjustingSearch => 'Try adjusting search terms';

  @override
  String get noData => 'No data';

  @override
  String get noDataSubtitle => 'There is nothing to show here';

  @override
  String get selectColor => 'Select Color';

  @override
  String get customColor => 'Custom Color';

  @override
  String get recentColors => 'Recent Colors';

  @override
  String get invalidFormat => 'Invalid Format';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get setAsFavorite => 'Set as Favorite';

  @override
  String get removeFavorite => 'Remove Favorite';

  @override
  String get justNow => 'Just now';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get statuses => 'Statuses';

  @override
  String get saved => 'Saved';

  @override
  String get images => 'Images';

  @override
  String get videos => 'Videos';

  @override
  String get audio => 'Audio';

  @override
  String get refresh => 'Refresh';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get safPermissionTitle => 'WhatsApp Status Folder Access';

  @override
  String get safPermissionExplanation =>
      'To view and save WhatsApp statuses, please select the WhatsApp Statuses folder.';

  @override
  String get selectFolder => 'Select Folder';

  @override
  String get savedSuccessfully => 'Saved to Gallery';

  @override
  String get saveFailed => 'Failed to save media';

  @override
  String get noStatusesFound => 'No statuses available';

  @override
  String get noStatusesSubtitle =>
      'View statuses in WhatsApp first to make them appear here.';

  @override
  String get noSavedMedia => 'No saved media yet';

  @override
  String get share => 'Share';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deletedSuccessfully => 'Deleted successfully';

  @override
  String get error => 'Error';

  @override
  String get deleteSavedMedia => 'Delete Saved Media?';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this media file?';

  @override
  String get counterOf => 'of';

  @override
  String get mediaViewer => 'Media Viewer';

  @override
  String get failedToLoadMedia => 'Failed to load media';

  @override
  String get itemDeleted => 'Item deleted';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get playingAudio => 'Playing audio';

  @override
  String get paused => 'Paused';

  @override
  String get unableToPlayAudio => 'Unable to play audio format';

  @override
  String get aboutStatusSaver => 'About Status Saver';

  @override
  String get appName => 'Status Saver';

  @override
  String appVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get contactAndFeedback => 'Contact & Feedback';

  @override
  String get openSourceLicenses => 'Open-Source Licenses';

  @override
  String get couldNotOpenLink => 'Couldn\'t open link.';

  @override
  String get couldNotOpenEmail => 'No email app found.';

  @override
  String get contactFeedbackNotice =>
      'This message will be sent through your email app to our support team.';

  @override
  String get feedbackMessage => 'Message';

  @override
  String get feedbackHint => 'Write your feedback or message here...';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get retry => 'Retry';

  @override
  String licensesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count licenses',
      one: '1 license',
    );
    return '$_temp0';
  }

  @override
  String get noLicensesFound => 'No Licenses Found';

  @override
  String get noLicensesFoundSubtitle =>
      'There are no open-source licenses to display';

  @override
  String get failedToLoadLicenses => 'Couldn\'t load licenses.';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get whatsappBusiness => 'WhatsApp Business';

  @override
  String get business => 'Business';

  @override
  String get defaultWhatsApp => 'Default WhatsApp';

  @override
  String get selectDefaultWhatsApp => 'Select Default WhatsApp';

  @override
  String get defaultWhatsAppSubtitle => 'Set default app for Status Saver';

  @override
  String get safPermissionTitleBusiness => 'WhatsApp Business Status Access';

  @override
  String get safPermissionExplanationBusiness =>
      'To view and save WhatsApp Business statuses, please select the WhatsApp Business Statuses folder.';
}
