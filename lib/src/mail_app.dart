import 'compose_data.dart';
import 'email_content.dart';
import 'open_mail_app_impl.dart';

/// Class representing an email application installed on the device
class MailApp {
  /// Name of the mail application
  final String name;

  /// iOS launch scheme URL for the application
  final String iosLaunchScheme;

  /// Data used for composing emails
  final ComposeData? composeData;

  const MailApp({
    required this.name,
    required this.iosLaunchScheme,
    this.composeData,
  });

  /// Creates a MailApp from JSON data
  factory MailApp.fromJson(Map<String, dynamic> json) => MailApp(
        name: json["name"],
        iosLaunchScheme: json["iosLaunchScheme"] ?? '',
        composeData: json["composeData"] ?? ComposeData(),
      );

  /// Converts the MailApp to a JSON representation
  Map<String, dynamic> toJson() => {
        "name": name,
        "iosLaunchScheme": iosLaunchScheme,
        "composeData": composeData,
      };

  /// Gets the launch scheme for composing a new email
  String? composeLaunchScheme(EmailContent content) {
    if (OpenMailAppImpl.platform.isAndroid) {
      return content.toJson();
    } else if (OpenMailAppImpl.platform.isIOS) {
      return composeData!.getComposeLaunchSchemeForIos(content);
    } else {
      throw Exception('Platform not supported');
    }
  }
}
