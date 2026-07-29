import 'package:flutter/material.dart';
import 'package:prizma/app/prizma_app.dart';
import 'package:prizma/core/models/prizma_models.dart';

/// The signed-in learner overview.
///
/// [DashboardScreen] is intentionally body-only: `AppShell` supplies the
/// navigation chrome, while this screen owns the responsive dashboard canvas.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _canvas = Color(0xFFF7F8FD);
  static const _ink = Color(0xFF1B2559);
  static const _muted = Color(0xFF6A7193);
  static const _violet = Color(0xFF7551FF);
  static const _line = Color(0xFFE8EAF4);

  static const _dailyPlan = [
    _PlanTask(
      id: 'plan_math',
      time: '09:30',
      title: 'Разобрать квадратные уравнения',
      subject: 'math',
      duration: '35 мин',
    ),
    _PlanTask(
      id: 'plan_physics',
      time: '13:00',
      title: 'Практика: законы отражения',
      subject: 'physics',
      duration: '25 мин',
    ),
    _PlanTask(
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
    final allRequests = store.sosList;
    final openRequests = allRequests
        .where((request) => !request.resolved)
        .toList();
    final suggestedRequests = openRequests
        .where((request) => request.author != user.name)
        .take(3)
        .toList(growable: false);
    final completedIds = store.completedTaskIds.toSet();
    final greeting = _greetingForHour(DateTime.now().hour);
    final rank = _rankFor(user.utilityScore);
    final levelProgress = _levelProgress(user.xp);

    return ColoredBox(
      color: _canvas,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 46),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DashboardHeader(
                        greeting: greeting,
                        name: user.name,
                        onCreate: () => _showCreateSos(context),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 1010
                              ? 4
                              : constraints.maxWidth >= 580
                              ? 2
                              : 1;
                          return GridView.count(
                            crossAxisCount: columns,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: columns == 4
                                ? 2.08
                                : columns == 2
                                ? 2.25
                                : 3.2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              const _MetricCard(
                                icon: Icons.schedule_rounded,
                                iconTone: Color(0xFF7551FF),
                                iconTint: Color(0xFFF0EDFF),
                                label: 'Фокус за неделю',
                                value: '2 ч 40 мин',
                                trend: '↗ 18%',
                                detail: 'ещё 20 мин до цели',
                              ),
                              _MetricCard(
                                icon: Icons.favorite_rounded,
                                iconTone: const Color(0xFFFF7396),
                                iconTint: const Color(0xFFFFF0F4),
                                label: 'Помощь другим',
                                value: '${user.helpGiven} ответов',
                                trend: user.helpGiven > 0 ? '↗ +1' : null,
                                detail: 'твой вклад в сообщество',
                              ),
                              const _MetricCard(
                                icon: Icons.local_fire_department_rounded,
                                iconTone: Color(0xFFFF9F43),
                                iconTint: Color(0xFFFFF4E8),
                                label: 'Серия фокуса',
                                value: '7 дней',
                                trend: 'в ритме',
                                detail: 'лучший результат: 12 дней',
                              ),
                              _MetricCard(
                                icon: Icons.bolt_rounded,
                                iconTone: const Color(0xFFFFB547),
                                iconTint: const Color(0xFFFFF8E9),
                                label: 'Энергия',
                                value: '${user.energy} / 100',
                                trend: '↗ +1',
                                detail: 'восстанавливается со временем',
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 860;
                          final weekly = const _WeeklyFocusCard();
                          final level = _LevelCard(
                            rank: rank,
                            level: user.level,
                            score: user.utilityScore,
                            progress: levelProgress,
                          );
                          return wide
                              ? Row(
                                  // This row lives inside a vertical scroll
                                  // view, where the height is unbounded.
                                  // Stretch would request infinite height.
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Expanded(
                                      flex: 13,
                                      child: _WeeklyFocusCard(),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(flex: 7, child: level),
                                  ],
                                )
                              : Column(
                                  children: [
                                    weekly,
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: level,
                                    ),
                                  ],
                                );
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 1100;
                          final plan = _TodayPlanCard(
                            completedIds: completedIds,
                            onToggle: store.toggleTask,
                          );
                          final requests = _RequestPreviewCard(
                            requests: suggestedRequests,
                            onAllRequests: () =>
                                Navigator.of(context).pushNamed('/sos'),
                            onHelp: (request) =>
                                _helpWithRequest(context, request),
                          );
                          final guild = _GuildPulseCard(
                            members: store.guild,
                            onOpenGuild: () =>
                                Navigator.of(context).pushNamed('/guild'),
                          );
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 10, child: plan),
                                const SizedBox(width: 16),
                                Expanded(flex: 10, child: requests),
                                const SizedBox(width: 16),
                                Expanded(flex: 9, child: guild),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              plan,
                              const SizedBox(height: 16),
                              requests,
                              const SizedBox(height: 16),
                              guild,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateSos(BuildContext context) async {
    final store = PrizmaScope.read(context);
    final questionController = TextEditingController();
    var subject = 'math';
    var reward = 20;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x250A1035),
                          blurRadius: 30,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Новый SOS-запрос',
                                      style: TextStyle(
                                        color: _ink,
                                        fontSize: 21,
                                        letterSpacing: -.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Добавь контекст — так легче помочь.',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
                                icon: const Icon(Icons.close_rounded),
                                color: _muted,
                                tooltip: 'Закрыть',
                              ),
                            ],
                          ),
                          const SizedBox(height: 19),
                          const Text(
                            'ПРЕДМЕТ',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 10,
                              letterSpacing: .9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _subjectLabels.entries
                                .map((entry) {
                                  final selected = subject == entry.key;
                                  return ChoiceChip(
                                    selected: selected,
                                    label: Text(
                                      '${_subjectSymbol(entry.key)} ${entry.value}',
                                    ),
                                    onSelected: (_) => setSheetState(
                                      () => subject = entry.key,
                                    ),
                                    selectedColor: const Color(0xFFEAE6FF),
                                    backgroundColor: const Color(0xFFF8F9FD),
                                    side: BorderSide(
                                      color: selected ? _violet : _line,
                                    ),
                                    labelStyle: TextStyle(
                                      color: selected ? _violet : _muted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  );
                                })
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: questionController,
                            minLines: 4,
                            maxLines: 6,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText:
                                  'Что именно не получается? Приведи условие или то, что уже пробовал(а).',
                              hintStyle: const TextStyle(
                                color: Color(0xFFA5ABC4),
                                fontSize: 13,
                                height: 1.35,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFE),
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: _line),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: _line),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: _violet,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Text(
                                'НАГРАДА',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                  letterSpacing: .9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              ...[10, 20, 30, 50].map(
                                (value) => Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: _RewardPill(
                                    value: value,
                                    selected: reward == value,
                                    onTap: () =>
                                        setSheetState(() => reward = value),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                final question = questionController.text.trim();
                                if (question.length < 10) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Опиши вопрос чуть подробнее — хотя бы 10 символов.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final created = store.createSos(
                                  subject: subject,
                                  question: question,
                                  reward: reward,
                                );
                                if (!created) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Не удалось создать запрос.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(sheetContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'SOS-запрос опубликован. Гильдия уже увидит его.',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: const Text('Опубликовать запрос'),
                              style: FilledButton.styleFrom(
                                backgroundColor: _violet,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    questionController.dispose();
  }

  void _helpWithRequest(BuildContext context, SosRequest request) {
    final result = PrizmaScope.read(context).helpWithSos(request.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }
}

// These palette values are library-level so the small, private dashboard
// widgets below can share the same visual language without a theme lookup in
// every constant widget tree.
const Color _ink = Color(0xFF1B2559);
const Color _muted = Color(0xFF6A7193);
const Color _violet = Color(0xFF7551FF);
const Color _line = Color(0xFFE8EAF4);

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.onCreate,
  });

  final String greeting;
  final String name;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                color: _ink,
                fontSize: 29,
                letterSpacing: -1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${name.isEmpty ? 'ученик' : name}, сегодня достаточно одного ясного шага.',
              style: const TextStyle(
                color: _muted,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (!compact) const _DatePill(),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('Новый запрос'),
              style: FilledButton.styleFrom(
                backgroundColor: _violet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 14,
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        );
        return compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 18), actions],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 18),
                  actions,
                ],
              );
      },
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = _monthNames[now.month - 1];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: _violet),
            const SizedBox(width: 8),
            Text(
              '${now.day} $month',
              style: const TextStyle(
                color: _ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconTone,
    required this.iconTint,
    required this.label,
    required this.value,
    required this.detail,
    this.trend,
  });

  final IconData icon;
  final Color iconTone;
  final Color iconTint;
  final String label;
  final String value;
  final String detail;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconTint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconTone, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 17,
                    letterSpacing: -.45,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trend != null)
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                trend!,
                style: TextStyle(
                  color: trend!.contains('↗')
                      ? const Color(0xFF38B77D)
                      : _violet,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(21),
      ),
      child: child,
    );
  }
}

class _WeeklyFocusCard extends StatelessWidget {
  const _WeeklyFocusCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: SizedBox(
        height: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeading(
              kicker: 'Учебная динамика',
              title: 'Твоя неделя',
              trailing: _SelectPill(label: '7 дней'),
            ),
            const SizedBox(height: 18),
            const Wrap(
              spacing: 10,
              runSpacing: 3,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '12 ч 40 мин',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 23,
                    letterSpacing: -.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '↗ 18% ',
                  style: TextStyle(
                    color: Color(0xFF35AD78),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'к прошлой неделе',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            const Expanded(child: _WeeklyChart()),
          ],
        ),
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({
    required this.kicker,
    required this.title,
    this.trailing,
  });

  final String kicker;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kicker.toUpperCase(),
                style: const TextStyle(
                  color: _violet,
                  fontSize: 9,
                  letterSpacing: .9,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 18,
                  letterSpacing: -.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (trailing case final Widget item) item,
      ],
    );
  }
}

class _SelectPill extends StatelessWidget {
  const _SelectPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 15,
            color: _muted,
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _WeeklyChartPainter())),
            Positioned(
              top: 3,
              right: constraints.maxWidth * .095,
              child: const _ChartTooltip(),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ChartLabel('Пн'),
                    _ChartLabel('Вт'),
                    _ChartLabel('Ср'),
                    _ChartLabel('Чт'),
                    _ChartLabel('Пт'),
                    _ChartLabel('Сб'),
                    _ChartLabel('Вс'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChartLabel extends StatelessWidget {
  const _ChartLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFA0A6C0),
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ChartTooltip extends StatelessWidget {
  const _ChartTooltip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '2ч 25м',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _WeeklyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - 20;
    final guides = Paint()
      ..color = const Color(0xFFECEEFA)
      ..strokeWidth = 1;
    for (var line = 1; line < 4; line++) {
      final y = chartHeight * line / 4;
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset(size.width, y),
        guides,
      );
    }

    final curve = Path()
      ..moveTo(0, chartHeight * .78)
      ..cubicTo(
        size.width * .08,
        chartHeight * .62,
        size.width * .11,
        chartHeight * .86,
        size.width * .21,
        chartHeight * .61,
      )
      ..cubicTo(
        size.width * .31,
        chartHeight * .34,
        size.width * .36,
        chartHeight * .73,
        size.width * .46,
        chartHeight * .42,
      )
      ..cubicTo(
        size.width * .55,
        chartHeight * .17,
        size.width * .64,
        chartHeight * .60,
        size.width * .74,
        chartHeight * .25,
      )
      ..cubicTo(
        size.width * .84,
        chartHeight * .02,
        size.width * .90,
        chartHeight * .23,
        size.width,
        chartHeight * .08,
      );
    final area = Path.from(curve)
      ..lineTo(size.width, chartHeight)
      ..lineTo(0, chartHeight)
      ..close();
    canvas.drawPath(area, Paint()..color = const Color(0x267551FF));
    canvas.drawPath(
      curve,
      Paint()
        ..color = _violet
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    final end = Offset(size.width, chartHeight * .08);
    canvas.drawCircle(end, 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(end, 3, Paint()..color = _violet);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.rank,
    required this.level,
    required this.score,
    required this.progress,
  });

  final String rank;
  final int level;
  final int score;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final remaining = (100 - (score % 100)) % 100;
    return _SectionCard(
      child: SizedBox(
        height: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeading(
              kicker: 'Точка роста',
              title: rank,
              trailing: _LevelBadge(level: level),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 108,
                height: 108,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 108,
                      height: 108,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 9,
                        backgroundColor: const Color(0xFFECE8FF),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          _violet,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 23,
                            letterSpacing: -.8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'POINTS',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 8,
                            letterSpacing: .7,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'До следующей грани',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  remaining == 0 ? 'Новый уровень!' : '$remaining pts',
                  style: const TextStyle(
                    color: _violet,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFECE8FF),
                valueColor: const AlwaysStoppedAnimation<Color>(_violet),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDFF),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        'LVL $level',
        style: const TextStyle(
          color: _violet,
          fontSize: 10,
          letterSpacing: .5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard({required this.completedIds, required this.onToggle});

  final Set<String> completedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            kicker: 'Собери день в ритм',
            title: 'План на сегодня',
            trailing: _TextRouteButton(
              label: 'Весь план',
              onTap: () => Navigator.of(context).pushNamed('/progress'),
            ),
          ),
          const SizedBox(height: 17),
          ...DashboardScreen._dailyPlan.map((task) {
            final done = completedIds.contains(task.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _TimelineTask(
                task: task,
                done: done,
                onToggle: () => onToggle(task.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineTask extends StatelessWidget {
  const _TimelineTask({
    required this.task,
    required this.done,
    required this.onToggle,
  });

  final _PlanTask task;
  final bool done;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 38,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              task.time,
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF4BCB8C) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: done ? const Color(0xFF4BCB8C) : const Color(0xFFD7DBE9),
                width: 1.5,
              ),
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  color: done ? const Color(0xFF8B90A8) : _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  _SubjectChip(subject: task.subject, compact: true),
                  const SizedBox(width: 7),
                  Text(
                    task.duration,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestPreviewCard extends StatelessWidget {
  const _RequestPreviewCard({
    required this.requests,
    required this.onAllRequests,
    required this.onHelp,
  });

  final List<SosRequest> requests;
  final VoidCallback onAllRequests;
  final ValueChanged<SosRequest> onHelp;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            kicker: 'Запросы от сообщества',
            title: 'Рядом нужна помощь',
            trailing: _TextRouteButton(label: 'Все', onTap: onAllRequests),
          ),
          const SizedBox(height: 14),
          if (requests.isEmpty)
            const _EmptyRequests()
          else
            ...requests.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MiniRequestCard(
                  request: request,
                  onHelp: () => onHelp(request),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.favorite_outline_rounded, color: Color(0xFFFF7A9A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Лента уже стала спокойнее. Новые вопросы появятся здесь.',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRequestCard extends StatelessWidget {
  const _MiniRequestCard({required this.request, required this.onHelp});

  final SosRequest request;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SubjectChip(subject: request.subject, compact: true),
              const Spacer(),
              Text(
                _timeAgo(request.createdAt),
                style: const TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.question,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              height: 1.34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InitialAvatar(
                value: request.authorAvatar,
                size: 22,
                tone: _subjectColor(request.subject),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request.author,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              TextButton(
                onPressed: onHelp,
                style: TextButton.styleFrom(
                  foregroundColor: _violet,
                  backgroundColor: const Color(0xFFF0EDFF),
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Помочь'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuildPulseCard extends StatelessWidget {
  const _GuildPulseCard({required this.members, required this.onOpenGuild});

  final List<GuildMember> members;
  final VoidCallback onOpenGuild;

  @override
  Widget build(BuildContext context) {
    final online = members
        .where((member) => member.status == 'online')
        .toList(growable: false);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            kicker: 'Сегодня рядом',
            title: 'Пульс гильдии',
            trailing: _TextRouteButton(label: 'В гильдию', onTap: onOpenGuild),
          ),
          const SizedBox(height: 17),
          _ActivityRow(
            icon: Icons.favorite_rounded,
            tone: const Color(0xFFFF7396),
            title: 'Mira_X закрыла SOS по математике',
            detail: 'В сообществе стало на один понятный ответ больше.',
            time: '12 мин',
          ),
          const SizedBox(height: 13),
          _ActivityRow(
            icon: Icons.local_fire_department_rounded,
            tone: const Color(0xFFFF9F43),
            title: 'Dev_K держит серию 10 дней',
            detail: 'Устойчивость складывается из маленьких сессий.',
            time: '1 ч',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF5FBFC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                _AvatarCluster(members: online.take(3).toList(growable: false)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    online.isEmpty
                        ? 'Гильдия вернётся чуть позже'
                        : '${online.length} участника сейчас онлайн',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.circle, size: 8, color: Color(0xFF42C894)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.detail,
    required this.time,
  });

  final IconData icon;
  final Color tone;
  final String title;
  final String detail;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: _tint(tone),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: tone, size: 16),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 9.5,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          time,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AvatarCluster extends StatelessWidget {
  const _AvatarCluster({required this.members});

  final List<GuildMember> members;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: members.isEmpty ? 25 : 21 + (members.length - 1) * 15,
      height: 25,
      child: Stack(
        children: [
          for (var index = 0; index < members.length; index++)
            Positioned(
              left: index * 15,
              child: _InitialAvatar(
                value: members[index].avatar,
                size: 25,
                tone: _avatarTone(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({
    required this.value,
    required this.size,
    required this.tone,
  });

  final String value;
  final double size;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.trim();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _tint(tone),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        safeValue.isEmpty ? '?' : safeValue.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: tone,
          fontSize: size * .39,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TextRouteButton extends StatelessWidget {
  const _TextRouteButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        foregroundColor: _violet,
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_outward_rounded, size: 13),
        ],
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.subject, this.compact = false});

  final String subject;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _subjectColor(subject);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: _tint(color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        compact
            ? '${_subjectSymbol(subject)} ${_subjectLabels[subject] ?? subject}'
            : _subjectLabels[subject] ?? subject,
        style: TextStyle(
          color: color,
          fontSize: compact ? 8.5 : 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF4DC) : const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: selected ? const Color(0xFFFFC664) : _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, size: 13, color: Color(0xFFFFB547)),
            Text(
              '$value',
              style: TextStyle(
                color: selected ? const Color(0xFFB97700) : _muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTask {
  const _PlanTask({
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

String _greetingForHour(int hour) {
  if (hour < 12) return 'Доброе утро';
  if (hour < 18) return 'Добрый день';
  return 'Добрый вечер';
}

String _rankFor(int score) {
  if (score >= 1500) return 'Легенда';
  if (score >= 700) return 'Мудрец';
  if (score >= 350) return 'Мастер';
  if (score >= 150) return 'Знаток';
  if (score >= 50) return 'Ученик';
  return 'Новичок';
}

double _levelProgress(int xp) => (xp % 100) / 100;

String _timeAgo(DateTime time) {
  final delta = DateTime.now().difference(time);
  if (delta.inMinutes < 1) return 'сейчас';
  if (delta.inMinutes < 60) return '${delta.inMinutes} мин';
  if (delta.inHours < 24) return '${delta.inHours} ч';
  return '${delta.inDays} д';
}

Color _tint(Color color) => Color.alphaBlend(const Color(0xDFFFFFFF), color);

Color _avatarTone(int index) {
  const colors = [Color(0xFF7551FF), Color(0xFF3CC7D5), Color(0xFFFF7396)];
  return colors[index % colors.length];
}

Color _subjectColor(String subject) {
  switch (subject) {
    case 'math':
      return const Color(0xFF7551FF);
    case 'physics':
      return const Color(0xFF3CA8E7);
    case 'biology':
      return const Color(0xFF49B987);
    case 'chemistry':
      return const Color(0xFFFF9F43);
    case 'history':
      return const Color(0xFFFF7396);
    case 'english':
      return const Color(0xFF2BBFC7);
    default:
      return const Color(0xFF7551FF);
  }
}

String _subjectSymbol(String subject) {
  switch (subject) {
    case 'math':
      return '∑';
    case 'physics':
      return '⚛';
    case 'biology':
      return '🧬';
    case 'chemistry':
      return '⚗';
    case 'history':
      return '📜';
    case 'english':
      return '🌐';
    default:
      return '✦';
  }
}

const _subjectLabels = <String, String>{
  'math': 'Математика',
  'physics': 'Физика',
  'biology': 'Биология',
  'chemistry': 'Химия',
  'history': 'История',
  'english': 'Английский',
};

const _monthNames = [
  'янв.',
  'фев.',
  'мар.',
  'апр.',
  'мая',
  'июн.',
  'июл.',
  'авг.',
  'сен.',
  'окт.',
  'ноя.',
  'дек.',
];
