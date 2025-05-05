import 'mail_app.dart';

/// Result of calling [OpenMailApp.openMailApp]
///
/// [options] and [canOpen] are only populated and used on iOS
class OpenMailAppResult {
  /// Whether an email app was successfully opened
  final bool didOpen;

  /// List of available mail apps (iOS only)
  final List<MailApp> options;

  /// Whether there are mail apps available to open
  bool get canOpen => options.isNotEmpty;

  /// Creates a new OpenMailAppResult
  OpenMailAppResult({
    required this.didOpen,
    this.options = const <MailApp>[],
  });
}
