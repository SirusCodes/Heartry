import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension URLLauncherExtension on BuildContext {
  /// Safely launches a URL string. If it fails, copies the link to the
  /// clipboard and shows a SnackBar.
  Future<void> safeLaunchURL(
    String url, {
    String? name,
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      final launched = await launchUrlString(url, mode: mode);
      if (!launched) {
        throw 'Could not launch';
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(this).showSnackBar(
          SnackBar(content: Text("Link to ${name ?? url} is copied")),
        );
      }
    }
  }
}
