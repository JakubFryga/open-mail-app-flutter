import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';

void main() {
  runApp(const MyAppWithTheme());
}

class MyAppWithTheme extends StatefulWidget {
  const MyAppWithTheme({Key? key}) : super(key: key);

  @override
  State<MyAppWithTheme> createState() => _MyAppWithThemeState();
}

class _MyAppWithThemeState extends State<MyAppWithTheme> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Open Mail App Example",
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      darkTheme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MyApp(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class MyApp extends StatelessWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const MyApp({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Open Mail App Example"), actions: [IconButton(icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: () => toggleTheme(), tooltip: isDarkMode ? "Switch to light mode" : "Switch to dark mode")]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              child: const Text("Open Mail App"),
              onPressed: () async {
                // Android: Will open mail app or show native picker.
                // iOS: Will open mail app if single mail app found.
                var result = await OpenMailApp.openMailApp(nativePickerTitle: 'Select email app to open');

                // If no mail apps found, show error
                if (!result.didOpen && !result.canOpen) {
                  showNoMailAppsDialog(context);

                  // iOS: if multiple mail apps found, show dialog to select.
                  // There is no native intent/default app system in iOS so
                  // you have to do it yourself.
                } else if (!result.didOpen && result.canOpen) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return MailAppPickerDialog(mailApps: result.options);
                    },
                  );
                }
              },
            ),
            ElevatedButton(
              child: const Text('Open mail app, with email already composed'),
              onPressed: () async {
                EmailContent email = EmailContent(to: ['user@domain.com'], subject: 'Hello!', body: 'How are you doing?', cc: ['user2@domain.com', 'user3@domain.com'], bcc: ['boss@domain.com']);

                OpenMailAppResult result = await OpenMailApp.composeNewEmailInMailApp(nativePickerTitle: 'Select email app to compose', emailContent: email);
                if (!result.didOpen && !result.canOpen) {
                  showNoMailAppsDialog(context);
                } else if (!result.didOpen && result.canOpen) {
                  showDialog(context: context, builder: (_) => MailAppPickerDialog(mailApps: result.options, emailContent: email));
                }
              },
            ),
            ElevatedButton(
              child: const Text("Get Mail Apps"),
              onPressed: () async {
                var apps = await OpenMailApp.getMailApps();

                if (apps.isEmpty) {
                  showNoMailAppsDialog(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return MailAppPickerDialog(mailApps: apps, emailContent: EmailContent(to: ['user@domain.com'], subject: 'Hello!', body: 'How are you doing?', cc: ['user2@domain.com', 'user3@domain.com'], bcc: ['boss@domain.com']));
                    },
                  );
                }
              },
            ),
            // Sekcja informacyjna o aktualnym trybie
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).primaryColor.withOpacity(0.1)),
              child: Column(
                children: [
                  Text("Current theme: ${isDarkMode ? 'Dark Mode' : 'Light Mode'}", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text("Use the icon in the app bar to switch themes and test the library in different display modes.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
