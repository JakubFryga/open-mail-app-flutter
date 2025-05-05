import 'dart:convert';
import 'open_mail_app_impl.dart';

/// Used to populate the precomposed emails
///
/// [to] List of [String] Addressees,
/// [cc] Carbon Copy [String] list
/// [bcc] Blind carbon copy [String] list
/// [subject] [String], getter returns [Uri.encodeComponent] from the set [String]
/// [body] [String], getter returns [Uri.encodeComponent] from the set [String]
class EmailContent {
  /// List of recipient email addresses
  final List<String> to;

  /// List of CC (Carbon Copy) email addresses
  final List<String> cc;

  /// List of BCC (Blind Carbon Copy) email addresses
  final List<String> bcc;

  /// Email subject (internal representation)
  final String _subject;

  /// Email subject, encoded for platform specific usage
  String get subject => OpenMailAppImpl.platform.isIOS ? Uri.encodeComponent(_subject) : _subject;

  /// Email body (internal representation)
  final String _body;

  /// Email body, encoded for platform specific usage
  String get body => OpenMailAppImpl.platform.isIOS ? Uri.encodeComponent(_body) : _body;

  /// Creates a new EmailContent object with optional fields
  EmailContent({
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    String? body,
  })  : this.to = to ?? const [],
        this.cc = cc ?? const [],
        this.bcc = bcc ?? const [],
        this._subject = subject ?? '',
        this._body = body ?? '';

  /// Converts the EmailContent to a JSON string
  String toJson() {
    final Map<String, dynamic> emailContent = {
      'to': this.to,
      'cc': this.cc,
      'bcc': this.bcc,
      'subject': this.subject,
      'body': this.body,
    };

    return json.encode(emailContent);
  }
}
