import 'package:shared_preferences/shared_preferences.dart';

/// Small asynchronous boundary around local persistence.
///
/// Keeping this interface independent of SharedPreferences makes the store
/// deterministic in tests and keeps platform-specific migration concerns out
/// of the state layer.
abstract interface class PrizmaRepository {
  Future<String?> readString(String key);

  Future<void> writeString(String key, String value);

  Future<void> remove(String key);
}

class SharedPreferencesPrizmaRepository implements PrizmaRepository {
  SharedPreferencesPrizmaRepository({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;

  @override
  Future<String?> readString(String key) async {
    final SharedPreferences preferences = await _preferences;
    return preferences.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    final SharedPreferences preferences = await _preferences;
    await preferences.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final SharedPreferences preferences = await _preferences;
    await preferences.remove(key);
  }
}

/// Useful for focused tests and previews that should not touch device storage.
class MemoryPrizmaRepository implements PrizmaRepository {
  MemoryPrizmaRepository([Map<String, String>? initialValues])
    : values = Map<String, String>.from(
        initialValues ?? const <String, String>{},
      );

  final Map<String, String> values;

  @override
  Future<String?> readString(String key) async => values[key];

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}
