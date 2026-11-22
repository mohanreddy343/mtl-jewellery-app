import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class SplashVideoService {
  static const _kVersion = 'splash_version';
  static const _kFile = 'splash_file';

  /// The downloaded video, or null if none is saved yet.
  static Future<File?> cachedFile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_kFile);
      if (path == null) return null;
      final f = File(path);
      return await f.exists() ? f : null;
    } catch (_) {
      return null;
    }
  }

  /// Checks the server and downloads a newer video. Never throws.
  static Future<void> refresh() async {
    try {
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/splash-config'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final url = (data['videoUrl'] ?? '').toString();
      final version = (data['version'] ?? '').toString();
      if (url.isEmpty || version.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_kVersion) == version && await cachedFile() != null) {
        return; // already up to date
      }

      final video =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 60));
      if (video.statusCode != 200) return;

      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/splash_$version.mp4');
      await file.writeAsBytes(video.bodyBytes);

      final oldPath = prefs.getString(_kFile);
      await prefs.setString(_kVersion, version);
      await prefs.setString(_kFile, file.path);
      if (oldPath != null && oldPath != file.path) {
        try {
          await File(oldPath).delete();
        } catch (_) {}
      }
    } catch (_) {}
  }
}