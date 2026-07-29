import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/prizma_app.dart';
import '../../app/prizma_theme.dart';
import '../../core/models/prizma_models.dart';
import '../../shared/widgets/prizma_widgets.dart';

/// A personal learning overview: experience, habits and small next actions.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _dailyTasks = <_FocusTask>[
    _FocusTask(
      id: 'plan_math',
      time: '09:30',
      title: 'Разобрать квадратные уравнения',
      subject: 'math',
      duration: '35 мин',
    ),
    _FocusTask(
      id: 'plan_physics',
      time: '13:00',
      title: 'Практика: законы отражения',
      subject: 'physics',
      duration: '25 мин',
    ),
    _FocusTask(
      id: 'plan_english',
      time: '18:30',
      title: 'Повторить Present Perfect',
      subject: 'english',
      duration: '20 мин',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    final user = store.user;
    final currentRank = PrizmaConfig.rankForScore(user.utilityScore);
    final rankIndex = PrizmaConfig.ranks.indexWhere(
      (rank) => rank.name == currentRank.name,
    );
    final nextRank = rankIndex >= 0 && rankIndex < PrizmaConfig.ranks.length - 1
        ? PrizmaConfig.ranks[rankIndex + 1]
        : null;
    final rankProgress = nextRank == null
        ? 1.0
        : ((user.utilityScore - currentRank.minScore) /
                  (nextRank.minScore - currentRank.minScore))
              .clamp(0.0, 1.0)
              .toDouble();
    final levelProgress = (user.xp / PrizmaConfig.xpPerLevel)
        .clamp(0.0, 1.0)
        .toDouble();
    final completed = _dailyTasks
        .where((task) => store.completedTaskIds.contains(task.id))
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
        final wide = constraints.maxWidth >= 980;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageIntro(
                  eyebrow: 'ЛИЧНЫЙ РОСТ',
                  title: 'Твоя траектория уже видна',
                  description:
                      'Здесь нет идеальных дней. Есть честный путь, который складывается из маленьких действий.',
                  action: FilledButton.tonalIcon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/profile'),
                    icon: const Icon(Icons.person_outline_rounded),
                    label: const Text('Профиль'),
                  ),
                ),
                const SizedBox(height: 26),
                _ProgressHero(
                  user: user,
                  rank: currentRank,
                  nextRank: nextRank,
                  levelProgress: levelProgress,
                  rankProgress: rankProgress,
                ),
                const SizedBox(height: 20),
                _MetricGrid(user: user),
                const SizedBox(height: 20),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 9,
                        child: _DailyFocusCard(
                          tasks: _dailyTasks,
                          completedIds: store.completedTaskIds,
                          onToggle: store.toggleTask,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(flex: 11, child: _AchievementsCard(user: user)),
                    ],
                  )
                else ...[
                  _DailyFocusCard(
                    tasks: _dailyTasks,
                    completedIds: store.completedTaskIds,
                    onToggle: store.toggleTask,
                  ),
                  const SizedBox(height: 20),
                  _AchievementsCard(user: user),
                ],
                const SizedBox(height: 20),
                _LearningCalendar(completed: completed),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The public-facing profile and the small set of profile details a learner
/// can edit locally.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showEditProfile(BuildContext context) async {
    final store = PrizmaScope.read(context);
    final nameController = TextEditingController(text: store.user.name);
    final avatarController = TextEditingController(text: store.user.avatar);
    final imageController = TextEditingController(
      text: store.user.avatarImage ?? '',
    );
    String language = store.user.lang;
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Редактировать профиль'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Эти данные останутся только на этом устройстве.',
                    style: TextStyle(
                      color: pageMuted(dialogContext),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    maxLength: 20,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      errorText: error,
                    ),
                    onChanged: (_) {
                      if (error != null) setDialogState(() => error = null);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: avatarController,
                    maxLength: 2,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Инициалы',
                      hintText: 'Например, А',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: imageController,
                    keyboardType: TextInputType.url,
                    maxLength: 2048,
                    decoration: const InputDecoration(
                      labelText: 'Ссылка на аватар (необязательно)',
                      hintText: 'https://…',
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: language,
                    decoration: const InputDecoration(
                      labelText: 'Язык интерфейса',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ru', child: Text('Русский')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => language = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton.icon(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  setDialogState(() => error = 'Имя не может быть пустым');
                  return;
                }
                store.updateProfile(
                  name: name,
                  avatar: avatarController.text.trim(),
                  avatarImage: imageController.text.trim().isEmpty
                      ? null
                      : imageController.text.trim(),
                  lang: language,
                );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Профиль сохранён')),
                );
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    avatarController.dispose();
    imageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    final user = store.user;
    final rank = PrizmaConfig.rankForScore(user.utilityScore);
    final requests = store.sosList
        .where((request) => request.author == user.name)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
        final wide = constraints.maxWidth >= 980;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageIntro(
                  eyebrow: 'ЛИЧНЫЙ РОСТ',
                  title: 'Твой профиль',
                  description:
                      'Управляй тем, как представиться гильдии — остальное покажет твой вклад.',
                  action: FilledButton.icon(
                    onPressed: () => _showEditProfile(context),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Редактировать'),
                  ),
                ),
                const SizedBox(height: 26),
                _ProfileHero(user: user, rank: rank),
                const SizedBox(height: 20),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
                        child: _ProfileAboutCard(user: user, rank: rank),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 12,
                        child: _MyRequestsCard(requests: requests),
                      ),
                    ],
                  )
                else ...[
                  _ProfileAboutCard(user: user, rank: rank),
                  const SizedBox(height: 20),
                  _MyRequestsCard(requests: requests),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Local appearance and data controls. Export never leaves the device unless
/// the learner explicitly copies the resulting JSON.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    final json = PrizmaScope.read(context).exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Копия данных готова'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'JSON уже скопирован в буфер обмена. Его можно сохранить в файл или вставить в заметки.',
              ),
              const SizedBox(height: 14),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: pageSubtleSurface(dialogContext),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    json,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Копия снова в буфере обмена')),
                );
              }
            },
            child: const Text('Скопировать ещё раз'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: PrizmaColors.danger,
        ),
        title: const Text('Сбросить учебные данные?'),
        content: const Text(
          'Будут удалены твои SOS-запросы, сообщения, прогресс и настройки на этом устройстве. Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: PrizmaColors.danger),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (shouldReset != true || !context.mounted) return;

    await PrizmaScope.read(context).resetLearningData();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Данные Prizma сброшены')));
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    final user = store.user;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
        final wide = constraints.maxWidth >= 900;
        final appearance = _SettingsCard(
          eyebrow: 'Внешний вид',
          title: 'Комфортный режим',
          icon: Icons.dark_mode_outlined,
          child: Column(
            children: [
              _SettingsSwitchRow(
                title: 'Тёмная тема',
                description: 'Снижает яркость интерфейса в вечернее время.',
                value: store.isDark,
                onChanged: (_) => store.toggleTheme(),
              ),
              const Divider(height: 26),
              _SettingsSwitchRow(
                title: 'Меньше анимаций',
                description:
                    'Убирает декоративные движения и плавные переходы.',
                value: store.reduceMotion,
                onChanged: (_) => store.toggleReduceMotion(),
              ),
            ],
          ),
        );
        final storage = _SettingsCard(
          eyebrow: 'Данные',
          title: 'Локальное хранилище',
          icon: Icons.shield_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: PrizmaColors.violetSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: PrizmaColors.violetDeep,
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Демо-данные Prizma живут только на этом устройстве. Их можно сохранить в копию или начать заново.',
                        style: TextStyle(fontSize: 11, height: 1.42),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _exportData(context),
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Скачать копию'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _resetData(context),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Сбросить данные'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PrizmaColors.danger,
                      side: const BorderSide(color: PrizmaColors.danger),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        final profile = _SettingsCard(
          eyebrow: 'Профиль',
          title: 'Текущий участник',
          icon: Icons.person_outline_rounded,
          child: Row(
            children: [
              UserAvatar(
                initials: user.avatar,
                imageUrl: user.avatarImage,
                size: 47,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.lang == 'en'
                          ? 'English interface'
                          : 'Интерфейс на русском',
                      style: TextStyle(color: pageMuted(context), fontSize: 11),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/profile'),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                label: const Text('Изменить'),
              ),
            ],
          ),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PageIntro(
                  eyebrow: 'ЛИЧНЫЙ РОСТ',
                  title: 'Настройки',
                  description:
                      'Все настройки хранятся только на этом устройстве. Их можно спокойно менять и сбрасывать.',
                ),
                const SizedBox(height: 26),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: appearance),
                      const SizedBox(width: 20),
                      Expanded(child: storage),
                    ],
                  )
                else ...[
                  appearance,
                  const SizedBox(height: 20),
                  storage,
                ],
                const SizedBox(height: 20),
                profile,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro({
    required this.eyebrow,
    required this.title,
    required this.description,
    this.action,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 22,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(eyebrow),
              const SizedBox(height: 7),
              Text(
                title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: textTheme.bodyLarge?.copyWith(
                  color: pageMuted(context),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        if (action case final Widget action) action,
      ],
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.user,
    required this.rank,
    required this.nextRank,
    required this.levelProgress,
    required this.rankProgress,
  });

  final PrizmaUser user;
  final RankDefinition rank;
  final RankDefinition? nextRank;
  final double levelProgress;
  final double rankProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: pageSurface(context),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: pageLine(context)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final identity = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(
                initials: user.avatar,
                imageUrl: user.avatarImage,
                background: PrizmaColors.violet,
                size: 72,
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Текущий ранг'),
                    const SizedBox(height: 5),
                    Text(
                      rank.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Уровень ${user.level} · ${user.utilityScore} utility points',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: pageMuted(context), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          );
          final metrics = SizedBox(
            width: wide ? 430 : double.infinity,
            child: Column(
              children: [
                _ProgressMetric(
                  label: 'Опыт',
                  value: '${user.xp} / ${PrizmaConfig.xpPerLevel} XP',
                  progress: levelProgress,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                _ProgressMetric(
                  label: 'Следующая грань',
                  value: nextRank?.name ?? 'Легенда',
                  progress: rankProgress,
                  color: PrizmaColors.cyan,
                ),
              ],
            ),
          );
          if (wide) {
            return Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: 30),
                metrics,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [identity, const SizedBox(height: 22), metrics],
          );
        },
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: pageMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ProgressLine(value: progress, color: color),
    ],
  );
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.user});

  final PrizmaUser user;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = constraints.maxWidth >= 1020
          ? 4
          : constraints.maxWidth >= 600
          ? 2
          : 1;
      return GridView.count(
        crossAxisCount: count,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 164,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MetricCard(
            icon: Icons.favorite_border_rounded,
            iconColor: PrizmaColors.pink,
            iconBackground: PrizmaColors.pinkSoft,
            label: 'Помощь другим',
            value: '${user.helpGiven}',
            caption: 'закрытых вопросов',
          ),
          MetricCard(
            icon: Icons.forum_outlined,
            iconColor: PrizmaColors.violetDeep,
            iconBackground: PrizmaColors.violetSoft,
            label: 'Мои SOS',
            value: '${user.requestsCreated}',
            caption: 'созданных запросов',
          ),
          MetricCard(
            icon: Icons.bolt_rounded,
            iconColor: PrizmaColors.orange,
            iconBackground: PrizmaColors.orangeSoft,
            label: 'Энергия',
            value: '${user.energy}',
            caption: 'на новые действия',
          ),
          const MetricCard(
            icon: Icons.local_fire_department_outlined,
            iconColor: PrizmaColors.orange,
            iconBackground: PrizmaColors.orangeSoft,
            label: 'Серия',
            value: '7 дней',
            caption: 'в учебном ритме',
          ),
        ],
      );
    },
  );
}

class _DailyFocusCard extends StatelessWidget {
  const _DailyFocusCard({
    required this.tasks,
    required this.completedIds,
    required this.onToggle,
  });

  final List<_FocusTask> tasks;
  final List<String> completedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final done = tasks.where((task) => completedIds.contains(task.id)).length;
    return PrizmaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: 'Сегодня',
            title: 'Маленький план',
            description: '$done из ${tasks.length} задач отмечено.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: PrizmaColors.violetSoft,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$done/${tasks.length}',
                style: const TextStyle(
                  color: PrizmaColors.violetDeep,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 17),
          for (final task in tasks) ...[
            _FocusTaskRow(
              task: task,
              done: completedIds.contains(task.id),
              onTap: () => onToggle(task.id),
            ),
            if (task != tasks.last) const SizedBox(height: 8),
          ],
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/sos'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить фокус'),
          ),
        ],
      ),
    );
  }
}

class _FocusTaskRow extends StatelessWidget {
  const _FocusTaskRow({
    required this.task,
    required this.done,
    required this.onTap,
  });

  final _FocusTask task;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: done ? PrizmaColors.greenSoft : pageSubtleSurface(context),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? PrizmaColors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: done
                    ? null
                    : Border.all(color: pageLine(context), width: 1.5),
              ),
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${task.time} · ${task.duration}',
                    style: TextStyle(color: pageMuted(context), fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SubjectChip(task.subject, compact: true),
          ],
        ),
      ),
    ),
  );
}

class _AchievementsCard extends StatelessWidget {
  const _AchievementsCard({required this.user});

  final PrizmaUser user;

  @override
  Widget build(BuildContext context) {
    final achievements = <_Achievement>[
      _Achievement(
        icon: Icons.volunteer_activism_outlined,
        tone: PrizmaColors.pink,
        title: 'Первый отклик',
        description: 'Помоги с одним SOS-запросом.',
        current: user.helpGiven,
        goal: 1,
      ),
      _Achievement(
        icon: Icons.forum_outlined,
        tone: PrizmaColors.violet,
        title: 'Смелый вопрос',
        description: 'Создай свой первый SOS.',
        current: user.requestsCreated,
        goal: 1,
      ),
      const _Achievement(
        icon: Icons.local_fire_department_outlined,
        tone: PrizmaColors.orange,
        title: 'Ритм недели',
        description: 'Сохраняй учебный темп 7 дней.',
        current: 7,
        goal: 7,
      ),
      _Achievement(
        icon: Icons.auto_awesome_outlined,
        tone: PrizmaColors.cyan,
        title: 'Знаток',
        description: 'Набери 150 utility points.',
        current: user.utilityScore,
        goal: 150,
      ),
    ];
    return PrizmaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Коллекция',
            title: 'Моменты роста',
            description: 'Не бейджи ради бейджей — следы твоего пути.',
          ),
          const SizedBox(height: 17),
          for (final achievement in achievements) ...[
            _AchievementRow(achievement: achievement),
            if (achievement != achievements.last) const Divider(height: 19),
          ],
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement});

  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.current >= achievement.goal;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: achievement.tone.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(achievement.icon, size: 19, color: achievement.tone),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                achievement.description,
                style: TextStyle(
                  color: pageMuted(context),
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unlocked
                    ? 'Получено'
                    : '${achievement.current} / ${achievement.goal}',
                style: TextStyle(
                  color: unlocked ? PrizmaColors.green : pageMuted(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Icon(
          unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
          size: 18,
          color: unlocked ? PrizmaColors.green : pageMuted(context),
        ),
      ],
    );
  }
}

class _LearningCalendar extends StatelessWidget {
  const _LearningCalendar({required this.completed});

  final int completed;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List<int>.generate(28, (index) => index + 1);
    final accentDays = <int>{3, 4, 7, 11, 14, 18, 20, 23, 26};
    return PrizmaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: 'Учебный след',
            title: _monthTitle(now.month),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _LegendDot(color: PrizmaColors.violet),
                const SizedBox(width: 4),
                Text(
                  'Фокус',
                  style: TextStyle(color: pageMuted(context), fontSize: 9),
                ),
                const SizedBox(width: 10),
                const _LegendDot(color: PrizmaColors.cyan),
                const SizedBox(width: 4),
                Text(
                  'Помощь',
                  style: TextStyle(color: pageMuted(context), fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 7,
            crossAxisSpacing: 7,
            children: [
              for (final label in const [
                'Пн',
                'Вт',
                'Ср',
                'Чт',
                'Пт',
                'Сб',
                'Вс',
              ])
                Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: pageMuted(context),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              for (final day in days)
                _CalendarDay(
                  day: day,
                  isToday: day == now.day,
                  active:
                      accentDays.contains(day) ||
                      (completed > 0 && day == now.day),
                  secondary: day == 7 || day == 20,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.isToday,
    required this.active,
    required this.secondary,
  });

  final int day;
  final bool isToday;
  final bool active;
  final bool secondary;

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active
          ? (secondary ? PrizmaColors.cyanSoft : PrizmaColors.violetSoft)
          : pageSubtleSurface(context),
      borderRadius: BorderRadius.circular(9),
      border: isToday
          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.4)
          : null,
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Text(
          '$day',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        if (active)
          Positioned(
            bottom: 4,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: secondary ? PrizmaColors.cyan : PrizmaColors.violet,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    ),
  );
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user, required this.rank});

  final PrizmaUser user;
  final RankDefinition rank;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          height: 226,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF735AF0), Color(0xFF409ABA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          right: -22,
          top: -36,
          child: Container(
            width: 184,
            height: 184,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 84,
          bottom: -38,
          child: Transform.rotate(
            angle: .7,
            child: Container(
              width: 93,
              height: 93,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: .22),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 620;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          UserAvatar(
                            initials: user.avatar,
                            imageUrl: user.avatarImage,
                            size: compact ? 67 : 82,
                            background: const Color(0xFF4A388F),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'УЧАСТНИК PRIZMA',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .78),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${rank.name} · уровень ${user.level} · с нами с этой недели',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .85),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 7,
                      children: const [
                        _ProfilePill(
                          icon: Icons.shield_outlined,
                          label: 'Уважительный участник',
                        ),
                        _ProfilePill(
                          icon: Icons.auto_awesome_outlined,
                          label: 'В своём ритме',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ProfileAboutCard extends StatelessWidget {
  const _ProfileAboutCard({required this.user, required this.rank});

  final PrizmaUser user;
  final RankDefinition rank;

  @override
  Widget build(BuildContext context) => PrizmaCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          eyebrow: 'О себе',
          title: 'Твоя учебная карточка',
          description:
              'Каждая цифра — не оценка, а отражение того, что ты уже сделал.',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: PrizmaColors.violetSoft,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: PrizmaColors.violet,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UTILITY SCORE',
                      style: TextStyle(
                        color: PrizmaColors.violetDeep,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.utilityScore}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                rank.name,
                style: const TextStyle(
                  color: PrizmaColors.violetDeep,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _ProfileMetric(label: 'Помощь', value: '${user.helpGiven}'),
            _ProfileMetric(label: 'Запросы', value: '${user.requestsCreated}'),
            _ProfileMetric(label: 'Энергия', value: '${user.energy}'),
          ],
        ),
      ],
    ),
  );
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: pageMuted(context), fontSize: 10)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _MyRequestsCard extends StatelessWidget {
  const _MyRequestsCard({required this.requests});

  final List<SosRequest> requests;

  @override
  Widget build(BuildContext context) => PrizmaCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          eyebrow: 'Мои запросы',
          title: 'Что сейчас в пути',
          description: requests.isEmpty
              ? 'Ты ещё не создавал SOS-запросы.'
              : 'Созданные тобой вопросы остаются здесь.',
          trailing: TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/sos'),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_outward_rounded, size: 16),
            label: const Text('Открыть ленту'),
          ),
        ),
        const SizedBox(height: 17),
        if (requests.isEmpty)
          _EmptyRequests()
        else
          for (final request in requests.take(3)) ...[
            _ProfileRequestRow(request: request),
            if (request != requests.take(3).last) const Divider(height: 18),
          ],
      ],
    ),
  );
}

class _EmptyRequests extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.forum_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          const SizedBox(height: 10),
          const Text(
            'Первый вопрос — самый важный',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            'Опиши, в чём нужна ясность, и гильдия поможет.',
            textAlign: TextAlign.center,
            style: TextStyle(color: pageMuted(context), fontSize: 11),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/sos'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Создать SOS'),
          ),
        ],
      ),
    ),
  );
}

class _ProfileRequestRow extends StatelessWidget {
  const _ProfileRequestRow({required this.request});

  final SosRequest request;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SubjectChip(request.subject, compact: true),
      const SizedBox(width: 9),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  request.resolved
                      ? Icons.check_circle_rounded
                      : Icons.schedule_rounded,
                  color: request.resolved
                      ? PrizmaColors.green
                      : PrizmaColors.orange,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  request.resolved ? 'Решён' : 'Ожидает ответа',
                  style: TextStyle(color: pageMuted(context), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Icon(Icons.bolt_rounded, color: PrizmaColors.orange, size: 15),
      Text(
        '${request.reward}',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => PrizmaCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SectionHeading(eyebrow: eyebrow, title: title),
            ),
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 21),
          ],
        ),
        const SizedBox(height: 19),
        child,
      ],
    ),
  );
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: pageMuted(context),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 14),
      Switch(value: value, onChanged: onChanged),
    ],
  );
}

class _FocusTask {
  const _FocusTask({
    required this.id,
    required this.time,
    required this.title,
    required this.subject,
    required this.duration,
  });

  final String id;
  final String time;
  final String title;
  final String subject;
  final String duration;
}

class _Achievement {
  const _Achievement({
    required this.icon,
    required this.tone,
    required this.title,
    required this.description,
    required this.current,
    required this.goal,
  });

  final IconData icon;
  final Color tone;
  final String title;
  final String description;
  final int current;
  final int goal;
}

String _monthTitle(int month) => switch (month) {
  1 => 'Январь',
  2 => 'Февраль',
  3 => 'Март',
  4 => 'Апрель',
  5 => 'Май',
  6 => 'Июнь',
  7 => 'Июль',
  8 => 'Август',
  9 => 'Сентябрь',
  10 => 'Октябрь',
  11 => 'Ноябрь',
  _ => 'Декабрь',
};
