import 'email_content.dart';

/// Class for handling email composition data formatting
class ComposeData {
  /// Base url scheme for composing
  String base;

  /// Parameter name for recipient
  String to;

  /// Parameter name for carbon copy
  String cc;

  /// Parameter name for blind carbon copy
  String bcc;

  /// Parameter name for email subject
  String subject;

  /// Parameter name for email body
  String body;

  /// Flag to track if composition has started
  bool composeStarted = false;

  /// Gets the appropriate separator for query string parameters
  String get qsPairSeparator {
    String separator = !composeStarted ? '?' : '&';
    composeStarted = true;
    return separator;
  }

  /// Creates a new ComposeData object with default or custom parameter names
  ComposeData({
    this.base = 'mailto:',
    this.to = 'to',
    this.cc = 'cc',
    this.bcc = 'bcc',
    this.subject = 'subject',
    this.body = 'body',
  });

  /// Generates a properly formatted launch scheme URL for iOS
  String getComposeLaunchSchemeForIos(EmailContent content) {
    String scheme = base;

    if (content.to.isNotEmpty) {
      scheme += '$qsPairSeparator$to=${content.to.join(',')}';
    }

    if (content.cc.isNotEmpty) {
      scheme += '$qsPairSeparator$cc=${content.cc.join(',')}';
    }

    if (content.bcc.isNotEmpty) {
      scheme += '$qsPairSeparator$bcc=${content.bcc.join(',')}';
    }

    if (content.subject.isNotEmpty) {
      scheme += '$qsPairSeparator$subject=${content.subject}';
    }

    if (content.body.isNotEmpty) {
      scheme += '$qsPairSeparator$body=${content.body}';
    }

    // Reset to make sure you can fetch this multiple times on the same instance.
    composeStarted = false;

    return scheme;
  }

  @override
  String toString() {
    return getComposeLaunchSchemeForIos(EmailContent());
  }
}
