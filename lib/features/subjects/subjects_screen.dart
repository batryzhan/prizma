import 'package:flutter/material.dart';

import '../../app/prizma_app.dart';

/// A browseable catalogue of the learning areas available in Prizma.
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  static const _subjects = <_SubjectDefinition>[
    _SubjectDefinition(
      id: 'math',
      name: 'Математика',
      icon: '∑',
      description: 'Уравнения, функции и понятные разборы шаг за шагом.',
      color: Color(0xFF6C63FF),
      resources: <_StudyResource>[
        _StudyResource('Разбор', 'Системы уравнений без паники', '12 мин'),
        _StudyResource('Тренажёр', 'Производные: 10 коротких задач', '20 мин'),
      ],
    ),
    _SubjectDefinition(
      id: 'physics',
      name: 'Физика',
      icon: '⚛',
      description: 'Формулы, явления и практика без лишнего шума.',
      color: Color(0xFF19B8D2),
      resources: <_StudyResource>[
        _StudyResource('Конспект', 'Законы отражения', '8 мин'),
        _StudyResource('Практика', 'Тепловые задачи', '16 мин'),
      ],
    ),
    _SubjectDefinition(
      id: 'biology',
      name: 'Биология',
      icon: '🧬',
      description: 'Живые системы, процессы и связи между темами.',
      color: Color(0xFF36B37E),
      resources: <_StudyResource>[
        _StudyResource('Карточки', 'Митоз и мейоз', '10 мин'),
        _StudyResource('Разбор', 'Клетка как система', '14 мин'),
      ],
    ),
    _SubjectDefinition(
      id: 'chemistry',
      name: 'Химия',
      icon: '⚗',
      description: 'Реакции, вещества и логика уравнивания.',
      color: Color(0xFFF59E0B),
      resources: <_StudyResource>[
        _StudyResource('Разбор', 'Как уравнивать реакции', '11 мин'),
        _StudyResource('Шпаргалка', 'ОВР на одном листе', '7 мин'),
      ],
    ),
    _SubjectDefinition(
      id: 'history',
      name: 'История',
      icon: '📜',
      description: 'Причины, события и люди в цельной картине.',
      color: Color(0xFFEAB308),
      resources: <_StudyResource>[
        _StudyResource('Лента времени', 'Романовы: начало династии', '9 мин'),
        _StudyResource('Тезисы', 'Французская революция', '13 мин'),
      ],
    ),
    _SubjectDefinition(
      id: 'english',
      name: 'Английский',
      icon: '🌐',
      description: 'Грамматика, словарь и уверенная практика.',
      color: Color(0xFFE879A9),
      resources: <_StudyResource>[
        _StudyResource('Разбор', 'Present Perfect и Past Simple', '12 мин'),
        _StudyResource('Словарь', 'Сильные синонимы для эссе', '6 мин'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final columns = constraints.maxWidth >= 1160
            ? 3
            : constraints.maxWidth >= 680
            ? 2
            : 1;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(wide ? 32 : 20, 24, wide ? 32 : 20, 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageIntro(
                  eyebrow: 'РАБОЧЕЕ ПРОСТРАНСТВО',
                  title: 'Предметы',
                  description:
                      'Короткие материалы, тренажёры и живые вопросы по каждому предмету.',
                  action: FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).pushNamed('/sos'),
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text('К запросам'),
                  ),
                ),
                const SizedBox(height: 28),
                GridView.builder(
                  itemCount: _subjects.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    // Two resource rows and the action need enough room on
                    // one-column mobile grids; a shorter fixed extent clips
                    // the last control on small viewports.
                    mainAxisExtent: 372,
                  ),
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    final openRequests = store.sosList
                        .where(
                          (request) =>
                              request.subject == subject.id &&
                              !request.resolved,
                        )
                        .length;
                    return _SubjectCard(
                      subject: subject,
                      openRequests: openRequests,
                      onOpenRequests: () => Navigator.of(context).pushNamed(
                        '/sos',
                        arguments: <String, String>{'subject': subject.id},
                      ),
                      onOpenResource: (resource) =>
                          _showResourceSheet(context, subject, resource),
                    );
                  },
                ),
                const SizedBox(height: 22),
                _StudyCallout(
                  colorScheme: colorScheme,
                  onFindRequest: () => Navigator.of(context).pushNamed('/sos'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResourceSheet(
    BuildContext context,
    _SubjectDefinition subject,
    _StudyResource resource,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resource.type.toUpperCase(),
                style: Theme.of(sheetContext).textTheme.labelMedium?.copyWith(
                  color: subject.color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resource.title,
                style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${subject.name} · ${resource.duration}. Материал откроется в полной версии Prizma.',
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Понятно'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.action,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 16,
      spacing: 24,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 670),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.15,
                ),
              ),
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        action,
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.openRequests,
    required this.onOpenRequests,
    required this.onOpenResource,
  });

  final _SubjectDefinition subject;
  final int openRequests;
  final VoidCallback onOpenRequests;
  final ValueChanged<_StudyResource> onOpenResource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerLowest;
    final tint = Color.alphaBlend(
      subject.color.withValues(alpha: 0.10),
      surface,
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: tint,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: subject.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subject.icon,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: subject.color.withValues(alpha: 0.13),
                  ),
                  child: Text(
                    '$openRequests SOS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: subject.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              subject.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subject.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.35,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 15),
            for (final resource in subject.resources)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _ResourceRow(
                  resource: resource,
                  color: subject.color,
                  onPressed: () => onOpenResource(resource),
                ),
              ),
            const Spacer(),
            TextButton.icon(
              onPressed: onOpenRequests,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_outward_rounded, size: 17),
              label: const Text('Смотреть запросы'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                foregroundColor: subject.color,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({
    required this.resource,
    required this.color,
    required this.onPressed,
  });

  final _StudyResource resource;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.type.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resource.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                resource.duration,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyCallout extends StatelessWidget {
  const _StudyCallout({required this.colorScheme, required this.onFindRequest});

  final ColorScheme colorScheme;
  final VoidCallback onFindRequest;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            Color.lerp(colorScheme.primary, colorScheme.tertiary, 0.55)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 18,
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 610),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'УЧЕБНЫЙ СОВЕТ ДНЯ',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.05,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Понимание крепнет, когда объясняешь его другому.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Выбери знакомый вопрос — даже короткая подсказка может стать началом решения.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onFindRequest,
              icon: const Icon(Icons.arrow_outward_rounded),
              iconAlignment: IconAlignment.end,
              label: const Text('Найти вопрос'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectDefinition {
  const _SubjectDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
    required this.resources,
  });

  final String id;
  final String name;
  final String icon;
  final String description;
  final Color color;
  final List<_StudyResource> resources;
}

class _StudyResource {
  const _StudyResource(this.type, this.title, this.duration);

  final String type;
  final String title;
  final String duration;
}
