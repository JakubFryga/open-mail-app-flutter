import 'package:flutter/material.dart';

import '../open_mail_app.dart';

/// A simple dialog for allowing the user to pick and open an email app
/// Use with [OpenMailApp.getMailApps] or [OpenMailApp.openMailApp] to get a
/// list of mail apps installed on the device.
class MailAppPickerDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The mail apps for the dialog to provide as options
  final List<MailApp> mailApps;

  /// Optional email content for composing an email
  final EmailContent? emailContent;

  /// Style for the dialog title text
  final TextStyle? titleTextStyle;

  /// Style for the app names in the dialog options
  final TextStyle? optionTextStyle;

  /// Padding for each option in the dialog
  final EdgeInsets? optionPadding;

  /// Background color for the dialog
  final Color? optionBackgroundColor;

  /// Background color for each option in the dialog
  final Color? optionBackgroundItemColor;

  /// Border radius for each option
  final BorderRadius? optionBorderRadius;

  /// Margin between options
  final EdgeInsets? optionMargin;

  /// Creates a new MailAppPickerDialog
  const MailAppPickerDialog({
    Key? key,
    this.title = 'Choose Mail App',
    required this.mailApps,
    this.emailContent,
    this.titleTextStyle,
    this.optionTextStyle,
    this.optionPadding,
    this.optionBackgroundColor,
    this.optionBorderRadius,
    this.optionBackgroundItemColor,
    this.optionMargin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle defaultTitleStyle = theme.textTheme.titleLarge ?? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
    final TextStyle defaultOptionStyle = theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 16);

    return SimpleDialog(
      backgroundColor: optionBackgroundColor ?? theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: optionBorderRadius ?? BorderRadius.circular(8.0),
      ),
      title: Text(
        title,
        style: titleTextStyle ?? defaultTitleStyle,
      ),
      children: <Widget>[
        for (var app in mailApps)
          Padding(
            padding: optionMargin ?? const EdgeInsets.symmetric(vertical: 2.0),
            child: Material(
              color: optionBackgroundItemColor ?? theme.cardColor,
              borderRadius: optionBorderRadius,
              child: InkWell(
                onTap: () {
                  final content = this.emailContent;
                  if (content != null) {
                    OpenMailApp.composeNewEmailInSpecificMailApp(
                      mailApp: app,
                      emailContent: content,
                    );
                  } else {
                    OpenMailApp.openSpecificMailApp(app);
                  }

                  Navigator.pop(context);
                },
                borderRadius: optionBorderRadius,
                child: Padding(
                  padding: optionPadding ?? const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Text(
                    app.name,
                    style: optionTextStyle ?? defaultOptionStyle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
