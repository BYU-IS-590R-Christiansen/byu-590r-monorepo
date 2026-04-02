import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:byu_590r_flutter_app/core/api_config.dart';
import 'package:byu_590r_flutter_app/screens/register.dart';
import 'package:byu_590r_flutter_app/screens/server_config_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BYU 590R Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AppEntry(),
    );
  }
}

/// Debug/profile: [http://localhost:8000/api/]. Release: prompt once for API host IP, unless
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
      return const RegisterScreen();
    }
    if (_releaseIpJustSaved) {
      return const RegisterScreen();
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
          return const RegisterScreen();
        }
        return ServerConfigScreen(
          onSaved: () => setState(() => _releaseIpJustSaved = true),
        );
      },
    );
  }
}

