import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:platform/platform.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'mail_app.dart';
import 'compose_data.dart';
import 'email_content.dart';
import 'open_mail_app_result.dart';

/// Provides ability to query device for installed email apps and open those
/// apps
class OpenMailAppImpl {
  OpenMailAppImpl._();

  // Usunięto adnotację @visibleForTesting, aby klasa OpenMailApp mogła uzyskać dostęp
  static Platform platform = LocalPlatform();

  // Dodane metody do zmiany platformy dla testów
  static void setPlatform(Platform value) {
    platform = value;
  }

  static const MethodChannel _channel = const MethodChannel('open_mail_app');
  static List<String> _filterList = <String>['paypal'];
  static List<MailApp> _supportedMailApps = [
    MailApp(
      name: 'Apple Mail',
      iosLaunchScheme: kLaunchSchemeAppleMail,
      composeData: ComposeData(
        base: 'mailto:',
      ),
    ),
    MailApp(
      name: 'Gmail',
      iosLaunchScheme: kLaunchSchemeGmail,
      composeData: ComposeData(
        base: kLaunchSchemeGmail + '/co',
      ),
    ),
    MailApp(
      name: 'Dispatch',
      iosLaunchScheme: kLaunchSchemeDispatch,
      composeData: ComposeData(
        base: kLaunchSchemeDispatch + '/compose',
      ),
    ),
    MailApp(
      name: 'Spark',
      iosLaunchScheme: kLaunchSchemeSpark,
      composeData: ComposeData(
        base: kLaunchSchemeSpark + 'compose',
        to: 'recipient',
      ),
    ),
    MailApp(
      name: 'Airmail',
      iosLaunchScheme: kLaunchSchemeAirmail,
      composeData: ComposeData(
        base: kLaunchSchemeAirmail + 'compose',
        body: 'plainBody',
      ),
    ),
    MailApp(
      name: 'Outlook',
      iosLaunchScheme: kLaunchSchemeOutlook,
      composeData: ComposeData(
        base: kLaunchSchemeOutlook + 'compose',
      ),
    ),
    MailApp(
      name: 'Yahoo',
      iosLaunchScheme: kLaunchSchemeYahoo,
      composeData: ComposeData(
        base: kLaunchSchemeYahoo + 'mail/compose',
      ),
    ),
    MailApp(
      name: 'Fastmail',
      iosLaunchScheme: kLaunchSchemeFastmail,
      composeData: ComposeData(
        base: kLaunchSchemeFastmail + 'mail/compose',
      ),
    ),
    MailApp(
      name: 'Superhuman',
      iosLaunchScheme: kLaunchSchemeSuperhuman,
      composeData: ComposeData(),
    ),
    MailApp(
      name: 'ProtonMail',
      iosLaunchScheme: kLaunchSchemeProtonmail,
      composeData: ComposeData(
        base: kLaunchSchemeProtonmail + 'mailto:',
      ),
    ),
  ];

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
  }) async {
    if (platform.isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'openMailApp',
            <String, dynamic>{'nativePickerTitle': nativePickerTitle},
          ) ??
          false;
      return OpenMailAppResult(didOpen: result);
    } else if (platform.isIOS) {
      final apps = await _getIosMailApps();
      if (apps.length == 1) {
        final result = await launchUrl(
          Uri.parse(apps.first.iosLaunchScheme),
          mode: LaunchMode.externalApplication,
        );
        return OpenMailAppResult(didOpen: result);
      } else {
        return OpenMailAppResult(didOpen: false, options: apps);
      }
    } else {
      throw Exception('Platform not supported');
    }
  }

  /// Allows you to open a mail application installed on the user's device
  /// and start composing a new email with the contents in [emailContent].
  ///
  /// [EmailContent] Provides content for  the email you're composing
  /// [String] (android) sets the title of the native picker.
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<OpenMailAppResult> composeNewEmailInMailApp({
    String nativePickerTitle = '',
    required EmailContent emailContent,
  }) async {
    if (platform.isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'composeNewEmailInMailApp',
            <String, String>{
              'nativePickerTitle': nativePickerTitle,
              'emailContent': emailContent.toJson(),
            },
          ) ??
          false;

      return OpenMailAppResult(didOpen: result);
    } else if (platform.isIOS) {
      List<MailApp> installedApps = await _getIosMailApps();
      if (installedApps.length == 1) {
        bool result = false;
        String? launchScheme = installedApps.first.composeLaunchScheme(emailContent);
        if (launchScheme != null) {
          result = await launchUrl(
            Uri.parse(launchScheme),
            mode: LaunchMode.externalApplication,
          );
        }
        return OpenMailAppResult(didOpen: result);
      } else {
        // This isn't ideal since you can't do anything with this...
        // Need to adapt the flow with that popup to also allow to pass emailcontent there.
        return OpenMailAppResult(didOpen: false, options: installedApps);
      }
    } else {
      throw Exception('Platform currently not supported.');
    }
  }

  /// Allows you to compose a new email in the specified [mailApp] witht the
  /// contents from [emailContent]
  ///
  /// [MailApp] (required) the maill app you wish to launch. Get it by calling [getMailApps]
  /// [EmailContent] provides content for the email you're composing
  /// throws an [Exception] if you're launching from an unsupported platform.
  static Future<bool> composeNewEmailInSpecificMailApp({
    required MailApp mailApp,
    required EmailContent emailContent,
  }) async {
    if (platform.isAndroid) {
      final result = await _channel.invokeMethod<bool>(
            'composeNewEmailInSpecificMailApp',
            <String, dynamic>{
              'name': mailApp.name,
              'emailContent': emailContent.toJson(),
            },
          ) ??
          false;
      return result;
    } else if (platform.isIOS) {
      String? launchScheme = mailApp.composeLaunchScheme(emailContent);
      if (launchScheme != null) {
        return await launchUrl(
          Uri.parse(launchScheme),
          mode: LaunchMode.externalApplication,
        );
      }

      return false;
    } else {
      throw Exception('Platform currently not supported');
    }
  }

  /// Attempts to open a specific email app installed on the device.
  /// Get a [MailApp] from calling [getMailApps]
  static Future<bool> openSpecificMailApp(MailApp mailApp) async {
    if (platform.isAndroid) {
      var result = await _channel.invokeMethod<bool>(
            'openSpecificMailApp',
            <String, dynamic>{'name': mailApp.name},
          ) ??
          false;
      return result;
    } else if (platform.isIOS) {
      return await launchUrl(
        Uri.parse(mailApp.iosLaunchScheme),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Platform not supported');
    }
  }

  /// Returns a list of installed email apps on the device
  ///
  /// iOS: [MailApp.iosLaunchScheme] will be populated
  static Future<List<MailApp>> getMailApps() async {
    if (platform.isAndroid) {
      return await _getAndroidMailApps();
    } else if (platform.isIOS) {
      return await _getIosMailApps();
    } else {
      throw Exception('Platform not supported');
    }
  }

  static Future<List<MailApp>> _getAndroidMailApps() async {
    var appsJson = await _channel.invokeMethod<String>('getMainApps');
    var apps = <MailApp>[];

    if (appsJson != null) {
      apps = (jsonDecode(appsJson) as Iterable).map((x) => MailApp.fromJson(x)).where((app) => !_filterList.contains(app.name.toLowerCase())).toList();
    }

    return apps;
  }

  static Future<List<MailApp>> _getIosMailApps() async {
    var installedApps = <MailApp>[];
    for (var app in _supportedMailApps) {
      if (await canLaunchUrl(Uri.parse(app.iosLaunchScheme)) && !_filterList.contains(app.name.toLowerCase())) {
        installedApps.add(app);
      }
    }
    return installedApps;
  }

  /// Clears existing filter list and sets the filter list to the passed values.
  /// Filter list is case insensitive. Listed apps will be excluded from the results
  /// of `getMailApps` by name.
  ///
  /// Default filter list includes PayPal, since it implements the mailto: intent-filter
  /// on Android, but the intention of this plugin is to provide
  /// a utility for finding and opening apps dedicated to sending/receiving email.
  static void setFilterList(List<String> filterList) {
    _filterList = filterList.map((e) => e.toLowerCase()).toList();
  }
}
