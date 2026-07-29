/// Immutable domain models and seed data for the Prizma learning space.
///
/// The models deliberately use plain JSON-compatible values so the same data
/// can be restored from the original browser prototype as well as Flutter's
/// local preferences store.
library;

const Object _unset = Object();

/// Shared, user-visible configuration for the learning space.
abstract final class PrizmaConfig {
  static const int maxEnergy = 100;
  static const int xpPerLevel = 100;
  static const Set<int> sosRewards = <int>{10, 20, 30, 50};

  static const List<SubjectDefinition> subjects = <SubjectDefinition>[
    SubjectDefinition(
      id: 'math',
      name: 'Математика',
      icon: '∑',
      color: 'purple',
    ),
    SubjectDefinition(id: 'physics', name: 'Физика', icon: '⚛', color: 'cyan'),
    SubjectDefinition(
      id: 'biology',
      name: 'Биология',
      icon: '🧬',
      color: 'green',
    ),
    SubjectDefinition(
      id: 'chemistry',
      name: 'Химия',
      icon: '⚗',
      color: 'orange',
    ),
    SubjectDefinition(
      id: 'history',
      name: 'История',
      icon: '📜',
      color: 'yellow',
    ),
    SubjectDefinition(
      id: 'english',
      name: 'Английский',
      icon: '🌐',
      color: 'pink',
    ),
  ];

  static const List<RankDefinition> ranks = <RankDefinition>[
    RankDefinition(minScore: 0, name: 'Новичок'),
    RankDefinition(minScore: 50, name: 'Ученик'),
    RankDefinition(minScore: 150, name: 'Знаток'),
    RankDefinition(minScore: 350, name: 'Мастер'),
    RankDefinition(minScore: 700, name: 'Мудрец'),
    RankDefinition(minScore: 1500, name: 'Легенда'),
  ];

  static bool isKnownSubject(String subject) =>
      subjects.any((SubjectDefinition item) => item.id == subject);

  static SubjectDefinition subjectFor(String id) => subjects.firstWhere(
    (SubjectDefinition item) => item.id == id,
    orElse: () => subjects.first,
  );

  static RankDefinition rankForScore(int score) {
    RankDefinition selected = ranks.first;
    for (final RankDefinition rank in ranks) {
      if (score >= rank.minScore) {
        selected = rank;
      }
    }
    return selected;
  }
}

class SubjectDefinition {
  const SubjectDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String icon;
  final String color;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
  };
}

class RankDefinition {
  const RankDefinition({required this.minScore, required this.name});

  final int minScore;
  final String name;
}

class PrizmaUser {
  const PrizmaUser({
    required this.name,
    required this.avatar,
    required this.avatarImage,
    required this.level,
    required this.xp,
    required this.energy,
    required this.utilityScore,
    required this.lang,
    required this.helpGiven,
    required this.helpReceived,
    required this.requestsCreated,
  });

  factory PrizmaUser.initial() => const PrizmaUser(
    name: 'Player_01',
    avatar: 'P',
    avatarImage: null,
    level: 1,
    xp: 0,
    energy: PrizmaConfig.maxEnergy,
    utilityScore: 0,
    lang: 'ru',
    helpGiven: 0,
    helpReceived: 0,
    requestsCreated: 0,
  );

  factory PrizmaUser.fromJson(Map<String, dynamic> json) {
    final String name = _string(
      json['name'],
      fallback: 'Player_01',
      maxLength: 20,
    );
    final String rawAvatar = _string(
      json['avatar'],
      fallback: _initialsFor(name),
      maxLength: 2,
    );
    int level = _nonNegativeInt(json['level'], fallback: 1);
    int xp = _nonNegativeInt(json['xp']);
    while (xp >= PrizmaConfig.xpPerLevel) {
      xp -= PrizmaConfig.xpPerLevel;
      level += 1;
    }
    return PrizmaUser(
      name: name,
      avatar: rawAvatar.isEmpty ? _initialsFor(name) : rawAvatar.toUpperCase(),
      avatarImage: _nullableString(json['avatarImage']),
      level: level < 1 ? 1 : level,
      xp: xp,
      energy: _clamp(
        _nonNegativeInt(json['energy'], fallback: PrizmaConfig.maxEnergy),
        0,
        PrizmaConfig.maxEnergy,
      ),
      utilityScore: _nonNegativeInt(json['utilityScore']),
      lang: _string(json['lang'], fallback: 'ru', maxLength: 10),
      helpGiven: _nonNegativeInt(json['helpGiven']),
      helpReceived: _nonNegativeInt(json['helpReceived']),
      requestsCreated: _nonNegativeInt(json['requestsCreated']),
    );
  }

  final String name;
  final String avatar;
  final String? avatarImage;
  final int level;
  final int xp;
  final int energy;
  final int utilityScore;
  final String lang;
  final int helpGiven;
  final int helpReceived;
  final int requestsCreated;

  PrizmaUser copyWith({
    String? name,
    String? avatar,
    Object? avatarImage = _unset,
    int? level,
    int? xp,
    int? energy,
    int? utilityScore,
    String? lang,
    int? helpGiven,
    int? helpReceived,
    int? requestsCreated,
  }) => PrizmaUser(
    name: name ?? this.name,
    avatar: avatar ?? this.avatar,
    avatarImage: identical(avatarImage, _unset)
        ? this.avatarImage
        : avatarImage as String?,
    level: level ?? this.level,
    xp: xp ?? this.xp,
    energy: energy ?? this.energy,
    utilityScore: utilityScore ?? this.utilityScore,
    lang: lang ?? this.lang,
    helpGiven: helpGiven ?? this.helpGiven,
    helpReceived: helpReceived ?? this.helpReceived,
    requestsCreated: requestsCreated ?? this.requestsCreated,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'avatar': avatar,
    'avatarImage': avatarImage,
    'level': level,
    'xp': xp,
    'energy': energy,
    'utilityScore': utilityScore,
    'lang': lang,
    'helpGiven': helpGiven,
    'helpReceived': helpReceived,
    'requestsCreated': requestsCreated,
  };
}

class SosRequest {
  const SosRequest({
    required this.id,
    required this.subject,
    required this.question,
    required this.reward,
    required this.author,
    required this.authorAvatar,
    required this.authorAvatarImage,
    required this.createdAt,
    required this.resolved,
  });

  factory SosRequest.fromJson(Map<String, dynamic> json) => SosRequest(
    id: _string(json['id'], fallback: 'sos_unknown'),
    subject: _string(json['subject'], fallback: 'math'),
    question: _string(json['question']),
    // Historical demo data includes one 40-energy request. It remains
    // valid when loaded, even though people can only create the configured
    // reward values now.
    reward: _nonNegativeInt(json['reward']),
    author: _string(json['author'], fallback: 'Ученик Prizma', maxLength: 20),
    authorAvatar: _string(json['authorAvatar'], fallback: 'P', maxLength: 2),
    authorAvatarImage: _nullableString(json['authorAvatarImage']),
    createdAt: _dateTime(json['createdAt']),
    resolved: _bool(json['resolved']),
  );

  final String id;
  final String subject;
  final String question;
  final int reward;
  final String author;
  final String authorAvatar;
  final String? authorAvatarImage;
  final DateTime createdAt;
  final bool resolved;

  SosRequest copyWith({
    String? id,
    String? subject,
    String? question,
    int? reward,
    String? author,
    String? authorAvatar,
    Object? authorAvatarImage = _unset,
    DateTime? createdAt,
    bool? resolved,
  }) => SosRequest(
    id: id ?? this.id,
    subject: subject ?? this.subject,
    question: question ?? this.question,
    reward: reward ?? this.reward,
    author: author ?? this.author,
    authorAvatar: authorAvatar ?? this.authorAvatar,
    authorAvatarImage: identical(authorAvatarImage, _unset)
        ? this.authorAvatarImage
        : authorAvatarImage as String?,
    createdAt: createdAt ?? this.createdAt,
    resolved: resolved ?? this.resolved,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'subject': subject,
    'question': question,
    'reward': reward,
    'author': author,
    'authorAvatar': authorAvatar,
    'authorAvatarImage': authorAvatarImage,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'resolved': resolved,
  };
}

class GuildMember {
  const GuildMember({
    required this.id,
    required this.name,
    required this.status,
    required this.avatar,
    required this.score,
  });

  factory GuildMember.fromJson(Map<String, dynamic> json) {
    final String name = _string(
      json['name'],
      fallback: 'Участник',
      maxLength: 20,
    );
    return GuildMember(
      id: _string(json['id'], fallback: 'guild_unknown'),
      name: name,
      status: _guildStatus(json['status']),
      avatar: _string(
        json['avatar'],
        fallback: _initialsFor(name),
        maxLength: 2,
      ).toUpperCase(),
      score: _nonNegativeInt(json['score']),
    );
  }

  final String id;
  final String name;
  final String status;
  final String avatar;
  final int score;

  GuildMember copyWith({
    String? id,
    String? name,
    String? status,
    String? avatar,
    int? score,
  }) => GuildMember(
    id: id ?? this.id,
    name: name ?? this.name,
    status: status ?? this.status,
    avatar: avatar ?? this.avatar,
    score: score ?? this.score,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'status': status,
    'avatar': avatar,
    'score': score,
  };
}

class ChatMessage {
  const ChatMessage({
    required this.from,
    required this.text,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    from: _string(json['from'], fallback: 'Ученик Prizma', maxLength: 20),
    text: _string(json['text'], maxLength: 200),
    time: _dateTime(json['time']),
  );

  final String from;
  final String text;
  final DateTime time;

  /// Friendly aliases for code that describes a message by its author/date.
  String get author => from;
  DateTime get createdAt => time;

  ChatMessage copyWith({String? from, String? text, DateTime? time}) =>
      ChatMessage(
        from: from ?? this.from,
        text: text ?? this.text,
        time: time ?? this.time,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'from': from,
    'text': text,
    'time': time.millisecondsSinceEpoch,
  };
}

class UiPreferences {
  UiPreferences({
    required this.isDark,
    required this.reduceMotion,
    required List<String> completedTaskIds,
  }) : completedTaskIds = List<String>.unmodifiable(completedTaskIds);

  UiPreferences.defaults()
    : isDark = false,
      reduceMotion = false,
      completedTaskIds = const <String>[];

  factory UiPreferences.fromJson(Map<String, dynamic> json) {
    final Object? legacyTheme = json['theme'];
    final List<Object?> currentIds = _list(json['completedTaskIds']);
    final Iterable<Object?> rawIds = currentIds.isNotEmpty
        ? currentIds
        : _list(json['completedTasks']);
    return UiPreferences(
      isDark: json.containsKey('isDark')
          ? _bool(json['isDark'])
          : legacyTheme == 'dark',
      reduceMotion: _bool(json['reduceMotion']),
      completedTaskIds: rawIds
          .map((Object? value) => _string(value))
          .where((String value) => value.isNotEmpty)
          .toSet()
          .toList(growable: false),
    );
  }

  final bool isDark;
  final bool reduceMotion;
  final List<String> completedTaskIds;

  UiPreferences copyWith({
    bool? isDark,
    bool? reduceMotion,
    List<String>? completedTaskIds,
  }) => UiPreferences(
    isDark: isDark ?? this.isDark,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    completedTaskIds: completedTaskIds ?? this.completedTaskIds,
  );

  /// Includes the old web field names so preference migration is lossless.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'isDark': isDark,
    'theme': isDark ? 'dark' : 'light',
    'reduceMotion': reduceMotion,
    'completedTaskIds': completedTaskIds,
    'completedTasks': completedTaskIds,
  };
}

class PrizmaState {
  PrizmaState({
    required this.user,
    required List<SosRequest> sosList,
    required List<GuildMember> guild,
    required List<ChatMessage> chatMessages,
  }) : sosList = List<SosRequest>.unmodifiable(sosList),
       guild = List<GuildMember>.unmodifiable(guild),
       chatMessages = List<ChatMessage>.unmodifiable(chatMessages);

  factory PrizmaState.seeded({DateTime? now}) {
    final DateTime moment = now ?? DateTime.now();
    return PrizmaState(
      user: PrizmaUser.initial(),
      sosList: _seedSos(moment),
      guild: _seedGuild(),
      chatMessages: _seedChat(moment),
    );
  }

  factory PrizmaState.fromJson(Map<String, dynamic> json) {
    final Object? userValue = json['user'];
    final Map<String, dynamic> userJson = _map(userValue);
    final List<SosRequest> sos = _list(json['sosList'])
        .map(_map)
        .where((Map<String, dynamic> item) => item.isNotEmpty)
        .map(SosRequest.fromJson)
        .toList(growable: false);
    final List<GuildMember> members = _list(json['guild'])
        .map(_map)
        .where((Map<String, dynamic> item) => item.isNotEmpty)
        .map(GuildMember.fromJson)
        .toList(growable: false);
    final List<ChatMessage> messages = _list(json['chatMessages'])
        .map(_map)
        .where((Map<String, dynamic> item) => item.isNotEmpty)
        .map(ChatMessage.fromJson)
        .toList(growable: false);
    final DateTime now = DateTime.now();
    return PrizmaState(
      user: userJson.isEmpty
          ? PrizmaUser.initial()
          : PrizmaUser.fromJson(userJson),
      sosList: sos,
      guild: members.isEmpty ? _seedGuild() : members,
      chatMessages: messages.isEmpty ? _seedChat(now) : messages,
    );
  }

  final PrizmaUser user;
  final List<SosRequest> sosList;
  final List<GuildMember> guild;
  final List<ChatMessage> chatMessages;

  PrizmaState copyWith({
    PrizmaUser? user,
    List<SosRequest>? sosList,
    List<GuildMember>? guild,
    List<ChatMessage>? chatMessages,
  }) => PrizmaState(
    user: user ?? this.user,
    sosList: sosList ?? this.sosList,
    guild: guild ?? this.guild,
    chatMessages: chatMessages ?? this.chatMessages,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'user': user.toJson(),
    'sosList': sosList
        .map((SosRequest item) => item.toJson())
        .toList(growable: false),
    'guild': guild
        .map((GuildMember item) => item.toJson())
        .toList(growable: false),
    'chatMessages': chatMessages
        .map((ChatMessage item) => item.toJson())
        .toList(growable: false),
  };
}

class StoreResult {
  const StoreResult._({
    required this.isSuccess,
    required this.message,
    this.code,
  });

  const StoreResult.success(String message)
    : this._(isSuccess: true, message: message);

  const StoreResult.failure(String message, {String? code})
    : this._(isSuccess: false, message: message, code: code);

  final bool isSuccess;
  final String message;
  final String? code;

  /// Convenience alias for call-sites that prefer a shorter check.
  bool get success => isSuccess;
}

Map<String, dynamic> _map(Object? value) {
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

List<Object?> _list(Object? value) =>
    value is List ? List<Object?>.from(value) : const <Object?>[];

String _string(Object? value, {String fallback = '', int? maxLength}) {
  final String result = value is String
      ? value.trim()
      : value?.toString().trim() ?? fallback;
  final String nonEmpty = result.isEmpty ? fallback : result;
  return maxLength == null || nonEmpty.length <= maxLength
      ? nonEmpty
      : nonEmpty.substring(0, maxLength);
}

String? _nullableString(Object? value) {
  final String parsed = _string(value);
  return parsed.isEmpty ? null : parsed;
}

int _nonNegativeInt(Object? value, {int fallback = 0}) {
  final int parsed = switch (value) {
    int value => value,
    num value => value.round(),
    String value => int.tryParse(value.trim()) ?? fallback,
    _ => fallback,
  };
  return parsed < 0 ? 0 : parsed;
}

bool _bool(Object? value) => switch (value) {
  bool value => value,
  num value => value != 0,
  String value => value.trim().toLowerCase() == 'true' || value.trim() == '1',
  _ => false,
};

DateTime _dateTime(Object? value) {
  if (value is num) {
    final int raw = value.toInt();
    final int milliseconds = raw.abs() < 100000000000 ? raw * 1000 : raw;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
  if (value is String) {
    final int? numeric = int.tryParse(value);
    if (numeric != null) {
      return _dateTime(numeric);
    }
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

String _guildStatus(Object? value) {
  const Set<String> available = <String>{'online', 'away', 'offline'};
  final String status = _string(value, fallback: 'offline').toLowerCase();
  return available.contains(status) ? status : 'offline';
}

String _initialsFor(String name) {
  final String trimmed = name.trim();
  return trimmed.isEmpty ? 'P' : trimmed.substring(0, 1).toUpperCase();
}

int _clamp(int value, int min, int max) =>
    value < min ? min : (value > max ? max : value);

List<SosRequest> _seedSos(DateTime now) => <SosRequest>[
  SosRequest(
    id: 'sos_1',
    subject: 'math',
    question:
        'Не могу решить систему уравнений: 2x + 3y = 12 и x - y = 1. Объясните метод подстановки пожалуйста!',
    reward: 20,
    author: 'Mira_X',
    authorAvatar: 'M',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 10)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_2',
    subject: 'physics',
    question:
        'Какое количество теплоты требуется, чтобы нагреть 2 кг воды на 10 градусов ?',
    reward: 30,
    author: 'Dev_K',
    authorAvatar: 'D',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 7)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_3',
    subject: 'biology',
    question:
        'Чем отличается митоз от мейоза? Нужно краткое и понятное объяснение для завтрашнего теста.',
    reward: 30,
    author: 'Luna_7',
    authorAvatar: 'L',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 3)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_4',
    subject: 'chemistry',
    question:
        'Как уравнять реакцию: Fe + O₂ → Fe₂O₃? Никак не получается расставить коэффициенты.',
    reward: 20,
    author: 'Kai_Z',
    authorAvatar: 'K',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 15)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_5',
    subject: 'history',
    question:
        'Кто был первым правителем династии Романовых? И в каком году произошло его вошествие на престол?',
    reward: 20,
    author: 'Old_Soul',
    authorAvatar: 'O',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 6)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_6',
    subject: 'english',
    question:
        'Когда использовать Present Perfect, а когда Past Simple? Совсем запутался в этих временах.',
    reward: 30,
    author: 'Linguist_99',
    authorAvatar: 'L',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 2, seconds: 30)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_7',
    subject: 'math',
    question:
        'Как вычислить производную функции f(x) = x³ + 2x^2 + 5x? Помогите с алгоритмом.',
    reward: 50,
    author: 'Math_Geek',
    authorAvatar: 'G',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 12)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_8',
    subject: 'history',
    question:
        'Назовите основные причины Великой французской революции (краткими тезисами).',
    reward: 40,
    author: 'Historian_X',
    authorAvatar: 'H',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 9)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_9',
    subject: 'english',
    question:
        'Напишите 5 синонимов к слову "Beautiful" для эссе. Желательно уровня C1/C2.',
    reward: 20,
    author: 'Writer_B',
    authorAvatar: 'W',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 7, seconds: 30)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_10',
    subject: 'chemistry',
    question:
        'Что такое окислительно-восстановительные реакции? Буду очень благодарен за понятный пример.',
    reward: 50,
    author: 'Chem_Lover',
    authorAvatar: 'C',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 1, seconds: 30)),
    resolved: false,
  ),
  SosRequest(
    id: 'sos_11',
    subject: 'physics',
    question:
        'Угол падения луча на зеркало равен 35 градусов. Чему равен угол отражения ?. Заранее спасибо!',
    reward: 50,
    author: 'Quantum_D',
    authorAvatar: 'Q',
    authorAvatarImage: null,
    createdAt: now.subtract(const Duration(minutes: 4)),
    resolved: false,
  ),
];

List<GuildMember> _seedGuild() => const <GuildMember>[
  GuildMember(
    id: 'g1',
    name: 'Mira_X',
    status: 'online',
    avatar: 'M',
    score: 230,
  ),
  GuildMember(
    id: 'g2',
    name: 'Dev_K',
    status: 'online',
    avatar: 'D',
    score: 180,
  ),
  GuildMember(
    id: 'g3',
    name: 'Luna_7',
    status: 'away',
    avatar: 'L',
    score: 310,
  ),
  GuildMember(
    id: 'g4',
    name: 'Kai_Z',
    status: 'online',
    avatar: 'K',
    score: 95,
  ),
  GuildMember(
    id: 'g5',
    name: 'Nova_R',
    status: 'offline',
    avatar: 'N',
    score: 420,
  ),
  GuildMember(
    id: 'g6',
    name: 'Zen_X',
    status: 'online',
    avatar: 'Z',
    score: 140,
  ),
];

List<ChatMessage> _seedChat(DateTime now) => <ChatMessage>[
  ChatMessage(
    from: 'Mira_X',
    text: 'Кто-нибудь шарит в квадратных уравнениях?',
    time: now.subtract(const Duration(minutes: 5)),
  ),
  ChatMessage(
    from: 'Dev_K',
    text: 'Да, скидывай задачу',
    time: now.subtract(const Duration(minutes: 4)),
  ),
  ChatMessage(
    from: 'Luna_7',
    text: 'Я только что закинула SOS по биологии 👀',
    time: now.subtract(const Duration(minutes: 2)),
  ),
];
