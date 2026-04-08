import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:byu_590r_flutter_app/app_theme.dart';
import 'package:byu_590r_flutter_app/core/api_config.dart';
import 'package:byu_590r_flutter_app/screens/server_config_screen.dart';
import 'package:byu_590r_flutter_app/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BYU 590R Library',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppEntry(),
    );
  }
}

/// Debug/profile: Android emulator → 10.0.2.2; iOS simulator & others → localhost. Release: API host IP unless
/// `--dart-define=API_BASE_URL=...` is set.
class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _releaseIpJustSaved = false;

  @override
  Widget build(BuildContext context) {
    if (!kReleaseMode || ApiConfig.hasCompileTimeBaseUrl) {
      return const WelcomeScreen();
    }
    if (_releaseIpJustSaved) {
      return const WelcomeScreen();
    }

    return FutureBuilder<bool>(
      future: ApiConfig.hasStoredProductionIp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return const WelcomeScreen();
        }
        return ServerConfigScreen(
          onSaved: () => setState(() => _releaseIpJustSaved = true),
        );
      },
    );
  }
}

