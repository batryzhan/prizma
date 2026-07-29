import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/prizma_models.dart';
import '../persistence/legacy_storage_stub.dart'
    if (dart.library.html) '../persistence/legacy_storage_web.dart'
    as legacy_storage;
import '../persistence/prizma_repository.dart';

typedef LegacyStorageReader = Future<String?> Function(String key);

const Object _unset = Object();

/// The local-first source of truth used by all Flutter screens.
///
/// Mutations update an immutable [PrizmaState], notify listeners immediately,
/// and write the resulting snapshot in the background. This keeps UI actions
/// responsive while preserving all original prototype mechanics.
class PrizmaStore extends ChangeNotifier {
  PrizmaStore({
    PrizmaRepository? repository,
    LegacyStorageReader? legacyStorageReader,
    DateTime Function()? clock,
    Duration energyInterval = const Duration(seconds: 15),
    bool enableEnergyTimer = true,
  }) : _repository = repository ?? SharedPreferencesPrizmaRepository(),
       _legacyStorageReader =
           legacyStorageReader ?? legacy_storage.readLegacyStorageValue,
       _clock = clock ?? DateTime.now,
       _timerInterval = energyInterval,
       _restoresEnergy = enableEnergyTimer {
    _state = PrizmaState.seeded(now: _clock());
  }

  static const String storageKey = 'prizma:flutter:v1';
  static const String uiPreferencesKey = 'prizma_ui_preferences';
  static const String _legacyImportMarkerKey =
      'prizma:flutter:v1:legacy-imported';
  static const List<String> _legacyStateKeys = <String>[
    'prizma:v2',
    'guildlearn_state',
  ];

  final PrizmaRepository _repository;
  final LegacyStorageReader _legacyStorageReader;
  final DateTime Function() _clock;
  final Duration _timerInterval;
  final bool _restoresEnergy;

  late PrizmaState _state;
  UiPreferences _preferences = UiPreferences.defaults();
  Future<void>? _initialization;
  Timer? _energyTimer;
  int _idSequence = 0;
  bool _disposed = false;

  bool isLoading = true;

  PrizmaState get state => _state;
  PrizmaUser get user => _state.user;
  List<SosRequest> get sosList => _state.sosList;
  List<GuildMember> get guild => _state.guild;
  List<ChatMessage> get chatMessages => _state.chatMessages;
  bool get isDark => _preferences.isDark;
  bool get reduceMotion => _preferences.reduceMotion;
  List<String> get completedTaskIds => _preferences.completedTaskIds;

  /// Exposed for settings views that need the complete immutable preference set.
  UiPreferences get preferences => _preferences;

  /// Restores the Flutter snapshot, then performs a single legacy web import
  /// only when there is no Flutter snapshot yet.
  Future<void> initialize() {
    if (_initialization != null) {
      return _initialization!;
    }
    _initialization = _initialize();
    return _initialization!;
  }

  Future<void> _initialize() async {
    try {
      final PrizmaState? savedState = await _readState(storageKey);
      final UiPreferences savedPreferences = await _readPreferences();
      _preferences = savedPreferences;

      if (savedState != null) {
        _state = savedState;
      } else {
        final PrizmaState? importedState = await _importLegacyStateOnce();
        _state = importedState ?? PrizmaState.seeded(now: _clock());
        await _persistState();
      }

      // The current schema writes the preference snapshot regardless of where
      // it came from, repairing missing fields from older web versions.
      await _persistPreferences();
    } catch (_) {
      // A corrupt or unavailable local store must never block the app. The
      // in-memory seed remains a safe, fully functional fallback.
      _state = PrizmaState.seeded(now: _clock());
      _preferences = UiPreferences.defaults();
    } finally {
      isLoading = false;
      if (!_disposed) {
        _startEnergyTimer();
        notifyListeners();
      }
    }
  }

  /// Creates a new SOS request and spends its selected energy reward.
  bool createSos({
    required String subject,
    required String question,
    required int reward,
  }) {
    final String normalizedSubject = subject.trim();
    final String normalizedQuestion = question.trim();
    if (!PrizmaConfig.isKnownSubject(normalizedSubject) ||
        normalizedQuestion.length < 10 ||
        normalizedQuestion.length > 500 ||
        !PrizmaConfig.sosRewards.contains(reward) ||
        user.energy < reward) {
      return false;
    }

    final SosRequest request = SosRequest(
      id: _nextId('sos'),
      subject: normalizedSubject,
      question: normalizedQuestion,
      reward: reward,
      author: user.name,
      authorAvatar: user.avatar,
      authorAvatarImage: user.avatarImage,
      createdAt: _clock(),
      resolved: false,
    );
    _state = _state.copyWith(
      user: user.copyWith(
        energy: _clamp(user.energy - reward, 0, PrizmaConfig.maxEnergy),
        requestsCreated: user.requestsCreated + 1,
      ),
      sosList: <SosRequest>[request, ...sosList],
    );
    _changed(saveState: true);
    return true;
  }

  /// Marks a peer request as resolved and gives the helper energy, XP, and
  /// utility score. A person can never help a request authored by themselves.
  StoreResult helpWithSos(String id) {
    final int index = sosList.indexWhere((SosRequest item) => item.id == id);
    if (index < 0) {
      return const StoreResult.failure('Запрос не найден.', code: 'not_found');
    }
    final SosRequest request = sosList[index];
    if (request.resolved) {
      return const StoreResult.failure(
        'Этот запрос уже решён.',
        code: 'already_resolved',
      );
    }
    if (request.author == user.name) {
      return const StoreResult.failure(
        'Нельзя помочь самому себе.',
        code: 'own_request',
      );
    }

    final int xpGain = (request.reward * 1.5).floor();
    int nextXp = user.xp + xpGain;
    int nextLevel = user.level;
    while (nextXp >= PrizmaConfig.xpPerLevel) {
      nextXp -= PrizmaConfig.xpPerLevel;
      nextLevel += 1;
    }

    final List<SosRequest> nextRequests = List<SosRequest>.of(sosList);
    nextRequests[index] = request.copyWith(resolved: true);
    _state = _state.copyWith(
      user: user.copyWith(
        energy: _clamp(user.energy + request.reward, 0, PrizmaConfig.maxEnergy),
        xp: nextXp,
        level: nextLevel,
        utilityScore: user.utilityScore + request.reward,
        helpGiven: user.helpGiven + 1,
      ),
      sosList: nextRequests,
    );
    _changed(saveState: true);
    return StoreResult.success(
      'Помощь оказана: +${request.reward} энергии и +$xpGain XP.',
    );
  }

  /// Deletes a request owned by the active user and returns its held energy.
  StoreResult deleteSos(String id) {
    final SosRequest? request = _findSos(id);
    if (request == null) {
      return const StoreResult.failure('Запрос не найден.', code: 'not_found');
    }
    if (request.author != user.name) {
      return const StoreResult.failure(
        'Можно удалить только свой запрос.',
        code: 'not_owner',
      );
    }

    _state = _state.copyWith(
      user: user.copyWith(
        energy: _clamp(user.energy + request.reward, 0, PrizmaConfig.maxEnergy),
      ),
      sosList: sosList
          .where((SosRequest item) => item.id != id)
          .toList(growable: false),
    );
    _changed(saveState: true);
    return const StoreResult.success('Запрос удалён, энергия возвращена.');
  }

  /// Updates profile details and keeps previously authored content recognisable.
  void updateProfile({
    String? name,
    String? avatar,
    Object? avatarImage = _unset,
    String? lang,
  }) {
    final String nextName = _bounded(name, fallback: user.name, maxLength: 20);
    final String nextAvatar = _bounded(
      avatar,
      fallback: user.avatar,
      maxLength: 2,
    ).toUpperCase();
    final String nextLang = _bounded(lang, fallback: user.lang, maxLength: 10);
    final String? nextAvatarImage = identical(avatarImage, _unset)
        ? user.avatarImage
        : _nullableBounded(avatarImage, maxLength: 2048);
    final bool hasNameChange = nextName != user.name;
    final bool hasAvatarChange =
        nextAvatar != user.avatar || nextAvatarImage != user.avatarImage;

    if (!hasNameChange && !hasAvatarChange && nextLang == user.lang) {
      return;
    }

    _state = _state.copyWith(
      user: user.copyWith(
        name: nextName,
        avatar: nextAvatar.isEmpty ? _initial(nextName) : nextAvatar,
        avatarImage: nextAvatarImage,
        lang: nextLang,
      ),
      sosList: sosList
          .map(
            (SosRequest item) => item.author == user.name
                ? item.copyWith(
                    author: nextName,
                    authorAvatar: nextAvatar.isEmpty
                        ? _initial(nextName)
                        : nextAvatar,
                    authorAvatarImage: nextAvatarImage,
                  )
                : item,
          )
          .toList(growable: false),
      chatMessages: chatMessages
          .map(
            (ChatMessage item) =>
                item.from == user.name ? item.copyWith(from: nextName) : item,
          )
          .toList(growable: false),
    );
    _changed(saveState: true);
  }

  /// Adds a local guild member. Invalid input is ignored rather than creating
  /// a partial record from a form field.
  void addGuildMember({
    required String name,
    int score = 100,
    String status = 'online',
    String? avatar,
  }) {
    final String normalizedName = _bounded(name, maxLength: 20);
    if (normalizedName.isEmpty) {
      return;
    }
    final String normalizedStatus = _validStatus(status)
        ? status.trim().toLowerCase()
        : 'online';
    final String normalizedAvatar = _bounded(
      avatar,
      fallback: _initial(normalizedName),
      maxLength: 2,
    ).toUpperCase();
    final GuildMember member = GuildMember(
      id: _nextId('guild'),
      name: normalizedName,
      status: normalizedStatus,
      avatar: normalizedAvatar.isEmpty
          ? _initial(normalizedName)
          : normalizedAvatar,
      score: _clamp(score, 0, 9999),
    );
    _state = _state.copyWith(guild: <GuildMember>[...guild, member]);
    _changed(saveState: true);
  }

  /// Sends a short local guild chat message. Returns false for blank messages.
  bool sendChatMessage(String text) {
    final String normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      return false;
    }
    final ChatMessage message = ChatMessage(
      from: user.name,
      text: normalizedText.length > 200
          ? normalizedText.substring(0, 200)
          : normalizedText,
      time: _clock(),
    );
    final List<ChatMessage> nextMessages = <ChatMessage>[
      ...chatMessages,
      message,
    ];
    _state = _state.copyWith(
      chatMessages: nextMessages.length <= 50
          ? nextMessages
          : nextMessages.sublist(nextMessages.length - 50),
    );
    _changed(saveState: true);
    return true;
  }

  void toggleTask(String id) {
    final String taskId = id.trim();
    if (taskId.isEmpty) {
      return;
    }
    final Set<String> completed = Set<String>.from(completedTaskIds);
    if (!completed.add(taskId)) {
      completed.remove(taskId);
    }
    _preferences = _preferences.copyWith(
      completedTaskIds: completed.toList(growable: false),
    );
    _changed(savePreferences: true);
  }

  void toggleTheme() {
    _preferences = _preferences.copyWith(isDark: !isDark);
    _changed(savePreferences: true);
  }

  void toggleReduceMotion() {
    _preferences = _preferences.copyWith(reduceMotion: !reduceMotion);
    _changed(savePreferences: true);
  }

  /// Returns a portable backup compatible with the previous web export shape.
  String exportJson() => jsonEncode(<String, dynamic>{
    'exportedAt': _clock().toIso8601String(),
    'app': 'Prizma',
    'state': state.toJson(),
    'preferences': _preferences.toJson(),
  });

  /// Starts the learner over without re-importing the old browser prototype.
  Future<void> resetLearningData() async {
    _state = PrizmaState.seeded(now: _clock());
    _preferences = UiPreferences.defaults();
    _changed(saveState: false, savePreferences: false);
    await Future.wait<void>(<Future<void>>[
      _writeStateSafely(),
      _writePreferencesSafely(),
    ]);
  }

  @override
  void dispose() {
    _disposed = true;
    _energyTimer?.cancel();
    _energyTimer = null;
    super.dispose();
  }

  Future<PrizmaState?> _readState(String key) async {
    try {
      final String? raw = await _repository.readString(key);
      return _decodeState(raw);
    } catch (_) {
      return null;
    }
  }

  Future<UiPreferences> _readPreferences() async {
    try {
      final String? raw = await _repository.readString(uiPreferencesKey);
      if (raw == null) {
        return UiPreferences.defaults();
      }
      final Object? decoded = jsonDecode(raw);
      final Map<String, dynamic> map = _jsonMap(decoded);
      return map.isEmpty
          ? UiPreferences.defaults()
          : UiPreferences.fromJson(map);
    } catch (_) {
      return UiPreferences.defaults();
    }
  }

  Future<PrizmaState?> _importLegacyStateOnce() async {
    try {
      if (await _repository.readString(_legacyImportMarkerKey) == 'true') {
        return null;
      }
      PrizmaState? imported;
      for (final String key in _legacyStateKeys) {
        final String? raw = await _legacyStorageReader(key);
        imported ??= _decodeState(raw);
        if (imported != null) {
          break;
        }
      }
      await _repository.writeString(_legacyImportMarkerKey, 'true');
      return imported;
    } catch (_) {
      // Even a localStorage security failure counts as an attempted migration:
      // do not make every launch repeat a known failing browser operation.
      await _writeLegacyMarkerSafely();
      return null;
    }
  }

  PrizmaState? _decodeState(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final Map<String, dynamic> map = _jsonMap(jsonDecode(raw));
      if (map['user'] is! Map) {
        return null;
      }
      return PrizmaState.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  void _startEnergyTimer() {
    if (!_restoresEnergy ||
        _energyTimer != null ||
        _timerInterval.inMicroseconds <= 0) {
      return;
    }
    _energyTimer = Timer.periodic(_timerInterval, (Timer _) {
      if (_disposed || user.energy >= PrizmaConfig.maxEnergy) {
        return;
      }
      _state = _state.copyWith(
        user: user.copyWith(
          energy: _clamp(user.energy + 1, 0, PrizmaConfig.maxEnergy),
        ),
      );
      _changed(saveState: true);
    });
  }

  void _changed({bool saveState = false, bool savePreferences = false}) {
    if (!_disposed) {
      notifyListeners();
    }
    if (saveState) {
      unawaited(_writeStateSafely());
    }
    if (savePreferences) {
      unawaited(_writePreferencesSafely());
    }
  }

  Future<void> _persistState() => _writeStateSafely();

  Future<void> _persistPreferences() => _writePreferencesSafely();

  Future<void> _writeStateSafely() async {
    try {
      await _repository.writeString(storageKey, jsonEncode(state.toJson()));
    } catch (_) {
      // Local persistence is a convenience; in-memory use continues safely.
    }
  }

  Future<void> _writePreferencesSafely() async {
    try {
      await _repository.writeString(
        uiPreferencesKey,
        jsonEncode(_preferences.toJson()),
      );
    } catch (_) {
      // See _writeStateSafely.
    }
  }

  Future<void> _writeLegacyMarkerSafely() async {
    try {
      await _repository.writeString(_legacyImportMarkerKey, 'true');
    } catch (_) {
      // Nothing else can be recovered here, and initialization still succeeds.
    }
  }

  SosRequest? _findSos(String id) {
    for (final SosRequest item in sosList) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  String _nextId(String prefix) {
    _idSequence += 1;
    return '${prefix}_${_clock().microsecondsSinceEpoch.toRadixString(36)}_${_idSequence.toRadixString(36)}';
  }
}

Map<String, dynamic> _jsonMap(Object? value) {
  if (value is! Map) {
    return const <String, dynamic>{};
  }
  return Map<String, dynamic>.fromEntries(
    value.entries.map(
      (MapEntry<dynamic, dynamic> entry) =>
          MapEntry<String, dynamic>(entry.key.toString(), entry.value),
    ),
  );
}

String _bounded(String? value, {String fallback = '', required int maxLength}) {
  final String source = value?.trim() ?? fallback;
  final String bounded = source.length > maxLength
      ? source.substring(0, maxLength)
      : source;
  return bounded.isEmpty ? fallback : bounded;
}

String? _nullableBounded(Object? value, {required int maxLength}) {
  if (value is! String) {
    return null;
  }
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed.length > maxLength ? trimmed.substring(0, maxLength) : trimmed;
}

String _initial(String name) =>
    name.trim().isEmpty ? 'P' : name.trim().substring(0, 1).toUpperCase();

bool _validStatus(String value) => const <String>{
  'online',
  'away',
  'offline',
}.contains(value.trim().toLowerCase());

int _clamp(int value, int min, int max) =>
    value < min ? min : (value > max ? max : value);
