// The migration intentionally reads the prototype's existing browser key.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// Reads the prototype's raw localStorage entry on Flutter web only.
Future<String?> readLegacyStorageValue(String key) async {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}
