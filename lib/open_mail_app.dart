import 'package:flutter/widgets.dart';
import 'package:platform/platform.dart';

export 'src/models.dart';

import 'src/mail_app.dart';
import 'src/email_content.dart';
import 'src/open_mail_app_result.dart';
import 'src/open_mail_app_impl.dart';

/// Provides ability to query device for installed email apps and open those apps
class OpenMailApp {
  OpenMailApp._();

  /// Platform for testing purposes
  @visibleForTesting
  static Platform get platform => OpenMailAppImpl.platform;

  /// Platform for testing purposes
  @visibleForTesting
  static set platform(Platform value) => OpenMailAppImpl.setPlatform(value);

  /// Attempts to open an email app installed on the device.
  ///
  /// Android: Will open mail app or show native picker if multiple.
  ///
  /// iOS: Will open mail app if single installed mail app is found. If multiple
  /// are found will return a [OpenMailAppResult] that contains list of
  /// [MailApp]s. This can be used along with [MailAppPickerDialog] to allow
  /// the user to pick the mail app they want to open.
  ///
  /// Also see [openSpecificMailApp] and [getMailApps] for other use cases.
  ///
  /// Android: [nativePickerTitle] will set the title of the native picker.
  static Future<OpenMailAppResult> openMailApp({
    String nativePickerTitle = '',
  }) =>
      OpenMailAppImpl.openMailApp(nativePickerTitle: nativePickerTitle);

  /// Allows you to open a mail application installed on the user's device
  /// and start composing a new email with the contents in [emailContent].
  ///
  /// [EmailContent] Provides content for the email you're composing
  /// [String] (android) sets the title of the native picker.
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<OpenMailAppResult> composeNewEmailInMailApp({
    String nativePickerTitle = '',
    required EmailContent emailContent,
  }) =>
      OpenMailAppImpl.composeNewEmailInMailApp(
        nativePickerTitle: nativePickerTitle,
        emailContent: emailContent,
      );

  /// Allows you to compose a new email in the specified [mailApp] with the
  /// contents from [emailContent]
  ///
  /// [MailApp] (required) the mail app you wish to launch. Get it by calling [getMailApps]
  /// [EmailContent] provides content for the email you're composing
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<bool> composeNewEmailInSpecificMailApp({
    required MailApp mailApp,
    required EmailContent emailContent,
  }) =>
      OpenMailAppImpl.composeNewEmailInSpecificMailApp(
        mailApp: mailApp,
        emailContent: emailContent,
      );

  /// Attempts to open a specific email app installed on the device.
  /// Get a [MailApp] from calling [getMailApps]
  static Future<bool> openSpecificMailApp(MailApp mailApp) => OpenMailAppImpl.openSpecificMailApp(mailApp);

  /// Returns a list of installed email apps on the device
  ///
  /// iOS: [MailApp.iosLaunchScheme] will be populated
  static Future<List<MailApp>> getMailApps() => OpenMailAppImpl.getMailApps();

  /// Clears existing filter list and sets the filter list to the passed values.
  /// Filter list is case insensitive. Listed apps will be excluded from the results
  /// of `getMailApps` by name.
  ///
  /// Default filter list includes PayPal, since it implements the mailto: intent-filter
  /// on Android, but the intention of this plugin is to provide
  /// a utility for finding and opening apps dedicated to sending/receiving email.
  static void setFilterList(List<String> filterList) => OpenMailAppImpl.setFilterList(filterList);
}
