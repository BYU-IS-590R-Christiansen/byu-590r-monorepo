import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKeyProductionIp = 'production_api_ip';

/// `--dart-define=API_BASE_URL=https://example.com/api/` skips dev default and release IP prompt.
const String _kApiUrlOverride = String.fromEnvironment('API_BASE_URL');

const String _kDevDefaultBaseUrl = 'http://localhost:8000/api/';

/// Resolves the Laravel API base URL (with trailing slash).
class ApiConfig {
  ApiConfig._();

  /// Laravel `php artisan serve` default port used for production IP URLs.
  static const int apiPort = 8000;

  /// True when `API_BASE_URL` was passed at compile time (skips dev default and release IP UI).
  static bool get hasCompileTimeBaseUrl => _kApiUrlOverride.isNotEmpty;

  static String? _cached;

  /// Clears in-memory cache (e.g. after user changes stored IP in release).
  static void clearCache() => _cached = null;

  static Future<String> getBaseUrl() async {
    if (_cached != null) return _cached!;

    if (_kApiUrlOverride.isNotEmpty) {
      _cached = _withTrailingSlash(_kApiUrlOverride);
      return _cached!;
    }

    if (!kReleaseMode) {
      _cached = _kDevDefaultBaseUrl;
      return _cached!;
    }

    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_prefsKeyProductionIp)?.trim();
    if (ip == null || ip.isEmpty) {
      throw StateError('Release build has no stored API IP; show server config first.');
    }
    _cached = 'http://$ip:${apiPort}/api/';
    return _cached!;
  }

  static Future<bool> hasStoredProductionIp() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_prefsKeyProductionIp)?.trim();
    return ip != null && ip.isNotEmpty;
  }

  static Future<void> saveProductionIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyProductionIp, ip.trim());
    clearCache();
  }

  static String _withTrailingSlash(String url) {
    if (url.endsWith('/')) return url;
    return '$url/';
  }
}
